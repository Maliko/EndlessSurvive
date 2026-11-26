using Dapper;
using Microsoft.Data.Sqlite;

namespace EndlessSurvive.Services;

/// <summary>Spielstand in Data/save.db (wird automatisch angelegt).</summary>
public sealed class SaveStore
{
    private readonly string _cs;

    public SaveStore(IWebHostEnvironment env, IConfiguration config)
    {
        var path = Path.Combine(env.ContentRootPath, "Data", config["SaveDb"] ?? "save.db");
        _cs = $"Data Source={path}";
        using var c = Open();
        c.Execute("""
            CREATE TABLE IF NOT EXISTS Character (
                Id INTEGER PRIMARY KEY CHECK (Id = 1),
                Name TEXT NOT NULL, Seed INTEGER NOT NULL, Level INTEGER NOT NULL, Xp INTEGER NOT NULL,
                Hp INTEGER NOT NULL, X INTEGER NOT NULL, Y INTEGER NOT NULL,
                AttributePoints INTEGER NOT NULL, SkillPoints INTEGER NOT NULL, Turn INTEGER NOT NULL,
                Deaths INTEGER NOT NULL, Kills INTEGER NOT NULL, MaxDanger INTEGER NOT NULL, CreatedAt TEXT NOT NULL);
            CREATE TABLE IF NOT EXISTS CharacterAttributes (Key TEXT PRIMARY KEY, Value INTEGER NOT NULL);
            CREATE TABLE IF NOT EXISTS CharacterSkills (Key TEXT PRIMARY KEY, Ranks INTEGER NOT NULL);
            CREATE TABLE IF NOT EXISTS Inventory (Id INTEGER PRIMARY KEY, ItemKey TEXT NOT NULL, Level INTEGER NOT NULL,
                Quantity INTEGER NOT NULL, Equipped INTEGER NOT NULL);
            CREATE TABLE IF NOT EXISTS Tiles (X INTEGER NOT NULL, Y INTEGER NOT NULL, State INTEGER NOT NULL, PRIMARY KEY (X, Y));
            CREATE TABLE IF NOT EXISTS FoundLore (LoreId INTEGER PRIMARY KEY);
            CREATE TABLE IF NOT EXISTS Log (Id INTEGER PRIMARY KEY AUTOINCREMENT, Turn INTEGER NOT NULL, Kind TEXT NOT NULL, Text TEXT NOT NULL);
            """);
    }

    private SqliteConnection Open()
    {
        var c = new SqliteConnection(_cs);
        c.Open();
        return c;
    }

    /// <summary>
    /// Wird ausgeloest, wenn der Spielstand ausserhalb des Spiels geaendert wurde (Verwaltung).
    /// Laufende Spiele laden ihn dann neu, statt ihn beim naechsten Zug zu ueberschreiben.
    /// </summary>
    public event Action? ExternallyChanged;

    public void NotifyExternalChange() => ExternallyChanged?.Invoke();

    /// <summary>Erkundung zuruecksetzen. resolvedOnly: nur erledigte Orte wieder oeffnen.</summary>
    public void ResetTiles(bool resolvedOnly)
    {
        using var c = Open();
        c.Execute(resolvedOnly ? "UPDATE Tiles SET State = State & ~2" : "DELETE FROM Tiles");
    }

    public void SetLore(IEnumerable<long> ids)
    {
        using var c = Open();
        using var tx = c.BeginTransaction();
        c.Execute("DELETE FROM FoundLore", transaction: tx);
        c.Execute("INSERT INTO FoundLore (LoreId) VALUES (@Id)", ids.Select(id => new { Id = id }), tx);
        tx.Commit();
    }

    public bool Exists()
    {
        using var c = Open();
        return c.ExecuteScalar<long>("SELECT COUNT(*) FROM Character") > 0;
    }

    public CharacterState? PeekCharacter()
    {
        using var c = Open();
        return c.QueryFirstOrDefault<CharacterState>("SELECT * FROM Character WHERE Id = 1");
    }

    public void Delete()
    {
        using var c = Open();
        c.Execute("DELETE FROM Character; DELETE FROM CharacterAttributes; DELETE FROM CharacterSkills; DELETE FROM Inventory; DELETE FROM Tiles; DELETE FROM FoundLore; DELETE FROM Log;");
    }

    public GameState? Load()
    {
        using var c = Open();
        var ch = c.QueryFirstOrDefault<CharacterState>("SELECT * FROM Character WHERE Id = 1");
        if (ch is null) return null;
        var s = new GameState { Char = ch };
        foreach (var (k, v) in c.Query<(string, int)>("SELECT Key, Value FROM CharacterAttributes")) s.Attributes[k] = v;
        foreach (var (k, v) in c.Query<(string, int)>("SELECT Key, Ranks FROM CharacterSkills")) s.Skills[k] = v;
        s.Inventory.AddRange(c.Query<InventoryItem>("SELECT * FROM Inventory ORDER BY Id"));
        foreach (var (x, y, st) in c.Query<(int, int, int)>("SELECT X, Y, State FROM Tiles")) s.Tiles[(x, y)] = (TileFlags)st;
        foreach (var id in c.Query<long>("SELECT LoreId FROM FoundLore")) s.FoundLore.Add(id);
        s.Log.AddRange(c.Query<LogEntry>("SELECT Turn, Kind, Text FROM (SELECT * FROM Log ORDER BY Id DESC LIMIT 80) ORDER BY Id"));
        return s;
    }

    public void Save(GameState s)
    {
        using var c = Open();
        using var tx = c.BeginTransaction();
        c.Execute("""
            INSERT OR REPLACE INTO Character (Id, Name, Seed, Level, Xp, Hp, X, Y, AttributePoints, SkillPoints, Turn, Deaths, Kills, MaxDanger, CreatedAt)
            VALUES (1, @Name, @Seed, @Level, @Xp, @Hp, @X, @Y, @AttributePoints, @SkillPoints, @Turn, @Deaths, @Kills, @MaxDanger, @CreatedAt)
            """, s.Char, tx);
        c.Execute("DELETE FROM CharacterAttributes; DELETE FROM CharacterSkills; DELETE FROM Inventory;", transaction: tx);
        c.Execute("INSERT INTO CharacterAttributes (Key, Value) VALUES (@Key, @Value)", s.Attributes.Select(kv => new { kv.Key, kv.Value }), tx);
        c.Execute("INSERT INTO CharacterSkills (Key, Ranks) VALUES (@Key, @Value)", s.Skills.Select(kv => new { kv.Key, kv.Value }), tx);
        c.Execute("INSERT INTO Inventory (Id, ItemKey, Level, Quantity, Equipped) VALUES (@Id, @ItemKey, @Level, @Quantity, @Equipped)", s.Inventory, tx);
        if (s.DirtyTiles.Count > 0)
            c.Execute("INSERT OR REPLACE INTO Tiles (X, Y, State) VALUES (@X, @Y, @State)",
                s.DirtyTiles.Select(t => new { t.X, t.Y, State = (int)s.TileState(t.X, t.Y) }), tx);
        if (s.NewLore.Count > 0)
            c.Execute("INSERT OR IGNORE INTO FoundLore (LoreId) VALUES (@Id)", s.NewLore.Select(id => new { Id = id }), tx);
        if (s.NewLog.Count > 0)
        {
            c.Execute("INSERT INTO Log (Turn, Kind, Text) VALUES (@Turn, @Kind, @Text)", s.NewLog, tx);
            c.Execute("DELETE FROM Log WHERE Id <= (SELECT MAX(Id) - 200 FROM Log)", transaction: tx);
        }
        tx.Commit();
        s.DirtyTiles.Clear();
        s.NewLore.Clear();
        s.NewLog.Clear();
    }
}
