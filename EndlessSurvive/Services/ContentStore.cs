using System.Globalization;
using Dapper;
using EndlessSurvive.Models;
using Microsoft.Data.Sqlite;

namespace EndlessSurvive.Services;

/// <summary>
/// Laedt alle Inhalte aus content.db in den Speicher. Existiert die Datei nicht,
/// wird sie aus content.sql erzeugt.
/// </summary>
public sealed class ContentStore
{
    public IReadOnlyDictionary<string, string> Settings { get; private set; } = new Dictionary<string, string>();
    public IReadOnlyDictionary<string, string> Texts { get; private set; } = new Dictionary<string, string>();
    public IReadOnlyList<AttributeDef> Attributes { get; private set; } = [];
    public IReadOnlyList<SkillDef> Skills { get; private set; } = [];
    public IReadOnlyList<BiomeDef> Biomes { get; private set; } = [];
    public IReadOnlyDictionary<string, ItemDef> Items { get; private set; } = new Dictionary<string, ItemDef>();
    public IReadOnlyDictionary<string, EnemyDef> Enemies { get; private set; } = new Dictionary<string, EnemyDef>();
    public IReadOnlyDictionary<string, EventDef> Events { get; private set; } = new Dictionary<string, EventDef>();
    public IReadOnlyList<LoreDef> Lore { get; private set; } = [];
    public IReadOnlyDictionary<string, TraderDef> Traders { get; private set; } = new Dictionary<string, TraderDef>();
    public IReadOnlyDictionary<string, DungeonTileDef> DungeonTiles { get; private set; } = new Dictionary<string, DungeonTileDef>();
    public IReadOnlyDictionary<string, DungeonDef> Dungeons { get; private set; } = new Dictionary<string, DungeonDef>();
    public IReadOnlyDictionary<long, DungeonFloorDef> Floors { get; private set; } = new Dictionary<long, DungeonFloorDef>();
    public IReadOnlyDictionary<string, DungeonStoryDef> Stories { get; private set; } = new Dictionary<string, DungeonStoryDef>();

    public string DbPath { get; }

    /// <summary>Steigt bei jedem Neuladen (z. B. nach Aenderungen in der Verwaltung).</summary>
    public int Version { get; private set; }

    public ContentStore(IWebHostEnvironment env, IConfiguration config)
    {
        var dataDir = Path.Combine(env.ContentRootPath, "Data");
        DbPath = Path.Combine(dataDir, config["ContentDb"] ?? "content.db");
        if (!File.Exists(DbPath))
        {
            var sqlPath = Path.Combine(dataDir, "content.sql");
            if (!File.Exists(sqlPath))
                throw new FileNotFoundException($"Weder {DbPath} noch {sqlPath} gefunden.");
            using var c = new SqliteConnection($"Data Source={DbPath}");
            c.Open();
            c.Execute(File.ReadAllText(sqlPath));
        }
        Load();
    }

    public void Load()
    {
        using var c = new SqliteConnection($"Data Source={DbPath};Mode=ReadOnly");
        c.Open();
        Settings = c.Query<(string Key, string Value)>("SELECT Key, Value FROM Settings").ToDictionary(r => r.Key, r => r.Value);
        Texts = c.Query<(string Key, string Text)>("SELECT Key, Text FROM Texts").ToDictionary(r => r.Key, r => r.Text);
        Attributes = c.Query<AttributeDef>("SELECT * FROM Attributes ORDER BY SortOrder").ToList();
        Skills = c.Query<SkillDef>("SELECT * FROM Skills ORDER BY SortOrder").ToList();
        Biomes = c.Query<BiomeDef>("SELECT * FROM Biomes ORDER BY Priority DESC").ToList();
        Items = c.Query<ItemDef>("SELECT * FROM Items").ToDictionary(i => i.Key);
        Enemies = c.Query<EnemyDef>("SELECT * FROM Enemies").ToDictionary(e => e.Key);
        var events = c.Query<EventDef>("SELECT * FROM Events").ToDictionary(e => e.Key);
        foreach (var o in c.Query<EventOptionDef>("SELECT * FROM EventOptions ORDER BY EventKey, SortOrder, Id"))
            if (events.TryGetValue(o.EventKey, out var ev)) ev.Options.Add(o);
        Events = events;
        Lore = c.Query<LoreDef>("SELECT * FROM Lore ORDER BY MinDanger, Id").ToList();
        Traders = c.Query<TraderDef>("SELECT * FROM Traders").ToDictionary(t => t.Key);

        // Ruinen
        DungeonTiles = c.Query<DungeonTileDef>("SELECT * FROM DungeonTiles ORDER BY SortOrder, Key").ToDictionary(t => t.Key);
        var dungeons = c.Query<DungeonDef>("SELECT * FROM Dungeons").ToDictionary(d => d.Key);
        var floors = c.Query<DungeonFloorDef>("SELECT * FROM DungeonFloors ORDER BY SortOrder, Id").ToDictionary(f => f.Id);
        foreach (var o in c.Query<DungeonObjectDef>("SELECT * FROM DungeonObjects ORDER BY Id"))
            if (floors.TryGetValue(o.FloorId, out var f)) f.Objects.Add(o);
        foreach (var f in floors.Values)
            if (dungeons.TryGetValue(f.DungeonKey, out var d)) d.Floors.Add(f);
        Dungeons = dungeons;
        Floors = floors;
        Stories = c.Query<DungeonStoryDef>("SELECT * FROM DungeonStory ORDER BY SortOrder, Key").ToDictionary(s => s.Key);
        Version++;
    }

    public double Num(string key, double fallback = 0) =>
        Settings.TryGetValue(key, out var v) && double.TryParse(v, NumberStyles.Float, CultureInfo.InvariantCulture, out var d) ? d : fallback;

    public int Int(string key, int fallback = 0) => (int)Math.Round(Num(key, fallback));

    public string Str(string key, string fallback = "") => Settings.TryGetValue(key, out var v) ? v : fallback;

    public string Text(string key) => Texts.TryGetValue(key, out var v) ? v : "";

    public BiomeDef Biome(string key) => Biomes.FirstOrDefault(b => b.Key == key) ?? Biomes.Last();

    public SkillDef? Skill(string? key) => key is null ? null : Skills.FirstOrDefault(s => s.Key == key);

    public AttributeDef? Attribute(string? key) => key is null ? null : Attributes.FirstOrDefault(a => a.Key == key);
}
