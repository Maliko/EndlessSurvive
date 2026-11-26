using EndlessSurvive.Models;

namespace EndlessSurvive.Services;

[Flags]
public enum TileFlags { None = 0, Explored = 1, Resolved = 2 }

public sealed class CharacterState
{
    public string Name { get; set; } = "";
    public long Seed { get; set; }
    public int Level { get; set; } = 1;
    public long Xp { get; set; }
    public int Hp { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int AttributePoints { get; set; }
    public int SkillPoints { get; set; }
    public long Turn { get; set; }
    public int Deaths { get; set; }
    public int Kills { get; set; }
    public int MaxDanger { get; set; }
    public string CreatedAt { get; set; } = "";
}

public sealed class InventoryItem
{
    public long Id { get; set; }
    public string ItemKey { get; set; } = "";
    public int Level { get; set; }
    public int Quantity { get; set; } = 1;
    public bool Equipped { get; set; }
}

public sealed class LogEntry
{
    public long Turn { get; set; }
    public string Kind { get; set; } = "info";
    public string Text { get; set; } = "";
}

public sealed class GameState
{
    public CharacterState Char { get; set; } = new();
    public Dictionary<string, int> Attributes { get; } = new();
    public Dictionary<string, int> Skills { get; } = new();
    public List<InventoryItem> Inventory { get; } = new();
    public Dictionary<(int X, int Y), TileFlags> Tiles { get; } = new();
    public HashSet<long> FoundLore { get; } = new();
    public List<LogEntry> Log { get; } = new();

    // Aenderungsverfolgung fuer inkrementelles Speichern
    public HashSet<(int X, int Y)> DirtyTiles { get; } = new();
    public HashSet<long> NewLore { get; } = new();
    public List<LogEntry> NewLog { get; } = new();

    public TileFlags TileState(int x, int y) => Tiles.TryGetValue((x, y), out var f) ? f : TileFlags.None;

    public void SetTile(int x, int y, TileFlags add)
    {
        var cur = TileState(x, y);
        if ((cur | add) == cur) return;
        Tiles[(x, y)] = cur | add;
        DirtyTiles.Add((x, y));
    }
}

// ----- Laufzeit-Zustaende (Dialoge) -----

public sealed class RollResult
{
    public string SkillName { get; init; } = "";
    public int Chance { get; init; }
    public int Roll { get; init; }
    public bool Success => Roll <= Chance;
    public bool Critical { get; init; }
}

public sealed class OptionView
{
    public required EventOptionDef Def { get; init; }
    public int? Chance { get; init; }
    public string? SkillName { get; init; }
    public bool Available { get; init; } = true;
    public string? Hint { get; init; }
}

public sealed class ActiveEvent
{
    public required EventDef Def { get; init; }
    public required TileInfo Tile { get; init; }
    public bool IsPoi { get; init; }
    public List<OptionView> Options { get; } = new();
    // nach der Wahl:
    public RollResult? Roll { get; set; }
    public string? ResultText { get; set; }
    public List<string> ResultLines { get; } = new();
    public bool Finished { get; set; }
}

public sealed class Enemy
{
    public required EnemyDef Def { get; init; }
    public int Level { get; init; }
    public int MaxHp { get; init; }
    public int Hp { get; set; }
    public int Attack { get; init; }
    public int Defense { get; init; }
    public int DamageMin { get; init; }
    public int DamageMax { get; init; }
    public int Armor { get; init; }
    public int Xp { get; init; }
}

public sealed class CombatLine
{
    public string Text { get; init; } = "";
    public string Kind { get; init; } = "info"; // player, enemy, info, good, bad
}

public sealed class Combat
{
    public required Enemy Enemy { get; init; }
    public required TileInfo Tile { get; init; }
    public List<CombatLine> Lines { get; } = new();
    public bool Over { get; set; }
    public bool Won { get; set; }
    public bool Fled { get; set; }
    public List<string> RewardLines { get; } = new();
}

/// <summary>Laufender Tauschhandel. Das Sortiment wird nicht gespeichert.</summary>
public sealed class Trade
{
    public required TraderDef Def { get; init; }
    public required TileInfo Tile { get; init; }
    /// <summary>Ware des Haendlers (Id nur innerhalb des Handels eindeutig).</summary>
    public List<InventoryItem> Stock { get; } = new();
    /// <summary>Angebot des Spielers: Inventar-Id -> Anzahl.</summary>
    public Dictionary<long, int> Offer { get; } = new();
    /// <summary>Forderung des Spielers: Stock-Id -> Anzahl.</summary>
    public Dictionary<long, int> Request { get; } = new();
    public List<string> History { get; } = new();
}

public sealed class Notice
{
    public string Title { get; init; } = "";
    public string Text { get; init; } = "";
    public string Kind { get; init; } = "info";
}
