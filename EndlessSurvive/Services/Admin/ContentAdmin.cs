using System.Globalization;
using System.Text;
using Dapper;
using Microsoft.Data.Sqlite;

namespace EndlessSurvive.Services.Admin;

public sealed record ColumnInfo(
    string Name, string Type, bool NotNull, string? Default, bool IsPk,
    string? FkTable, string? Description, string Editor)
{
    public bool IsInteger => Type.Contains("INT", StringComparison.OrdinalIgnoreCase);
    public bool IsReal => Type.Contains("REAL", StringComparison.OrdinalIgnoreCase) || Type.Contains("FLOA", StringComparison.OrdinalIgnoreCase);
    /// <summary>Verweis auf eine andere Tabelle (Fremdschluessel oder Editor "ref:Tabelle").</summary>
    public string? RefTable => FkTable ?? (Editor.StartsWith("ref:") ? Editor[4..] : null);
}

public sealed record TableInfo(
    string Name, string Label, string Group, string? Description, int SortOrder,
    IReadOnlyList<ColumnInfo> Columns, IReadOnlyList<string> DisplayColumns, string CreateSql)
{
    public ColumnInfo? Pk => Columns.Count(c => c.IsPk) == 1 ? Columns.First(c => c.IsPk) : null;
    /// <summary>Automatisch vergebene Nummer (INTEGER PRIMARY KEY).</summary>
    public bool AutoId => Pk is { IsInteger: true };
    public bool IsMeta => Name.StartsWith('_');
    public ColumnInfo? Column(string name) => Columns.FirstOrDefault(c => c.Name.Equals(name, StringComparison.OrdinalIgnoreCase));
    /// <summary>Spalte mit einem lesbaren Namen fuer Auswahllisten.</summary>
    public string? TitleColumn => new[] { "Name", "Title", "Label" }.FirstOrDefault(n => Column(n) is not null);
}

public sealed class ContentRow
{
    public long RowId { get; init; }
    public Dictionary<string, object?> Values { get; } = new(StringComparer.OrdinalIgnoreCase);
    public object? this[string col] => Values.GetValueOrDefault(col);
    public string Text(string col) => ContentAdmin.Format(this[col]);
}

public sealed record RefOption(string Value, string Label);

public sealed record ChildRows(TableInfo Table, ColumnInfo Column, IReadOnlyList<ContentRow> Rows);

/// <summary>
/// Schreibender Zugriff auf content.db fuer die Verwaltung. Arbeitet generisch auf dem
/// Datenbankschema: neue Tabellen und Spalten erscheinen ohne Codeaenderung.
/// Nach jeder Aenderung: Sicherung (hoechstens alle 10 Minuten), content.sql neu
/// schreiben, Inhalte im Spiel neu laden.
/// </summary>
public sealed class ContentAdmin
{
    private readonly ContentStore _content;
    private readonly string _sqlPath;
    private readonly string _backupDir;
    private readonly object _lock = new();
    private DateTime _lastBackup = DateTime.MinValue;

    public ContentAdmin(ContentStore content, IWebHostEnvironment env)
    {
        _content = content;
        var dataDir = Path.Combine(env.ContentRootPath, "Data");
        _sqlPath = Path.Combine(dataDir, "content.sql");
        _backupDir = Path.Combine(dataDir, "backups");
    }

    /// <summary>Wird nach jeder Aenderung ausgeloest.</summary>
    public event Action? Changed;

    public string? LastBackup { get; private set; }

    private SqliteConnection Open()
    {
        var c = new SqliteConnection($"Data Source={_content.DbPath}");
        c.Open();
        c.Execute("PRAGMA foreign_keys = ON;");
        return c;
    }

    private static string Q(string identifier) => "\"" + identifier.Replace("\"", "\"\"") + "\"";

    // =================================================================
    //  Schema
    // =================================================================

    public IReadOnlyList<TableInfo> Tables()
    {
        using var c = Open();
        var names = c.Query<(string Name, string Sql)>(
            "SELECT name, sql FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'").ToList();
        var tdocs = HasTable(c, "_TableDocs")
            ? c.Query<(string TableName, string Label, string GroupName, string? Description, string? DisplayColumns, long SortOrder)>(
                "SELECT TableName, Label, GroupName, Description, DisplayColumns, SortOrder FROM _TableDocs").ToDictionary(t => t.TableName)
            : new();
        var cdocs = HasTable(c, "_ColumnDocs")
            ? c.Query<(string TableName, string ColumnName, string? Description, string? Editor)>(
                "SELECT TableName, ColumnName, Description, Editor FROM _ColumnDocs").ToDictionary(d => (d.TableName, d.ColumnName))
            : new();

        var result = new List<TableInfo>();
        foreach (var (name, sql) in names)
        {
            var fks = c.Query<(string Table, string From)>($"SELECT \"table\", \"from\" FROM pragma_foreign_key_list({Lit(name)})")
                .ToDictionary(f => f.From, f => f.Table, StringComparer.OrdinalIgnoreCase);
            var cols = new List<ColumnInfo>();
            foreach (var col in c.Query<(string Name, string Type, long NotNull, string? Dflt, long Pk)>(
                         $"SELECT name, type, \"notnull\", dflt_value, pk FROM pragma_table_info({Lit(name)})"))
            {
                cdocs.TryGetValue((name, col.Name), out var doc);
                var editor = doc.Editor ?? "";
                if (editor == "") editor = col.Type.Contains("INT", StringComparison.OrdinalIgnoreCase) ? "int"
                    : col.Type.Contains("REAL", StringComparison.OrdinalIgnoreCase) ? "real" : "text";
                cols.Add(new ColumnInfo(col.Name, col.Type, col.NotNull == 1, col.Dflt, col.Pk > 0,
                    fks.GetValueOrDefault(col.Name), doc.Description, editor));
            }
            tdocs.TryGetValue(name, out var td);
            var display = (td.DisplayColumns ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(d => cols.Any(x => x.Name.Equals(d, StringComparison.OrdinalIgnoreCase))).ToList();
            if (display.Count == 0) display = cols.Take(6).Select(x => x.Name).ToList();
            result.Add(new TableInfo(name, td.Label ?? name, td.GroupName ?? (name.StartsWith('_') ? "Meta" : "Weitere"),
                td.Description, (int)(td.TableName is null ? 1000 : td.SortOrder), cols, display, sql));
        }
        return result.OrderBy(t => t.SortOrder).ThenBy(t => t.Name).ToList();
    }

    public TableInfo? Table(string name) => Tables().FirstOrDefault(t => t.Name.Equals(name, StringComparison.OrdinalIgnoreCase));

    private static bool HasTable(SqliteConnection c, string name) =>
        c.ExecuteScalar<long>("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=@name", new { name }) > 0;

    private static string Lit(string s) => "'" + s.Replace("'", "''") + "'";

    // =================================================================
    //  Lesen
    // =================================================================

    public IReadOnlyList<ContentRow> Rows(TableInfo t, string? whereColumn = null, object? whereValue = null)
    {
        using var c = Open();
        var order = t.Column("SortOrder") is not null && t.Column("EventKey") is not null ? "EventKey, SortOrder, rowid"
            : t.Column("SortOrder") is not null ? "SortOrder, rowid" : "rowid";
        var sql = $"SELECT rowid AS __rowid, * FROM {Q(t.Name)}";
        if (whereColumn is not null) sql += $" WHERE {Q(whereColumn)} = @v";
        sql += $" ORDER BY {order}";
        return Read(c, sql, new { v = whereValue });
    }

    public ContentRow? Row(TableInfo t, long rowId)
    {
        using var c = Open();
        return Read(c, $"SELECT rowid AS __rowid, * FROM {Q(t.Name)} WHERE rowid = @rowId", new { rowId }).FirstOrDefault();
    }

    public ContentRow? RowByKey(TableInfo t, string key)
    {
        if (t.Pk is null) return null;
        using var c = Open();
        return Read(c, $"SELECT rowid AS __rowid, * FROM {Q(t.Name)} WHERE {Q(t.Pk.Name)} = @key", new { key }).FirstOrDefault();
    }

    private static List<ContentRow> Read(SqliteConnection c, string sql, object? args)
    {
        var list = new List<ContentRow>();
        using var r = c.ExecuteReader(sql, args);
        while (r.Read())
        {
            var row = new ContentRow { RowId = r.GetInt64(0) };
            for (int i = 1; i < r.FieldCount; i++)
                row.Values[r.GetName(i)] = r.IsDBNull(i) ? null : r.GetValue(i);
            list.Add(row);
        }
        return list;
    }

    /// <summary>Auswahlwerte fuer einen Verweis auf eine Tabelle (Primaerschluessel + Name).</summary>
    public IReadOnlyList<RefOption> RefOptions(string table)
    {
        var t = Table(table);
        if (t?.Pk is null) return [];
        var title = t.TitleColumn;
        return Rows(t).Select(r => new RefOption(r.Text(t.Pk.Name),
            title is null ? r.Text(t.Pk.Name) : $"{r.Text(t.Pk.Name)} – {r.Text(title)}")).ToList();
    }

    /// <summary>Zeilen anderer Tabellen, die per Fremdschluessel auf diese Zeile verweisen.</summary>
    public IReadOnlyList<ChildRows> Children(TableInfo t, ContentRow row)
    {
        if (t.Pk is null) return [];
        var key = row[t.Pk.Name];
        var result = new List<ChildRows>();
        foreach (var other in Tables())
            foreach (var col in other.Columns.Where(x => x.FkTable is not null && x.FkTable.Equals(t.Name, StringComparison.OrdinalIgnoreCase)))
                result.Add(new ChildRows(other, col, Rows(other, col.Name, key)));
        return result;
    }

    // =================================================================
    //  Schreiben
    // =================================================================

    /// <summary>Wandelt Formularwerte (Text) in passende SQLite-Werte um.</summary>
    public static object? Convert(ColumnInfo col, string? input, out string? error)
    {
        error = null;
        var s = input?.Trim() ?? "";
        if (s == "")
        {
            if (col.NotNull && col.Default is null && !(col.IsPk && col.IsInteger))
                error = "Pflichtfeld";
            return null;
        }
        if (col.IsInteger)
        {
            if (long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var l)) return l;
            error = "Ganze Zahl erwartet";
            return null;
        }
        if (col.IsReal)
        {
            if (double.TryParse(s.Replace(',', '.'), NumberStyles.Float, CultureInfo.InvariantCulture, out var d)) return d;
            error = "Zahl erwartet (z. B. 0.25)";
            return null;
        }
        return input; // Text unveraendert (inkl. Zeilenumbrueche)
    }

    public long Insert(TableInfo t, IReadOnlyDictionary<string, object?> values)
    {
        lock (_lock)
        {
            Backup();
            using var c = Open();
            // leere Felder weglassen, damit DEFAULT-Werte greifen
            var cols = values.Where(kv => kv.Value is not null && t.Column(kv.Key) is not null).ToList();
            var sql = cols.Count == 0
                ? $"INSERT INTO {Q(t.Name)} DEFAULT VALUES"
                : $"INSERT INTO {Q(t.Name)} ({string.Join(", ", cols.Select(kv => Q(kv.Key)))}) VALUES ({string.Join(", ", cols.Select((_, i) => "@p" + i))})";
            var p = new DynamicParameters();
            for (int i = 0; i < cols.Count; i++) p.Add("p" + i, cols[i].Value);
            c.Execute(sql, p);
            var id = c.ExecuteScalar<long>("SELECT last_insert_rowid()");
            AfterWrite();
            return id;
        }
    }

    public void Update(TableInfo t, long rowId, IReadOnlyDictionary<string, object?> values)
    {
        lock (_lock)
        {
            Backup();
            using var c = Open();
            var cols = values.Where(kv => t.Column(kv.Key) is { } col && !(col.IsPk && t.AutoId)).ToList();
            if (cols.Count == 0) return;
            var sql = $"UPDATE {Q(t.Name)} SET {string.Join(", ", cols.Select((kv, i) => $"{Q(kv.Key)} = @p{i}"))} WHERE rowid = @rowId";
            var p = new DynamicParameters();
            for (int i = 0; i < cols.Count; i++) p.Add("p" + i, cols[i].Value);
            p.Add("rowId", rowId);
            c.Execute(sql, p);
            AfterWrite();
        }
    }

    /// <summary>
    /// Loescht eine Zeile. Mit cascade werden verweisende Zeilen mitgeloescht (Pflicht-Verweis)
    /// bzw. ihr Verweis geleert (optionaler Verweis).
    /// </summary>
    public void Delete(TableInfo t, long rowId, bool cascade)
    {
        lock (_lock)
        {
            Backup();
            var row = Row(t, rowId);
            if (row is null) return;
            // Erst den kompletten Plan lesen (rekursiv: Ruine -> Stockwerke -> Objekte), dann in einer Transaktion ausfuehren
            var plan = new List<(string Sql, object Args)>();
            if (cascade) PlanCascade(t, row, plan, new HashSet<(string, long)>());
            plan.Add(($"DELETE FROM {Q(t.Name)} WHERE rowid = @rowId", new { rowId }));
            using var c = Open();
            using var tx = c.BeginTransaction();
            foreach (var (sql, args) in plan) c.Execute(sql, args, tx);
            tx.Commit();
            AfterWrite();
        }
    }

    private void PlanCascade(TableInfo t, ContentRow row, List<(string, object)> plan, HashSet<(string, long)> seen)
    {
        if (!seen.Add((t.Name, row.RowId))) return;
        foreach (var ch in Children(t, row))
        {
            var v = row[t.Pk!.Name];
            if (ch.Column.NotNull)
            {
                foreach (var child in ch.Rows) PlanCascade(ch.Table, child, plan, seen); // Enkel zuerst
                plan.Add(($"DELETE FROM {Q(ch.Table.Name)} WHERE {Q(ch.Column.Name)} = @v", new { v }));
            }
            else
            {
                plan.Add(($"UPDATE {Q(ch.Table.Name)} SET {Q(ch.Column.Name)} = NULL WHERE {Q(ch.Column.Name)} = @v", new { v }));
            }
        }
    }

    private void AfterWrite()
    {
        ExportSql();
        _content.Load();
        Changed?.Invoke();
    }

    // =================================================================
    //  Sicherung und Export
    // =================================================================

    /// <summary>Sicherung von content.db nach Data/backups (hoechstens alle 10 Minuten, die letzten 20 bleiben).</summary>
    public void Backup(bool force = false)
    {
        if (!force && DateTime.Now - _lastBackup < TimeSpan.FromMinutes(10)) return;
        Directory.CreateDirectory(_backupDir);
        var file = Path.Combine(_backupDir, $"content-{DateTime.Now:yyyyMMdd-HHmmss}.db");
        using (var src = Open())
        using (var dst = new SqliteConnection($"Data Source={file};Pooling=False"))
        {
            dst.Open();
            src.BackupDatabase(dst);
        }
        _lastBackup = DateTime.Now;
        LastBackup = Path.GetFileName(file);
        foreach (var old in Directory.GetFiles(_backupDir, "content-*.db").OrderByDescending(f => f).Skip(20))
            File.Delete(old);
    }

    public IReadOnlyList<string> Backups() =>
        Directory.Exists(_backupDir)
            ? Directory.GetFiles(_backupDir, "content-*.db").OrderByDescending(f => f).Select(f => Path.GetFileName(f)).ToList()
            : [];

    /// <summary>Ersetzt content.db durch eine Sicherung (die aktuelle Fassung wird vorher gesichert).</summary>
    public void Restore(string backupFile)
    {
        lock (_lock)
        {
            var path = Path.Combine(_backupDir, Path.GetFileName(backupFile));
            if (!File.Exists(path)) return;
            Backup(force: true);
            using (var src = new SqliteConnection($"Data Source={path};Mode=ReadOnly;Pooling=False"))
            using (var dst = Open())
            {
                src.Open();
                src.BackupDatabase(dst);
            }
            AfterWrite();
        }
    }

    /// <summary>
    /// Schreibt content.sql als vollstaendigen, lesbaren Abzug von content.db.
    /// So bleiben beide Dateien synchron und Aenderungen sind in git als Text-Diff sichtbar.
    /// </summary>
    public void ExportSql()
    {
        using var c = Open();
        var tables = Tables();
        var deps = tables.ToDictionary(t => t.Name, t => t.Columns.Where(x => x.FkTable is not null).Select(x => x.FkTable!).ToHashSet(StringComparer.OrdinalIgnoreCase));
        // Tabellen so sortieren, dass referenzierte Tabellen zuerst kommen
        var ordered = new List<TableInfo>();
        var done = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        while (ordered.Count < tables.Count)
        {
            var next = tables.FirstOrDefault(t => !done.Contains(t.Name) && deps[t.Name].All(d => done.Contains(d) || d.Equals(t.Name, StringComparison.OrdinalIgnoreCase)))
                       ?? tables.First(t => !done.Contains(t.Name));
            ordered.Add(next);
            done.Add(next.Name);
        }

        var sb = new StringBuilder();
        sb.AppendLine("-- =====================================================================");
        sb.AppendLine("--  EndlessSurvive - Inhaltsdatenbank (content.db) als SQL");
        sb.AppendLine("--  Diese Datei wird von der Verwaltung (/admin) bei jeder Aenderung neu");
        sb.AppendLine("--  geschrieben. Fehlt content.db, wird sie beim Start hieraus erzeugt.");
        sb.AppendLine("--  Spaltenbeschreibungen: Tabelle _ColumnDocs.");
        sb.AppendLine("-- =====================================================================");
        sb.AppendLine("PRAGMA foreign_keys = ON;");
        foreach (var t in ordered)
        {
            sb.AppendLine();
            sb.AppendLine($"-- {t.Label}{(t.Description is null ? "" : ": " + t.Description.Replace("\n", " "))}");
            sb.AppendLine(t.CreateSql.TrimEnd().TrimEnd(';') + ";");
            var rows = Read(c, $"SELECT rowid AS __rowid, * FROM {Q(t.Name)} ORDER BY rowid", null);
            if (rows.Count == 0) continue;
            var colList = string.Join(",", t.Columns.Select(x => x.Name));
            foreach (var r in rows)
                sb.AppendLine($"INSERT INTO {t.Name} ({colList}) VALUES ({string.Join(", ", t.Columns.Select(x => SqlLiteral(r[x.Name])))});");
        }
        var tmp = _sqlPath + ".tmp";
        File.WriteAllText(tmp, sb.ToString(), new UTF8Encoding(false));
        File.Move(tmp, _sqlPath, overwrite: true);
    }

    private static string SqlLiteral(object? v) => v switch
    {
        null => "NULL",
        long or int or short or byte => System.Convert.ToString(v, CultureInfo.InvariantCulture)!,
        double d => d.ToString("R", CultureInfo.InvariantCulture),
        float f => ((double)f).ToString("R", CultureInfo.InvariantCulture),
        byte[] b => "X'" + System.Convert.ToHexString(b) + "'",
        _ => "'" + System.Convert.ToString(v, CultureInfo.InvariantCulture)!.Replace("'", "''") + "'",
    };

    public static string Format(object? v) => v switch
    {
        null => "",
        double d => d.ToString("0.###", CultureInfo.InvariantCulture),
        _ => System.Convert.ToString(v, CultureInfo.InvariantCulture) ?? "",
    };

    /// <summary>Inhalte im Spiel neu laden (z. B. nach Bearbeitung mit einem externen Werkzeug).</summary>
    public void Reload()
    {
        _content.Load();
        Changed?.Invoke();
    }
}
