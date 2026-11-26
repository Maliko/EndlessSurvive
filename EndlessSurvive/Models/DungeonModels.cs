namespace EndlessSurvive.Models;

// Abbild der Ruinen-Tabellen in content.db.

public sealed class DungeonTileDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string Layer { get; set; } = "terrain";
    public string Svg { get; set; } = "";
    public bool Passable { get; set; }
    public int SortOrder { get; set; }
}

public sealed class DungeonDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Biomes { get; set; } = "*";
    public int MinDanger { get; set; }
    public int? MaxDanger { get; set; }
    public int Weight { get; set; }
    public string Marker { get; set; } = "▼";
    public string Color { get; set; } = "#c0503a";

    public List<DungeonFloorDef> Floors { get; } = new();

    /// <summary>Startpunkt: erster Eingang auf dem ersten Stockwerk, das einen hat.</summary>
    public DungeonObjectDef? Entrance =>
        Floors.OrderBy(f => f.SortOrder).ThenBy(f => f.Id)
            .SelectMany(f => f.Objects.Where(o => o.Kind == "entrance")).FirstOrDefault();
}

public sealed class DungeonFloorDef
{
    public long Id { get; set; }
    public string DungeonKey { get; set; } = "";
    public string Name { get; set; } = "";
    public int SortOrder { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
    public int DangerOffset { get; set; }
    public string Tiles { get; set; } = "";

    public List<DungeonObjectDef> Objects { get; } = new();

    private string[][]? _grid;

    /// <summary>Kachel-Key an Position (oder "void" ausserhalb).</summary>
    public string TileAt(int x, int y)
    {
        _grid ??= ParseGrid(Tiles, Width, Height);
        return x < 0 || y < 0 || x >= Width || y >= Height ? "void" : _grid[y][x];
    }

    public DungeonObjectDef? ObjectAt(int x, int y) => Objects.FirstOrDefault(o => o.X == x && o.Y == y);

    /// <summary>Zerlegt die Kartendaten (Zeilen durch \n, Zellen durch Komma) und fuellt Luecken mit "void".</summary>
    public static string[][] ParseGrid(string tiles, int width, int height)
    {
        var rows = (tiles ?? "").Replace("\r", "").Split('\n');
        var grid = new string[height][];
        for (int y = 0; y < height; y++)
        {
            var cells = y < rows.Length ? rows[y].Split(',') : [];
            grid[y] = new string[width];
            for (int x = 0; x < width; x++)
                grid[y][x] = x < cells.Length && cells[x].Trim() != "" ? cells[x].Trim() : "void";
        }
        return grid;
    }

    public static string SerializeGrid(string[][] grid) => string.Join("\n", grid.Select(r => string.Join(",", r)));
}

public sealed class DungeonObjectDef
{
    public long Id { get; set; }
    public long FloorId { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    /// <summary>entrance, exit, transition, container, door, enemy, event, trigger</summary>
    public string Kind { get; set; } = "";
    public string? Icon { get; set; }
    public string? Label { get; set; }
    public string? Description { get; set; }
    public string? EnemyKey { get; set; }
    public string? EventKey { get; set; }
    public string? SkillKey { get; set; }
    public int Difficulty { get; set; }
    public string? Effects { get; set; }
    public string? FailEffects { get; set; }
    public long? TargetFloorId { get; set; }
    public int? TargetX { get; set; }
    public int? TargetY { get; set; }

    /// <summary>Objekte, die den Weg versperren, bis sie erledigt sind.</summary>
    public bool Blocks => Kind is "container" or "door" or "enemy" or "event";
}

public sealed class DungeonStoryDef
{
    public string Key { get; set; } = "";
    public string? DungeonKey { get; set; }
    public string Title { get; set; } = "";
    public string Text { get; set; } = "";
    public int SortOrder { get; set; }
}

public static class DungeonKinds
{
    public static readonly (string Key, string Name, string? DefaultIcon)[] All =
    [
        ("entrance", "Eingang", null),
        ("exit", "Ausgang", "obj_exit"),
        ("transition", "Übergang", "obj_stairs_down"),
        ("container", "Behälter", "obj_chest"),
        ("door", "Tür", "obj_door"),
        ("enemy", "Gegner", null),
        ("event", "Ereignis", "obj_terminal"),
        ("trigger", "Auslöser", null),
    ];

    public static string Name(string kind) => All.FirstOrDefault(k => k.Key == kind).Name ?? kind;
}
