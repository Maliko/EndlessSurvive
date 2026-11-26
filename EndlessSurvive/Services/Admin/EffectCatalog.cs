namespace EndlessSurvive.Services.Admin;

public sealed record EffectInfo(string Name, string Syntax, string Description);

/// <summary>
/// Beschreibung und Pruefung der Effekt-Sprache in EventOptions.
/// Wer in GameService.ApplyEffect einen neuen Effekt einbaut, traegt ihn hier ein.
/// </summary>
public static class EffectCatalog
{
    public static readonly IReadOnlyList<EffectInfo> All =
    [
        new("xp", "xp:N", "Erfahrung, skaliert mit der Gefahrenstufe"),
        new("loot", "loot:N", "N zufällige Gegenstände"),
        new("lootcat", "lootcat:KAT:N", "N Gegenstände einer Kategorie oder eines Slots"),
        new("item", "item:KEY:N", "bestimmter Gegenstand"),
        new("take", "take:KEY:N", "Gegenstand abgeben"),
        new("heal", "heal:N · heal:full · heal:pct:N", "Lebenspunkte heilen"),
        new("damage", "damage:A-B", "Schaden, skaliert mit der Gefahrenstufe"),
        new("combat", "combat:KEY · combat:*", "Kampf gegen Gegner KEY oder passenden Zufallsgegner"),
        new("trade", "trade:KEY · trade:*", "Tauschhandel mit Händler KEY"),
        new("lore", "lore", "zufälliges neues Infofragment"),
        new("reveal", "reveal:R", "Karte im Radius R aufdecken"),
        new("persist", "persist", "Ort bleibt auf der Karte"),
    ];

    public static readonly string[] Categories = ["weapon", "armor", "consumable", "ammo"];
    public static readonly string[] Slots = ["melee", "ranged", "body", "head"];

    /// <summary>Prueft einen Effekt-String gegen die geladenen Inhalte. Liefert Fehlermeldungen.</summary>
    public static IEnumerable<string> Validate(string? effects, ContentStore c)
    {
        if (string.IsNullOrWhiteSpace(effects)) yield break;
        foreach (var raw in effects.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var p = raw.Split(':');
            var name = p[0].ToLowerInvariant();
            string? Arg(int i) => p.Length > i ? p[i] : null;
            bool IsInt(string? s) => int.TryParse(s, out _);
            switch (name)
            {
                case "xp" or "reveal":
                    if (!IsInt(Arg(1))) yield return $"„{raw}“: Zahl erwartet, z. B. {name}:10";
                    break;
                case "loot":
                    if (Arg(1) is not null && !IsInt(Arg(1))) yield return $"„{raw}“: Anzahl muss eine Zahl sein";
                    break;
                case "lootcat":
                    if (Arg(1) is not { } cat || (!Categories.Contains(cat) && !Slots.Contains(cat)))
                        yield return $"„{raw}“: unbekannte Kategorie. Erlaubt: {string.Join(", ", Categories.Concat(Slots))}";
                    if (Arg(2) is not null && !IsInt(Arg(2))) yield return $"„{raw}“: Anzahl muss eine Zahl sein";
                    break;
                case "item" or "take":
                    if (Arg(1) is not { } key || !c.Items.ContainsKey(key)) yield return $"„{raw}“: Gegenstand „{Arg(1)}“ existiert nicht";
                    if (Arg(2) is not null && !IsInt(Arg(2))) yield return $"„{raw}“: Anzahl muss eine Zahl sein";
                    break;
                case "heal":
                    if (!(Arg(1) == "full" || (Arg(1) == "pct" && IsInt(Arg(2))) || IsInt(Arg(1))))
                        yield return $"„{raw}“: erwartet heal:N, heal:full oder heal:pct:N";
                    break;
                case "damage":
                {
                    var r = Arg(1)?.Split('-') ?? [];
                    if (r.Length is < 1 or > 2 || !r.All(IsInt)) yield return $"„{raw}“: erwartet damage:A-B, z. B. damage:2-5";
                    break;
                }
                case "combat":
                    if (Arg(1) is not { } e || (e != "*" && !c.Enemies.ContainsKey(e))) yield return $"„{raw}“: Gegner „{Arg(1)}“ existiert nicht";
                    break;
                case "trade":
                    if (Arg(1) is not { } tr || (tr != "*" && !c.Traders.ContainsKey(tr))) yield return $"„{raw}“: Händler „{Arg(1)}“ existiert nicht";
                    break;
                case "lore" or "persist":
                    break;
                default:
                    yield return $"„{raw}“: unbekannter Effekt „{name}“";
                    break;
            }
        }
    }
}
