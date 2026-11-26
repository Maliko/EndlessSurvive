using System.Xml.Linq;

namespace EndlessSurvive.Services.Admin;

public enum Severity { Error, Warning }

public sealed record Issue(Severity Severity, string Table, string? Key, string Message);

/// <summary>Prueft die geladenen Inhalte auf Fehler, die das Spiel stoeren wuerden.</summary>
public sealed class ContentValidator(ContentStore c)
{
    // Schluessel, die der Code direkt verwendet
    private static readonly string[] CodeAttributes = ["str", "end", "agi"];
    private static readonly string[] CodeSkills = ["melee", "ranged", "healing", "stealth", "perception"];

    public IReadOnlyList<Issue> Run()
    {
        var list = new List<Issue>();
        void Err(string t, string? k, string m) => list.Add(new Issue(Severity.Error, t, k, m));
        void Warn(string t, string? k, string m) => list.Add(new Issue(Severity.Warning, t, k, m));

        var biomeKeys = c.Biomes.Select(b => b.Key).ToHashSet();
        void CheckBiomes(string table, string key, string list)
        {
            if (string.IsNullOrWhiteSpace(list)) { Err(table, key, "Biomes ist leer (für überall: *)"); return; }
            if (list.Trim() == "*") return;
            foreach (var b in list.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                if (!biomeKeys.Contains(b)) Err(table, key, $"Unbekanntes Biom „{b}“ in Biomes");
        }
        void CheckSvg(string table, string key, string col, string? svg)
        {
            if (string.IsNullOrWhiteSpace(svg)) return;
            try { XElement.Parse($"<svg xmlns=\"http://www.w3.org/2000/svg\">{svg}</svg>"); }
            catch (Exception ex) { Err(table, key, $"{col}: ungültiges SVG ({ex.Message.Split('.')[0]})"); }
        }

        // ----- Vom Code benutzte Schluessel -----
        foreach (var a in CodeAttributes)
            if (c.Attribute(a) is null) Err("Attributes", a, $"Attribut „{a}“ fehlt – wird vom Code benutzt");
        foreach (var s in CodeSkills)
            if (c.Skill(s) is null) Err("Skills", s, $"Fertigkeit „{s}“ fehlt – wird vom Code benutzt");
        foreach (var sk in c.Skills)
            if (c.Attribute(sk.AttributeKey) is null) Err("Skills", sk.Key, $"Unbekanntes Leitattribut „{sk.AttributeKey}“");

        // ----- Settings -----
        var start = c.Str("StartBiome", "bunker");
        if (c.Biomes.All(b => b.Key != start)) Err("Settings", "StartBiome", $"StartBiome „{start}“ existiert nicht");
        foreach (var part in c.Str("StartItems").Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var p = part.Split(':');
            if (!c.Items.ContainsKey(p[0])) Err("Settings", "StartItems", $"Startgegenstand „{p[0]}“ existiert nicht");
            if (p.Length > 1 && !int.TryParse(p[1], out _)) Err("Settings", "StartItems", $"„{part}“: Anzahl ist keine Zahl");
        }
        foreach (var (k, v) in c.Settings)
            if (k != "StartBiome" && k != "StartItems" && !double.TryParse(v, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out _))
                Warn("Settings", k, $"Wert „{v}“ ist keine Zahl (Punkt als Dezimaltrenner)");

        // ----- Biome -----
        if (!c.Biomes.Any(b => b.Generated && b.Passable)) Err("Biomes", null, "Kein begehbares, generiertes Biom vorhanden");
        foreach (var b in c.Biomes)
        {
            if ((b.HeightMin ?? 0) > (b.HeightMax ?? 1) || (b.MoistMin ?? 0) > (b.MoistMax ?? 1))
                Err("Biomes", b.Key, "Bereich: Min ist größer als Max");
            if (b.EventChance is < 0 or > 1 || b.EncounterChance is < 0 or > 1)
                Err("Biomes", b.Key, "EventChance und EncounterChance müssen zwischen 0 und 1 liegen");
            CheckSvg("Biomes", b.Key, "Glyph", b.Glyph);
        }

        // ----- Gegenstaende -----
        foreach (var i in c.Items.Values)
        {
            if (!EffectCatalog.Categories.Contains(i.Category)) Err("Items", i.Key, $"Unbekannte Kategorie „{i.Category}“");
            if (i.Category is "weapon" or "armor" && string.IsNullOrEmpty(i.Slot)) Err("Items", i.Key, "Waffen und Rüstung brauchen einen Slot");
            if (!string.IsNullOrEmpty(i.Slot) && !EffectCatalog.Slots.Contains(i.Slot)) Err("Items", i.Key, $"Unbekannter Slot „{i.Slot}“");
            if (i.Category == "weapon" && string.IsNullOrEmpty(i.SkillKey)) Warn("Items", i.Key, "Waffe ohne SkillKey – Nahkampf wird benutzt");
            if (i.Category == "weapon" && (i.DamageMax < i.DamageMin || i.DamageMax <= 0)) Err("Items", i.Key, "Schaden: Max muss > 0 und ≥ Min sein");
            if (i.Category == "consumable" && (i.HealMax < i.HealMin || i.HealMax <= 0)) Err("Items", i.Key, "Heilung: Max muss > 0 und ≥ Min sein");
            if (!string.IsNullOrEmpty(i.AmmoKey) && (!c.Items.TryGetValue(i.AmmoKey, out var ammo) || ammo.Category != "ammo"))
                Err("Items", i.Key, $"AmmoKey „{i.AmmoKey}“ ist keine Munition");
            if (i.MaxDanger is not null && i.MaxDanger < i.MinDanger) Err("Items", i.Key, "MaxDanger ist kleiner als MinDanger");
            if (i.Value <= 0) Warn("Items", i.Key, "Value ist 0 – nicht handelbar");
            CheckBiomes("Items", i.Key, i.Biomes);
        }

        // ----- Gegner -----
        if (!c.Enemies.Values.Any(e => e.MinDanger == 0 && e.Weight > 0)) Err("Enemies", null, "Kein Gegner für Gefahrenstufe 0 – combat:* schlägt am Anfang fehl");
        foreach (var e in c.Enemies.Values)
        {
            if (e.Hp <= 0) Err("Enemies", e.Key, "Hp muss größer als 0 sein");
            if (e.DamageMax < e.DamageMin) Err("Enemies", e.Key, "DamageMax ist kleiner als DamageMin");
            if (e.MaxDanger is not null && e.MaxDanger < e.MinDanger) Err("Enemies", e.Key, "MaxDanger ist kleiner als MinDanger");
            CheckBiomes("Enemies", e.Key, e.Biomes);
            CheckSvg("Enemies", e.Key, "Icon", e.Icon);
        }

        // ----- Ereignisse -----
        foreach (var ev in c.Events.Values)
        {
            if (ev.Kind is not ("poi" or "encounter")) Err("Events", ev.Key, $"Kind muss poi oder encounter sein, nicht „{ev.Kind}“");
            if (ev.Options.Count == 0) Err("Events", ev.Key, "Ereignis hat keine Optionen – der Dialog ließe sich nicht schließen");
            else if (ev.Options.All(o => !string.IsNullOrEmpty(o.RequiresItem))) Err("Events", ev.Key, "Alle Optionen benötigen einen Gegenstand – ohne ihn steckt man fest");
            if (ev.Options.Count > 9) Warn("Events", ev.Key, "Mehr als 9 Optionen – nicht alle per Taste wählbar");
            if (ev.MaxDanger is not null && ev.MaxDanger < ev.MinDanger) Err("Events", ev.Key, "MaxDanger ist kleiner als MinDanger");
            CheckBiomes("Events", ev.Key, ev.Biomes);
            foreach (var o in ev.Options)
            {
                var label = $"Option „{o.Label}“";
                if (!string.IsNullOrEmpty(o.SkillKey) && c.Skill(o.SkillKey) is null) Err("EventOptions", o.Id.ToString(), $"{label}: unbekannte Fertigkeit „{o.SkillKey}“");
                if (!string.IsNullOrEmpty(o.RequiresItem) && !c.Items.ContainsKey(o.RequiresItem)) Err("EventOptions", o.Id.ToString(), $"{label}: RequiresItem „{o.RequiresItem}“ existiert nicht");
                foreach (var m in EffectCatalog.Validate(o.SuccessEffects, c)) Err("EventOptions", o.Id.ToString(), $"{label}, Erfolg: {m}");
                foreach (var m in EffectCatalog.Validate(o.FailEffects, c)) Err("EventOptions", o.Id.ToString(), $"{label}, Fehlschlag: {m}");
                if (!string.IsNullOrEmpty(o.SkillKey) && string.IsNullOrEmpty(o.FailText) && string.IsNullOrEmpty(o.FailEffects))
                    Warn("EventOptions", o.Id.ToString(), $"{label}: Probe ohne Fehlschlag-Text und -Effekte");
            }
        }
        foreach (var kind in new[] { "poi", "encounter" })
            if (!c.Events.Values.Any(e => e.Kind == kind && e.MinDanger == 0))
                Warn("Events", null, $"Kein Ereignis der Art {kind} für Gefahrenstufe 0");

        // ----- Haendler -----
        foreach (var t in c.Traders.Values)
        {
            if (t.StockMax < t.StockMin) Err("Traders", t.Key, "StockMax ist kleiner als StockMin");
            if (t.PayFactor <= 0 || t.PriceFactor <= 0) Err("Traders", t.Key, "PayFactor und PriceFactor müssen größer als 0 sein");
            if (t.Categories.Trim() != "*")
                foreach (var cat in t.Categories.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                    if (!EffectCatalog.Categories.Contains(cat) && !EffectCatalog.Slots.Contains(cat))
                        Err("Traders", t.Key, $"Unbekannte Kategorie „{cat}“");
        }

        // ----- Lore -----
        foreach (var l in c.Lore)
            if (string.IsNullOrWhiteSpace(l.Text)) Warn("Lore", l.Id.ToString(), $"Infofragment „{l.Title}“ hat keinen Text");

        return list;
    }
}
