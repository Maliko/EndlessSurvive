using System.Globalization;
using EndlessSurvive.Models;

namespace EndlessSurvive.Services;

/// <summary>
/// Die Spielregeln. Ein Exemplar pro Browser-Verbindung (scoped).
/// </summary>
public sealed class GameService
{
    private readonly ContentStore _c;
    private readonly SaveStore _store;
    private readonly Dice _dice = new();
    private readonly Queue<Notice> _notices = new();

    // Effekt-Warteschlange (fuer Ereignisse, die Kaempfe ausloesen und danach weiterlaufen)
    private readonly Queue<string> _effects = new();
    private bool _persist;

    public GameService(ContentStore content, SaveStore store)
    {
        _c = content;
        _store = store;
    }

    public ContentStore Content => _c;
    public GameState? State { get; private set; }
    public WorldGen? World { get; private set; }
    public ActiveEvent? Event { get; private set; }
    public Combat? Combat { get; private set; }
    public Trade? Trade { get; private set; }
    public Notice? Notice => Event is null && Combat is null && Trade is null && _notices.Count > 0 ? _notices.Peek() : null;
    public bool Busy => Event is not null || Combat is not null || Trade is not null || _notices.Count > 0;
    public bool Loaded => State is not null && World is not null;

    // =================================================================
    //  Spielstand
    // =================================================================

    public bool HasSave() => _store.Exists();
    public CharacterState? PeekSave() => _store.PeekCharacter();

    public bool Load()
    {
        if (Loaded) return true;
        var s = _store.Load();
        if (s is null) return false;
        State = s;
        World = new WorldGen(_c, s.Char.Seed);
        return true;
    }

    public void NewGame(string name, Dictionary<string, int> attributes, Dictionary<string, int> skills)
    {
        _store.Delete();
        Event = null; Combat = null; Trade = null; _notices.Clear(); _effects.Clear();
        var s = new GameState();
        s.Char.Name = string.IsNullOrWhiteSpace(name) ? "Namenlos" : name.Trim();
        s.Char.Seed = Random.Shared.NextInt64(1, long.MaxValue);
        s.Char.CreatedAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture);
        foreach (var a in _c.Attributes) s.Attributes[a.Key] = attributes.GetValueOrDefault(a.Key, _c.Int("AttributeStart", 5));
        foreach (var sk in _c.Skills) s.Skills[sk.Key] = skills.GetValueOrDefault(sk.Key, 0);
        State = s;
        World = new WorldGen(_c, s.Char.Seed);

        foreach (var part in _c.Str("StartItems").Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var p = part.Split(':');
            if (_c.Items.ContainsKey(p[0])) AddItem(p[0], 0, p.Length > 1 ? int.Parse(p[1]) : 1);
        }
        s.Char.Hp = MaxHp;
        Explore(0, 0, SightRadius);
        _notices.Enqueue(new Notice { Title = "Erwachen", Text = _c.Text("intro"), Kind = "intro" });
        AddLog("Du erwachst im Bunker.", "story");
        Persist();
    }

    /// <summary>Wird nach jeder Zustandsaenderung ausgeloest (UI aktualisiert sich).</summary>
    public event Action? Changed;

    private void Persist()
    {
        if (State is not null) _store.Save(State);
        Changed?.Invoke();
    }

    // =================================================================
    //  Charakterwerte
    // =================================================================

    public int Attr(string key) => State?.Attributes.GetValueOrDefault(key) ?? 0;
    public int Ranks(string key) => State?.Skills.GetValueOrDefault(key) ?? 0;

    public int SkillValue(string key)
    {
        var sk = _c.Skill(key);
        if (sk is null) return 0;
        return _c.Int("SkillBase", 10) + Attr(sk.AttributeKey) * _c.Int("SkillPerAttribute", 3) + Ranks(key) * _c.Int("SkillPerRank", 4);
    }

    public int MaxHp => State is null ? 1 :
        _c.Int("HpBase", 20) + Attr("end") * _c.Int("HpPerEndurance", 4) + (State.Char.Level - 1) * _c.Int("HpPerLevel", 3);

    public long XpForNext(int level) => (long)Math.Round(_c.Num("XpBase", 100) * Math.Pow(level, _c.Num("XpExponent", 1.6)));

    public int Dodge => Attr("agi") * _c.Int("DodgePerAgility", 2);

    public int ArmorTotal => State?.Inventory.Where(i => i.Equipped).Sum(ItemArmor) ?? 0;

    public int SightRadius => _c.Int("SightRadius", 2) + (SkillValue("perception") >= 60 ? 1 : 0);

    public int Clamp(int chance) => Math.Clamp(chance, _c.Int("ChanceMin", 5), _c.Int("ChanceMax", 95));

    public TileInfo CurrentTile => World!.Tile(State!.Char.X, State.Char.Y);

    // =================================================================
    //  Gegenstaende
    // =================================================================

    public ItemDef Def(InventoryItem i) => _c.Items[i.ItemKey];

    public string ItemName(InventoryItem i) => i.Level > 0 ? $"{Def(i).Name} +{i.Level}" : Def(i).Name;

    public (int Min, int Max) ItemDamage(InventoryItem i)
    {
        var d = Def(i);
        double f = 1 + i.Level * _c.Num("ItemDamagePerLevel", 0.15);
        return ((int)Math.Round(d.DamageMin * f), (int)Math.Round(d.DamageMax * f));
    }

    public int ItemArmor(InventoryItem i)
    {
        var d = Def(i);
        if (d.Armor <= 0) return 0;
        return d.Armor + (int)Math.Floor(i.Level * _c.Num("ItemArmorPerLevel", 0.5));
    }

    public InventoryItem? Equipped(string slot) =>
        State?.Inventory.FirstOrDefault(i => i.Equipped && Def(i).Slot == slot);

    public int Count(string key) => State?.Inventory.Where(i => i.ItemKey == key).Sum(i => i.Quantity) ?? 0;

    private InventoryItem AddItem(string key, int level, int qty)
    {
        var s = State!;
        var def = _c.Items[key];
        if (!def.IsEquippable)
        {
            var stack = s.Inventory.FirstOrDefault(i => i.ItemKey == key && i.Level == level);
            if (stack is not null) { stack.Quantity += qty; return stack; }
            var n = new InventoryItem { Id = NextId(), ItemKey = key, Level = level, Quantity = qty };
            s.Inventory.Add(n);
            return n;
        }
        InventoryItem last = null!;
        for (int k = 0; k < Math.Max(1, qty); k++)
        {
            last = new InventoryItem { Id = NextId(), ItemKey = key, Level = level, Quantity = 1 };
            s.Inventory.Add(last);
            if (Equipped(def.Slot!) is null) last.Equipped = true;
        }
        return last;
    }

    private long NextId() => State!.Inventory.Count == 0 ? 1 : State.Inventory.Max(i => i.Id) + 1;

    private bool RemoveItem(string key, int qty)
    {
        var s = State!;
        if (Count(key) < qty) return false;
        foreach (var i in s.Inventory.Where(i => i.ItemKey == key).OrderBy(i => i.Equipped).ToList())
        {
            int take = Math.Min(qty, i.Quantity);
            i.Quantity -= take;
            qty -= take;
            if (i.Quantity <= 0) s.Inventory.Remove(i);
            if (qty <= 0) break;
        }
        return true;
    }

    public void Equip(InventoryItem item)
    {
        if (State is null || Combat is not null || Trade is not null) return;
        var d = Def(item);
        if (!d.IsEquippable) return;
        foreach (var other in State.Inventory.Where(i => i.Equipped && Def(i).Slot == d.Slot)) other.Equipped = false;
        item.Equipped = true;
        AddLog($"Ausgeruestet: {ItemName(item)}.");
        Persist();
    }

    public void Unequip(InventoryItem item)
    {
        if (State is null || Combat is not null || Trade is not null) return;
        item.Equipped = false;
        Persist();
    }

    public void Drop(InventoryItem item)
    {
        if (State is null || Combat is not null || Trade is not null) return;
        State.Inventory.Remove(item);
        AddLog($"Weggeworfen: {ItemName(item)}{(item.Quantity > 1 ? $" ({item.Quantity})" : "")}.");
        Persist();
    }

    /// <summary>Ist ein nicht angelegter Gegenstand hoechstens so gut wie das Angelegte im selben Platz?</summary>
    public bool IsObsolete(InventoryItem item)
    {
        var d = Def(item);
        if (item.Equipped || !d.IsEquippable) return false;
        var eq = Equipped(d.Slot!);
        if (eq is null) return false;
        if (d.IsWeapon)
        {
            var (a1, b1) = ItemDamage(item);
            var (a2, b2) = ItemDamage(eq);
            return a1 + b1 <= a2 + b2;
        }
        return ItemArmor(item) <= ItemArmor(eq);
    }

    public int ObsoleteCount => State?.Inventory.Count(IsObsolete) ?? 0;

    /// <summary>Alle Ausruestung wegwerfen, die nicht besser als die angelegte ist.</summary>
    public void DropObsolete()
    {
        if (State is null || Combat is not null || Trade is not null) return;
        int n = State.Inventory.RemoveAll(IsObsolete);
        if (n > 0) AddLog($"{n} schwaechere Ausruestungsteile aussortiert.");
        Persist();
    }

    /// <summary>Heilgegenstand verwenden. Heilung-Probe verbessert die Wirkung.</summary>
    private (int Heal, RollResult Roll) ApplyHealItem(InventoryItem item)
    {
        var d = Def(item);
        var roll = Roll("healing", 0);
        int heal = roll.Success ? d.HealMax + Ranks("healing") : _dice.Range(d.HealMin, d.HealMax);
        heal = Math.Min(heal, MaxHp - State!.Char.Hp);
        State.Char.Hp += heal;
        item.Quantity--;
        if (item.Quantity <= 0) State.Inventory.Remove(item);
        return (heal, roll);
    }

    public void UseItem(InventoryItem item)
    {
        if (State is null) return;
        if (Combat is not null) { CombatUseItem(item); return; }
        if (Busy || !Def(item).IsConsumable) return;
        if (State.Char.Hp >= MaxHp) { AddLog("Du bist bereits unverletzt."); Persist(); return; }
        var name = ItemName(item);
        var (heal, roll) = ApplyHealItem(item);
        AddLog($"{name} benutzt ({RollText(roll)}): +{heal} LP.", "good");
        Persist();
    }

    // =================================================================
    //  Proben
    // =================================================================

    public int CheckChance(EventOptionDef o, int danger)
    {
        if (string.IsNullOrEmpty(o.SkillKey)) return 100;
        int penalty = o.DangerScaling ? danger * _c.Int("DangerCheckPenalty", 2) : 0;
        return Clamp(SkillValue(o.SkillKey) + o.Difficulty - penalty);
    }

    private RollResult Roll(string skillKey, int modifier)
    {
        int chance = Clamp(SkillValue(skillKey) + modifier);
        return RollRaw(_c.Skill(skillKey)?.Name ?? skillKey, chance);
    }

    private RollResult RollRaw(string name, int chance)
    {
        int roll = _dice.D100();
        return new RollResult { SkillName = name, Chance = chance, Roll = roll, Critical = roll <= Math.Max(1, chance / 10) };
    }

    public static string RollText(RollResult r) =>
        $"{r.SkillName} {r.Chance}% – Wurf {r.Roll}: {(r.Success ? (r.Critical ? "kritischer Erfolg" : "Erfolg") : "Fehlschlag")}";

    // =================================================================
    //  Bewegung und Erkundung
    // =================================================================

    public bool CanEnter(int x, int y) => World!.Tile(x, y).Biome.Passable;

    public void Move(int dx, int dy)
    {
        if (!Loaded || Busy) return;
        var s = State!;
        int nx = s.Char.X + dx, ny = s.Char.Y + dy;
        var tile = World!.Tile(nx, ny);
        if (!tile.Biome.Passable)
        {
            AddLog($"{tile.Biome.Name}: Hier kommst du nicht weiter.", "warn");
            Persist();
            return;
        }
        s.Char.X = nx; s.Char.Y = ny; s.Char.Turn++;
        if (tile.Danger > s.Char.MaxDanger)
        {
            s.Char.MaxDanger = tile.Danger;
            AddLog($"Du betrittst gefaehrlicheres Gebiet (Gefahrenstufe {tile.Danger}).", "warn");
        }
        Explore(nx, ny, SightRadius);

        if (nx == 0 && ny == 0)
            AddLog(_c.Text("bunker"), "story");
        else if (tile.Poi is not null && !s.TileState(nx, ny).HasFlag(TileFlags.Resolved))
            OpenEvent(tile.Poi, tile, isPoi: true);
        else if (World.Distance(nx, ny) > _c.Int("SafeRadius", 2) && _dice.Chance(tile.Biome.EncounterChance))
            TriggerEncounter(tile);
        Persist();
    }

    /// <summary>Einen Schritt in Richtung eines angeklickten Feldes.</summary>
    public void StepToward(int tx, int ty)
    {
        if (!Loaded) return;
        int dx = Math.Sign(tx - State!.Char.X), dy = Math.Sign(ty - State.Char.Y);
        if (dx == 0 && dy == 0)
        {
            // Klick auf eigenes Feld: offenen Ort erneut ansehen
            var t = CurrentTile;
            if (!Busy && t.Poi is not null && !State.TileState(t.X, t.Y).HasFlag(TileFlags.Resolved))
                OpenEvent(t.Poi, t, isPoi: true);
            return;
        }
        int adx = Math.Abs(tx - State.Char.X), ady = Math.Abs(ty - State.Char.Y);
        // bevorzugt die laengere Achse, weicht bei Hindernis auf die andere aus
        if (adx >= ady)
        {
            if (CanEnter(State.Char.X + dx, State.Char.Y) || dy == 0) Move(dx, 0); else Move(0, dy);
        }
        else
        {
            if (CanEnter(State.Char.X, State.Char.Y + dy) || dx == 0) Move(0, dy); else Move(dx, 0);
        }
    }

    private void Explore(int cx, int cy, int r)
    {
        for (int y = cy - r; y <= cy + r; y++)
        for (int x = cx - r; x <= cx + r; x++)
            if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r + r)
                State!.SetTile(x, y, TileFlags.Explored);
    }

    public void Rest()
    {
        if (!Loaded || Busy) return;
        var s = State!;
        var tile = CurrentTile;
        s.Char.Turn += 4;
        if (tile.X == 0 && tile.Y == 0)
        {
            s.Char.Hp = MaxHp;
            AddLog("Du schlaefst in deiner Kapsel. Volle Genesung.", "good");
            Persist();
            return;
        }
        var roll = Roll("healing", 0);
        int pct = roll.Success ? 35 : 15;
        int heal = Math.Min(MaxHp - s.Char.Hp, Math.Max(1, MaxHp * pct / 100));
        s.Char.Hp += heal;
        AddLog($"Du rastest ({RollText(roll)}): +{heal} LP.", "good");
        if (World!.Distance(tile.X, tile.Y) > _c.Int("SafeRadius", 2)
            && _dice.Chance(tile.Biome.EncounterChance * _c.Num("RestEncounterFactor", 2.5)))
        {
            AddLog("Deine Rast wird jaeh unterbrochen!", "bad");
            TriggerEncounter(tile);
        }
        Persist();
    }

    // =================================================================
    //  Ereignisse
    // =================================================================

    private void TriggerEncounter(TileInfo tile)
    {
        var candidates = _c.Events.Values
            .Where(e => e.Kind == "encounter" && e.Biomes.AllowsBiome(tile.Biome.Key)
                        && e.MinDanger <= tile.Danger && (e.MaxDanger is null || e.MaxDanger >= tile.Danger))
            .ToList();
        var ev = _dice.Weighted(candidates, e => e.Weight);
        if (ev is not null) OpenEvent(ev, tile, isPoi: false);
    }

    private void OpenEvent(EventDef def, TileInfo tile, bool isPoi)
    {
        var ae = new ActiveEvent { Def = def, Tile = tile, IsPoi = isPoi };
        foreach (var o in def.Options)
        {
            bool available = string.IsNullOrEmpty(o.RequiresItem) || Count(o.RequiresItem) > 0;
            string? hint = null;
            if (!string.IsNullOrEmpty(o.RequiresItem) && _c.Items.TryGetValue(o.RequiresItem, out var req))
                hint = $"Benoetigt: {req.Name}";
            ae.Options.Add(new OptionView
            {
                Def = o,
                Available = available,
                Hint = hint,
                Chance = string.IsNullOrEmpty(o.SkillKey) ? null : CheckChance(o, tile.Danger),
                SkillName = _c.Skill(o.SkillKey)?.Name,
            });
        }
        Event = ae;
        AddLog($"{def.Title}", "event");
    }

    public void ChooseOption(OptionView option)
    {
        var ev = Event;
        if (ev is null || ev.Roll is not null || ev.ResultText is not null || !option.Available || Combat is not null || Trade is not null) return;
        var o = option.Def;
        bool success = true;
        if (!string.IsNullOrEmpty(o.SkillKey))
        {
            var roll = RollRaw(_c.Skill(o.SkillKey)?.Name ?? o.SkillKey, CheckChance(o, ev.Tile.Danger));
            ev.Roll = roll;
            success = roll.Success;
            AddLog($"{o.Label}: {RollText(roll)}", success ? "good" : "bad");
        }
        ev.ResultText = (success ? o.SuccessText : o.FailText) ?? "";
        _effects.Clear();
        _persist = false;
        foreach (var e in ((success ? o.SuccessEffects : o.FailEffects) ?? "")
                     .Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            _effects.Enqueue(e);
        RunEffects();
        Persist();
    }

    private void RunEffects()
    {
        var ev = Event!;
        while (_effects.Count > 0)
        {
            if (State!.Char.Hp <= 0) { _effects.Clear(); break; }
            var effect = _effects.Dequeue();
            if (ApplyEffect(effect, ev)) return; // Kampf gestartet -> pausieren
        }
        ev.Finished = true;
        if (ev.IsPoi && !_persist && State!.Char.Hp > 0)
            State.SetTile(ev.Tile.X, ev.Tile.Y, TileFlags.Resolved);
    }

    /// <returns>true, wenn ein Kampf gestartet wurde.</returns>
    private bool ApplyEffect(string effect, ActiveEvent ev)
    {
        var p = effect.Split(':');
        var tile = ev.Tile;
        var lines = ev.ResultLines;
        switch (p[0].ToLowerInvariant())
        {
            case "xp":
            {
                long xp = (long)Math.Round(ParseInt(p, 1, 0) * (1 + tile.Danger * _c.Num("EventXpPerDanger", 0.25)));
                lines.Add($"+{xp} EP");
                GainXp(xp);
                break;
            }
            case "loot":
                for (int i = 0; i < ParseInt(p, 1, 1); i++) GiveLoot(tile, null, lines);
                break;
            case "lootcat":
                for (int i = 0; i < ParseInt(p, 2, 1); i++) GiveLoot(tile, p.Length > 1 ? p[1] : null, lines);
                break;
            case "item":
                if (p.Length > 1 && _c.Items.TryGetValue(p[1], out var idef))
                {
                    int qty = ParseInt(p, 2, 1);
                    var it = AddItem(idef.Key, idef.Scales ? tile.Danger : 0, qty);
                    lines.Add($"Erhalten: {ItemName(it)}{(qty > 1 ? $" ×{qty}" : "")}");
                }
                break;
            case "take":
                if (p.Length > 1 && _c.Items.TryGetValue(p[1], out var tdef) && RemoveItem(p[1], ParseInt(p, 2, 1)))
                    lines.Add($"Abgegeben: {tdef.Name}");
                break;
            case "heal":
            {
                int before = State!.Char.Hp;
                if (p.Length > 1 && p[1] == "full") State.Char.Hp = MaxHp;
                else if (p.Length > 2 && p[1] == "pct") State.Char.Hp = Math.Min(MaxHp, State.Char.Hp + MaxHp * ParseInt(p, 2, 0) / 100);
                else State.Char.Hp = Math.Min(MaxHp, State.Char.Hp + ParseInt(p, 1, 0));
                lines.Add($"+{State.Char.Hp - before} LP");
                break;
            }
            case "damage":
            {
                var (a, b) = ParseRange(p.Length > 1 ? p[1] : "1-1");
                int dmg = (int)Math.Round(_dice.Range(a, b) * (1 + tile.Danger * _c.Num("EnemyDamagePerDanger", 0.12)));
                State!.Char.Hp = Math.Max(0, State.Char.Hp - dmg);
                lines.Add($"−{dmg} LP");
                AddLog($"Du erleidest {dmg} Schaden.", "bad");
                if (State.Char.Hp <= 0) lines.Add("Dir wird schwarz vor Augen...");
                break;
            }
            case "combat":
                StartCombat(p.Length > 1 ? p[1] : "*", tile);
                return Combat is not null;
            case "lore":
                FindLore(tile, lines);
                break;
            case "reveal":
            {
                int r = ParseInt(p, 1, 4);
                Explore(State!.Char.X, State.Char.Y, r);
                lines.Add($"Karte im Umkreis von {r} Feldern aufgedeckt");
                break;
            }
            case "persist":
                _persist = true;
                break;
            case "trade":
                StartTrade(p.Length > 1 ? p[1] : "*", tile);
                return Trade is not null;
        }
        return false;
    }

    public void CloseEvent()
    {
        if (Event is null || !Event.Finished || Combat is not null || Trade is not null) return;
        Event = null;
        if (State!.Char.Hp <= 0) HandleDeath();
        Persist();
    }

    /// <summary>Ort ohne Entscheidung verlassen (bleibt bestehen).</summary>
    public void LeaveEvent()
    {
        if (Event is null || Event.ResultText is not null) return;
        if (!Event.IsPoi && Event.Def.Options.Any(o => !string.IsNullOrEmpty(o.SuccessEffects) && o.SuccessEffects.Contains("combat")))
            return; // Begegnungen mit Kampf kann man nicht einfach wegklicken
        Event = null;
        Persist();
    }

    public bool CanLeaveEvent => Event is not null && Event.ResultText is null &&
        (Event.IsPoi || !Event.Def.Options.Any(o => (o.SuccessEffects ?? "").Contains("combat")));

    private void GiveLoot(TileInfo tile, string? category, List<string> lines)
    {
        var def = PickLoot(tile, category);
        if (def is null) { lines.Add("Nichts Brauchbares."); return; }
        int level = 0;
        if (def.Scales)
        {
            level = tile.Danger;
            if (_dice.Chance(0.2)) level++;
            if (_dice.Chance(0.2)) level--;
            level = Math.Max(0, level);
        }
        int qty = def.Category == "ammo" ? _dice.Range(3, 8) : 1;
        var it = AddItem(def.Key, level, qty);
        lines.Add($"Gefunden: {ItemName(it)}{(qty > 1 ? $" ×{qty}" : "")}");
        AddLog($"Gefunden: {ItemName(it)}{(qty > 1 ? $" ×{qty}" : "")}", "loot");
        if (!string.IsNullOrEmpty(def.AmmoKey) && _c.Items.TryGetValue(def.AmmoKey, out var ammo))
        {
            int a = _dice.Range(3, 6);
            AddItem(ammo.Key, 0, a);
            lines.Add($"Gefunden: {ammo.Name} ×{a}");
        }
    }

    private ItemDef? PickLoot(TileInfo tile, string? category)
    {
        bool Cat(ItemDef i) => category is null || i.Category == category || i.Slot == category;
        var all = _c.Items.Values.Where(i => i.Rarity > 0 && Cat(i)).OrderBy(i => i.Key, StringComparer.Ordinal).ToList();
        var list = all.Where(i => i.MinDanger <= tile.Danger && (i.MaxDanger is null || i.MaxDanger >= tile.Danger) && i.Biomes.AllowsBiome(tile.Biome.Key)).ToList();
        if (list.Count == 0) list = all.Where(i => i.MinDanger <= tile.Danger && (i.MaxDanger is null || i.MaxDanger >= tile.Danger)).ToList();
        if (list.Count == 0) list = all.Where(i => i.MinDanger <= tile.Danger).ToList();
        return _dice.Weighted(list, i => i.Rarity);
    }

    private void FindLore(TileInfo tile, List<string> lines)
    {
        int maxDanger = Math.Max(tile.Danger, State!.Char.MaxDanger);
        var candidates = _c.Lore.Where(l => l.MinDanger <= maxDanger && !State.FoundLore.Contains(l.Id)).ToList();
        if (candidates.Count == 0)
        {
            lines.Add("Nichts, was du nicht schon wuesstest.");
            return;
        }
        // aeltere (niedrigere) Fragmente zuerst bevorzugen
        int minD = candidates.Min(l => l.MinDanger);
        var pick = _dice.Weighted(candidates, l => l.MinDanger == minD ? 3 : 1)!;
        State.FoundLore.Add(pick.Id);
        State.NewLore.Add(pick.Id);
        lines.Add($"Infofragment: »{pick.Title}« (Journal)");
        AddLog($"Infofragment gefunden: {pick.Title}", "story");
    }

    // =================================================================
    //  Kampf
    // =================================================================

    private void StartCombat(string enemyKey, TileInfo tile)
    {
        EnemyDef? def = null;
        if (enemyKey != "*" && _c.Enemies.TryGetValue(enemyKey, out var d)) def = d;
        if (def is null)
        {
            var all = _c.Enemies.Values.OrderBy(e => e.Key, StringComparer.Ordinal).ToList();
            var list = all.Where(e => e.MinDanger <= tile.Danger && (e.MaxDanger is null || e.MaxDanger >= tile.Danger) && e.Biomes.AllowsBiome(tile.Biome.Key)).ToList();
            if (list.Count == 0) list = all.Where(e => e.MinDanger <= tile.Danger && (e.MaxDanger is null || e.MaxDanger >= tile.Danger)).ToList();
            if (list.Count == 0) list = all.Where(e => e.MinDanger <= tile.Danger).ToList();
            def = _dice.Weighted(list, e => e.Weight);
        }
        if (def is null) return;

        int lvl = Math.Max(0, tile.Danger - def.MinDanger);
        double hpF = 1 + lvl * _c.Num("EnemyHpPerDanger", 0.22);
        double dmgF = 1 + lvl * _c.Num("EnemyDamagePerDanger", 0.12);
        int hp = (int)Math.Round(def.Hp * hpF);
        var enemy = new Enemy
        {
            Def = def,
            Level = tile.Danger,
            MaxHp = hp,
            Hp = hp,
            Attack = def.Attack + lvl * _c.Int("EnemyAttackPerDanger", 2),
            Defense = def.Defense + lvl,
            DamageMin = (int)Math.Round(def.DamageMin * dmgF),
            DamageMax = (int)Math.Round(def.DamageMax * dmgF),
            Armor = def.Armor + lvl / 3,
            Xp = (int)Math.Round(def.Xp * (1 + tile.Danger * _c.Num("EnemyXpPerDanger", 0.3))),
        };
        Combat = new Combat { Enemy = enemy, Tile = tile };
        Combat.Lines.Add(new CombatLine { Text = $"{def.Name} (Stufe {enemy.Level}) stellt sich dir entgegen!", Kind = "info" });
        AddLog($"Kampf: {def.Name} (Stufe {enemy.Level})", "bad");
    }

    public int AttackChance(bool ranged)
    {
        if (Combat is null) return 0;
        var w = Equipped(ranged ? "ranged" : "melee");
        var skill = w is not null ? Def(w).SkillKey ?? (ranged ? "ranged" : "melee") : "melee";
        return Clamp(SkillValue(skill) + _c.Int("AttackBonus", 15) - Combat.Enemy.Defense);
    }

    public int EnemyHitChance => Combat is null ? 0 : Clamp(Combat.Enemy.Attack - Dodge);

    public int FleeChance => Combat is null ? 0 :
        Clamp(_c.Int("FleeBase", 25) + SkillValue("stealth") / 2 - Combat.Tile.Danger * 2);

    public string? RangedProblem()
    {
        var w = Equipped("ranged");
        if (w is null) return "Keine Fernkampfwaffe ausgeruestet";
        var ammo = Def(w).AmmoKey;
        if (!string.IsNullOrEmpty(ammo) && Count(ammo) <= 0) return $"Keine Munition ({_c.Items.GetValueOrDefault(ammo)?.Name ?? ammo})";
        return null;
    }

    public void CombatAttack(bool ranged)
    {
        var cb = Combat;
        if (cb is null || cb.Over) return;
        var s = State!;
        InventoryItem? weapon = Equipped(ranged ? "ranged" : "melee");
        if (ranged)
        {
            var problem = RangedProblem();
            if (problem is not null) { cb.Lines.Add(new CombatLine { Text = problem, Kind = "info" }); Changed?.Invoke(); return; }
            var ammo = Def(weapon!).AmmoKey;
            if (!string.IsNullOrEmpty(ammo)) RemoveItem(ammo, 1);
        }
        var skillKey = weapon is not null ? Def(weapon).SkillKey ?? "melee" : "melee";
        int chance = AttackChance(ranged);
        var roll = RollRaw(_c.Skill(skillKey)?.Name ?? skillKey, chance);
        var wName = weapon is not null ? ItemName(weapon) : "Faeuste";
        if (roll.Success)
        {
            var (mn, mx) = weapon is not null ? ItemDamage(weapon) : (1, 3);
            int dmg = _dice.Range(mn, mx);
            if (!ranged) dmg += Attr("str") / Math.Max(1, _c.Int("MeleeStrengthDivisor", 2));
            if (roll.Critical) dmg *= 2;
            dmg = Math.Max(1, dmg - cb.Enemy.Armor);
            cb.Enemy.Hp = Math.Max(0, cb.Enemy.Hp - dmg);
            cb.Lines.Add(new CombatLine
            {
                Kind = "player",
                Text = $"{wName}: {roll.Chance}% / Wurf {roll.Roll} – {(roll.Critical ? "KRITISCH! " : "")}Treffer fuer {dmg} Schaden.",
            });
            if (cb.Enemy.Hp <= 0) { WinCombat(); Persist(); return; }
        }
        else
        {
            cb.Lines.Add(new CombatLine { Kind = "player", Text = $"{wName}: {roll.Chance}% / Wurf {roll.Roll} – daneben." });
        }
        EnemyTurn();
        Persist();
    }

    public void CombatUseItem(InventoryItem item)
    {
        var cb = Combat;
        if (cb is null || cb.Over || !Def(item).IsConsumable) return;
        var name = ItemName(item);
        var (heal, roll) = ApplyHealItem(item);
        cb.Lines.Add(new CombatLine { Kind = "good", Text = $"{name} ({roll.SkillName} {roll.Chance}% / Wurf {roll.Roll}): +{heal} LP." });
        EnemyTurn();
        Persist();
    }

    public void CombatFlee()
    {
        var cb = Combat;
        if (cb is null || cb.Over) return;
        var roll = RollRaw("Flucht", FleeChance);
        if (roll.Success)
        {
            cb.Over = true; cb.Fled = true;
            cb.Lines.Add(new CombatLine { Kind = "good", Text = $"Flucht {roll.Chance}% / Wurf {roll.Roll} – du entkommst!" });
            AddLog($"Vor {cb.Enemy.Def.Name} geflohen.", "warn");
        }
        else
        {
            cb.Lines.Add(new CombatLine { Kind = "bad", Text = $"Flucht {roll.Chance}% / Wurf {roll.Roll} – kein Entkommen!" });
            EnemyTurn();
        }
        Persist();
    }

    private void EnemyTurn()
    {
        var cb = Combat!;
        var e = cb.Enemy;
        var roll = RollRaw(e.Def.Name, EnemyHitChance);
        if (roll.Success)
        {
            int dmg = _dice.Range(e.DamageMin, e.DamageMax);
            if (roll.Critical) dmg *= 2;
            dmg = Math.Max(1, dmg - ArmorTotal);
            State!.Char.Hp = Math.Max(0, State.Char.Hp - dmg);
            cb.Lines.Add(new CombatLine
            {
                Kind = "enemy",
                Text = $"{e.Def.Name}: {roll.Chance}% / Wurf {roll.Roll} – {(roll.Critical ? "KRITISCH! " : "")}trifft dich fuer {dmg} Schaden.",
            });
            if (State.Char.Hp <= 0)
            {
                cb.Over = true;
                cb.Lines.Add(new CombatLine { Kind = "bad", Text = "Du gehst zu Boden..." });
            }
        }
        else
        {
            cb.Lines.Add(new CombatLine { Kind = "enemy", Text = $"{e.Def.Name}: {roll.Chance}% / Wurf {roll.Roll} – verfehlt dich." });
        }
    }

    private void WinCombat()
    {
        var cb = Combat!;
        cb.Over = true; cb.Won = true;
        State!.Char.Kills++;
        cb.Lines.Add(new CombatLine { Kind = "good", Text = $"{cb.Enemy.Def.Name} ist besiegt!" });
        cb.RewardLines.Add($"+{cb.Enemy.Xp} EP");
        AddLog($"{cb.Enemy.Def.Name} besiegt. +{cb.Enemy.Xp} EP", "good");
        if (_dice.Chance(cb.Enemy.Def.LootChance)) GiveLoot(cb.Tile, null, cb.RewardLines);
        GainXp(cb.Enemy.Xp);
    }

    public void EndCombat()
    {
        var cb = Combat;
        if (cb is null || !cb.Over) return;
        Combat = null;
        var ev = Event;
        if (cb.Won)
        {
            ev?.ResultLines.Add($"{cb.Enemy.Def.Name} besiegt");
            ev?.ResultLines.AddRange(cb.RewardLines);
            if (ev is not null) RunEffects();
        }
        else
        {
            _effects.Clear();
            if (ev is not null)
            {
                ev.ResultLines.Add(cb.Fled ? "Du bist geflohen." : "Du wurdest besiegt.");
                ev.Finished = true;
            }
            if (State!.Char.Hp <= 0)
            {
                Event = null;
                HandleDeath();
            }
        }
        Persist();
    }

    private void HandleDeath()
    {
        var s = State!;
        s.Char.Deaths++;
        long lost = s.Char.Xp * _c.Int("DeathXpLossPercent", 25) / 100;
        s.Char.Xp -= lost;
        s.Char.X = 0; s.Char.Y = 0;
        s.Char.Hp = Math.Max(1, MaxHp / 2);
        _effects.Clear();
        Event = null; Combat = null; Trade = null;
        Explore(0, 0, SightRadius);
        AddLog($"Du bist gestorben und im Bunker wieder zu dir gekommen. −{lost} EP.", "bad");
        _notices.Enqueue(new Notice { Title = "Niedergestreckt", Text = _c.Text("death") + (lost > 0 ? $"\n\nDu verlierst {lost} EP." : ""), Kind = "death" });
    }

    // =================================================================
    //  Tauschhandel
    // =================================================================

    /// <summary>Interner Wert eines Stuecks, skaliert mit der Gegenstandsstufe.</summary>
    public int ItemValue(InventoryItem i) =>
        (int)Math.Round(Def(i).Value * (1 + i.Level * _c.Num("ItemValuePerLevel", 0.25)));

    /// <summary>So viel ist dem Haendler ein Stueck deiner Ware wert.</summary>
    public int PayValue(InventoryItem i) => Trade is null ? 0 : (int)Math.Floor(ItemValue(i) * Trade.Def.PayFactor);

    /// <summary>So viel verlangt der Haendler fuer ein Stueck seiner Ware.</summary>
    public int PriceValue(InventoryItem i) => Trade is null || ItemValue(i) <= 0 ? 0 : Math.Max(1, (int)Math.Ceiling(ItemValue(i) * Trade.Def.PriceFactor));

    /// <summary>Gegenstaende, die der Spieler anbieten kann (angelegte nicht).</summary>
    public IEnumerable<InventoryItem> TradeableInventory => State?.Inventory.Where(i => !i.Equipped) ?? [];

    public int OfferTotal => Trade is null ? 0 : Trade.Offer.Sum(kv => State!.Inventory.FirstOrDefault(i => i.Id == kv.Key) is { } it ? PayValue(it) * kv.Value : 0);

    public int RequestTotal => Trade is null ? 0 : Trade.Request.Sum(kv => Trade.Stock.FirstOrDefault(i => i.Id == kv.Key) is { } it ? PriceValue(it) * kv.Value : 0);

    public bool CanExecuteTrade => Trade is not null && Trade.Request.Count > 0 && OfferTotal >= RequestTotal;

    private void StartTrade(string traderKey, TileInfo tile)
    {
        TraderDef? def = null;
        if (traderKey != "*" && _c.Traders.TryGetValue(traderKey, out var d)) def = d;
        def ??= _dice.Weighted(_c.Traders.Values.OrderBy(t => t.Key, StringComparer.Ordinal).ToList(), t => t.Weight);
        if (def is null) return;

        var trade = new Trade { Def = def, Tile = tile };
        var cats = def.Categories.Trim() == "*" ? new List<string?> { null }
            : def.Categories.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(c => (string?)c).ToList();
        int n = _dice.Range(def.StockMin, def.StockMax);
        long nextId = 1;
        for (int k = 0; k < n; k++)
        {
            var item = PickLoot(tile, cats[_dice.Range(0, cats.Count - 1)]);
            if (item is null || item.Value <= 0) continue;
            int level = item.Scales ? Math.Max(0, tile.Danger + _dice.Range(-1, 1)) : 0;
            int qty = item.Category == "ammo" ? _dice.Range(4, 12) : item.IsConsumable ? _dice.Range(1, 3) : 1;
            var stack = item.IsEquippable ? null : trade.Stock.FirstOrDefault(s => s.ItemKey == item.Key && s.Level == level);
            if (stack is not null) stack.Quantity += qty;
            else trade.Stock.Add(new InventoryItem { Id = nextId++, ItemKey = item.Key, Level = level, Quantity = qty });
        }
        Trade = trade;
        AddLog($"Handel mit {def.Name}.", "event");
    }

    /// <summary>Anzahl eines eigenen Gegenstands im Angebot aendern.</summary>
    public void ChangeOffer(InventoryItem item, int delta)
    {
        if (Trade is null || item.Equipped) return;
        int cur = Trade.Offer.GetValueOrDefault(item.Id);
        int next = Math.Clamp(cur + delta, 0, item.Quantity);
        if (next == 0) Trade.Offer.Remove(item.Id); else Trade.Offer[item.Id] = next;
        Changed?.Invoke();
    }

    /// <summary>Anzahl eines Haendler-Gegenstands in der Forderung aendern.</summary>
    public void ChangeRequest(InventoryItem stockItem, int delta)
    {
        if (Trade is null) return;
        int cur = Trade.Request.GetValueOrDefault(stockItem.Id);
        int next = Math.Clamp(cur + delta, 0, stockItem.Quantity);
        if (next == 0) Trade.Request.Remove(stockItem.Id); else Trade.Request[stockItem.Id] = next;
        Changed?.Invoke();
    }

    public void ExecuteTrade()
    {
        var t = Trade;
        if (t is null || !CanExecuteTrade) return;
        var s = State!;
        var given = new List<string>();
        var got = new List<string>();

        // Eigene Ware an den Haendler
        foreach (var (id, qty) in t.Offer)
        {
            var it = s.Inventory.FirstOrDefault(i => i.Id == id);
            if (it is null) continue;
            int q = Math.Min(qty, it.Quantity);
            given.Add($"{ItemName(it)}{(q > 1 ? $" ×{q}" : "")}");
            it.Quantity -= q;
            if (it.Quantity <= 0) s.Inventory.Remove(it);
            var stack = Def(it).IsEquippable ? null : t.Stock.FirstOrDefault(x => x.ItemKey == it.ItemKey && x.Level == it.Level);
            if (stack is not null) stack.Quantity += q;
            else t.Stock.Add(new InventoryItem { Id = t.Stock.Count == 0 ? 1 : t.Stock.Max(x => x.Id) + 1, ItemKey = it.ItemKey, Level = it.Level, Quantity = q });
        }
        // Ware des Haendlers an den Spieler
        foreach (var (id, qty) in t.Request)
        {
            var it = t.Stock.FirstOrDefault(i => i.Id == id);
            if (it is null) continue;
            int q = Math.Min(qty, it.Quantity);
            var added = AddItem(it.ItemKey, it.Level, q);
            got.Add($"{ItemName(added)}{(q > 1 ? $" ×{q}" : "")}");
            it.Quantity -= q;
            if (it.Quantity <= 0) t.Stock.Remove(it);
        }
        t.Offer.Clear();
        t.Request.Clear();
        var line = $"{string.Join(", ", given)} → {string.Join(", ", got)}";
        t.History.Add(line);
        AddLog($"Getauscht: {line}", "loot");
        Persist();
    }

    public void EndTrade()
    {
        var t = Trade;
        if (t is null) return;
        Trade = null;
        if (Event is { } ev)
        {
            ev.ResultLines.Add(t.History.Count == 0 ? $"Kein Handel mit {t.Def.Name}" : $"{t.History.Count} Tausch(e) mit {t.Def.Name}");
            RunEffects();
        }
        Persist();
    }

    // =================================================================
    //  Erfahrung und Stufen
    // =================================================================

    private void GainXp(long xp)
    {
        var s = State!;
        s.Char.Xp += xp;
        while (s.Char.Xp >= XpForNext(s.Char.Level))
        {
            s.Char.Xp -= XpForNext(s.Char.Level);
            s.Char.Level++;
            int ap = _c.Int("AttributePointsPerLevel", 1), sp = _c.Int("SkillPointsPerLevel", 3);
            s.Char.AttributePoints += ap;
            s.Char.SkillPoints += sp;
            s.Char.Hp = Math.Min(MaxHp, s.Char.Hp + _c.Int("HpPerLevel", 3));
            AddLog($"Stufe {s.Char.Level} erreicht!", "level");
            _notices.Enqueue(new Notice
            {
                Title = $"Stufe {s.Char.Level}",
                Text = $"{_c.Text("levelup")}\n\n+{ap} Attributpunkt(e), +{sp} Fertigkeitspunkte. Verteile sie im Charakterbogen.",
                Kind = "level",
            });
        }
    }

    public void SpendAttribute(string key)
    {
        if (State is null || State.Char.AttributePoints <= 0 || !State.Attributes.ContainsKey(key)) return;
        int before = MaxHp;
        State.Attributes[key]++;
        State.Char.AttributePoints--;
        State.Char.Hp += Math.Max(0, MaxHp - before);
        Persist();
    }

    public void SpendSkill(string key)
    {
        if (State is null || State.Char.SkillPoints <= 0 || _c.Skill(key) is null) return;
        State.Skills[key] = Ranks(key) + 1;
        State.Char.SkillPoints--;
        Persist();
    }

    public void DismissNotice()
    {
        if (Event is null && Combat is null && Trade is null && _notices.Count > 0) _notices.Dequeue();
        Changed?.Invoke();
    }

    // =================================================================
    //  Hilfen
    // =================================================================

    private void AddLog(string text, string kind = "info")
    {
        if (State is null) return;
        var e = new LogEntry { Turn = State.Char.Turn, Kind = kind, Text = text };
        State.Log.Add(e);
        State.NewLog.Add(e);
        if (State.Log.Count > 120) State.Log.RemoveRange(0, State.Log.Count - 120);
    }

    private static int ParseInt(string[] p, int idx, int fallback) =>
        p.Length > idx && int.TryParse(p[idx], out var v) ? v : fallback;

    private static (int, int) ParseRange(string s)
    {
        var parts = s.Split('-');
        int a = int.TryParse(parts[0], out var x) ? x : 1;
        int b = parts.Length > 1 && int.TryParse(parts[1], out var y) ? y : a;
        return (Math.Min(a, b), Math.Max(a, b));
    }
}
