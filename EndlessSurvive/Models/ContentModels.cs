namespace EndlessSurvive.Models;

// Abbild der Tabellen in content.db. Diese Klassen enthalten keine Inhalte,
// nur die Struktur. Alle Werte kommen aus der Datenbank.

public sealed class AttributeDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string Abbrev { get; set; } = "";
    public string? Description { get; set; }
    public int SortOrder { get; set; }
}

public sealed class SkillDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string AttributeKey { get; set; } = "";
    public string Category { get; set; } = "";
    public string? Description { get; set; }
    public int SortOrder { get; set; }
}

public sealed class BiomeDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public string Color { get; set; } = "#555";
    public string AccentColor { get; set; } = "#777";
    public string? Glyph { get; set; }
    public double? HeightMin { get; set; }
    public double? HeightMax { get; set; }
    public double? MoistMin { get; set; }
    public double? MoistMax { get; set; }
    public int Priority { get; set; }
    public int DangerBonus { get; set; }
    public double EventChance { get; set; }
    public double EncounterChance { get; set; }
    public bool Passable { get; set; }
    public bool Generated { get; set; }

    public bool Matches(double h, double m) =>
        Generated
        && h >= (HeightMin ?? 0) && h <= (HeightMax ?? 1)
        && m >= (MoistMin ?? 0) && m <= (MoistMax ?? 1);
}

public sealed class ItemDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public string Category { get; set; } = "";
    public string? Slot { get; set; }
    public string? SkillKey { get; set; }
    public int DamageMin { get; set; }
    public int DamageMax { get; set; }
    public int Armor { get; set; }
    public int HealMin { get; set; }
    public int HealMax { get; set; }
    public string? AmmoKey { get; set; }
    public int Rarity { get; set; }
    public int MinDanger { get; set; }
    public int? MaxDanger { get; set; }
    public string Biomes { get; set; } = "*";
    public bool Scales { get; set; }
    public string Color { get; set; } = "#ccc";

    public bool IsWeapon => Category == "weapon";
    public bool IsArmor => Category == "armor";
    public bool IsConsumable => Category == "consumable";
    public bool IsEquippable => !string.IsNullOrEmpty(Slot);
}

public sealed class EnemyDef
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public int Hp { get; set; }
    public int Attack { get; set; }
    public int Defense { get; set; }
    public int DamageMin { get; set; }
    public int DamageMax { get; set; }
    public int Armor { get; set; }
    public int Xp { get; set; }
    public int MinDanger { get; set; }
    public int? MaxDanger { get; set; }
    public string Biomes { get; set; } = "*";
    public int Weight { get; set; }
    public double LootChance { get; set; }
    public string Color { get; set; } = "#c44";
    public string? Icon { get; set; }
}

public sealed class EventDef
{
    public string Key { get; set; } = "";
    public string Title { get; set; } = "";
    public string Text { get; set; } = "";
    public string Kind { get; set; } = "poi";
    public string Biomes { get; set; } = "*";
    public int MinDanger { get; set; }
    public int? MaxDanger { get; set; }
    public int Weight { get; set; }
    public string Marker { get; set; } = "?";
    public List<EventOptionDef> Options { get; } = new();
}

public sealed class EventOptionDef
{
    public long Id { get; set; }
    public string EventKey { get; set; } = "";
    public int SortOrder { get; set; }
    public string Label { get; set; } = "";
    public string? SkillKey { get; set; }
    public int Difficulty { get; set; }
    public bool DangerScaling { get; set; }
    public string? RequiresItem { get; set; }
    public string? SuccessText { get; set; }
    public string? SuccessEffects { get; set; }
    public string? FailText { get; set; }
    public string? FailEffects { get; set; }
}

public sealed class LoreDef
{
    public long Id { get; set; }
    public string Title { get; set; } = "";
    public string Text { get; set; } = "";
    public int MinDanger { get; set; }
}

public static class BiomeListExtensions
{
    /// <summary>Prueft eine '*' oder kommagetrennte Biomliste.</summary>
    public static bool AllowsBiome(this string list, string biomeKey)
    {
        if (string.IsNullOrWhiteSpace(list) || list.Trim() == "*") return true;
        foreach (var part in list.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            if (part == biomeKey) return true;
        return false;
    }
}
