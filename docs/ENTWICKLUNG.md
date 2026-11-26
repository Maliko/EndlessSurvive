# Entwicklerdoku

Diese Doku erklärt, wie der Code aufgebaut ist und wo du anfasst, wenn du das Spiel erweitern willst. Für Spielregeln und das reine Hinzufügen von Inhalten siehe zuerst die [README](../README.md).

## Inhalt

1. [Entwicklungsumgebung](#1-entwicklungsumgebung)
2. [Architektur im Überblick](#2-architektur-im-überblick)
3. [Ablauf eines Spielzugs](#3-ablauf-eines-spielzugs)
4. [Die Dienste im Detail](#4-die-dienste-im-detail)
5. [Die Oberfläche](#5-die-oberfläche)
6. [Formeln](#6-formeln)
7. [Rezepte: typische Erweiterungen](#7-rezepte-typische-erweiterungen)
7a. [Beispiel einer größeren Erweiterung: Tauschhändler](#7a-beispiel-einer-größeren-erweiterung-tauschhändler)
7b. [Die Verwaltung](#7b-die-verwaltung)
8. [Stolperfallen](#8-stolperfallen)
9. [Testen](#9-testen)

---

## 1. Entwicklungsumgebung

- .NET 8 SDK
- Ein Editor mit C#-Unterstützung (Visual Studio, Rider oder VS Code mit C# Dev Kit)
- Optional: [DB Browser for SQLite](https://sqlitebrowser.org/) zum Bearbeiten von `content.db`

Mit Hot Reload entwickeln:

```bash
cd EndlessSurvive
dotnet watch
```

Änderungen an `.razor`, `.cs` und `app.css` werden meist ohne Neustart übernommen. Änderungen über die Verwaltung (`/admin`) wirken sofort. Änderungen an `content.db` mit einem externen Werkzeug werden erst nach „Inhalte neu laden“ in der Verwaltung oder nach einem Neustart sichtbar, weil `ContentStore` die Inhalte in den Speicher liest.

Spielstand zurücksetzen: in der Verwaltung unter „Spielstand“, im Spiel über „Neues Spiel“ oder bei **gestopptem** Server `EndlessSurvive/Data/save.db` löschen. Bei laufendem Server die Datei nicht löschen: Der Server hält sie offen und meldet dann „readonly database“.

---

## 2. Architektur im Überblick

```
Browser  ──SignalR──►  Blazor-Komponenten  ──►  GameService (Regeln, 1× pro Verbindung)
                              ▲                    │        │          │
                              │ Changed-Event      │        │          │
                              └────────────────────┘        ▼          ▼
                                                     ContentStore   SaveStore
                                                     (content.db,   (save.db,
                                                      nur lesen)     lesen/schreiben)
                                                            │
                                                            ▼
                                                        WorldGen
                                                  (Welt aus Seed + Koordinaten)
```

| Klasse | Lebensdauer | Aufgabe |
|---|---|---|
| `ContentStore` | Singleton | Lädt beim Start alle Tabellen aus `content.db` in den Speicher. Erzeugt `content.db` aus `content.sql`, falls sie fehlt. |
| `SaveStore` | Singleton | Legt `save.db` an und liest/schreibt den kompletten Spielstand. |
| `GameService` | Scoped (pro Browser-Verbindung) | **Alle Spielregeln.** Hält den Spielzustand und die offenen Dialoge (Ereignis, Kampf, Handel, Hinweis). |
| `ContentAdmin` | Singleton | Verwaltung: schreibt in `content.db`, sichert, exportiert `content.sql`, lädt `ContentStore` neu (siehe [7b](#7b-die-verwaltung)). |
| `WorldGen` | pro Spielstand | Berechnet für jede Koordinate Biom, Gefahrenstufe und ggf. einen Ort. Rein deterministisch. |
| `Dice` / `WorldHash` | – | `Dice` ist echter Zufall (Würfe), `WorldHash` ist deterministischer Zufall (Welt). |

**Grundregel:** Komponenten enthalten keine Spiellogik. Sie lesen aus `GameService` und rufen dessen Methoden auf. Neue Regeln gehören immer in `GameService` (oder eine neue Klasse in `Services/`).

### Dateien

```
EndlessSurvive/
  Program.cs                   DI-Registrierung, Start
  Data/content.sql|.db         Inhalte
  Models/ContentModels.cs      Klassen für die Inhaltstabellen (1:1 zu den Spalten)
  Services/
    ContentStore.cs            Inhalte laden, Settings lesen (Num/Int/Str/Text)
    GameState.cs               Spielzustand + Laufzeitobjekte (ActiveEvent, Combat, Enemy, Notice …)
    GameService.cs             Regeln
    SaveStore.cs               Persistenz
    WorldGen.cs                Prozedurale Welt
    Rng.cs                     Dice, WorldHash
    Admin/                     ContentAdmin, ContentValidator, EffectCatalog
  Components/
    App.razor                  HTML-Gerüst, Render-Modus
    Pages/Home.razor           Titelbildschirm  (/)
    Pages/NewGame.razor        Charaktererstellung (/new)
    Pages/GamePage.razor       Spielansicht (/game), Tastatur, Dialog-Auswahl
    Game/*.razor               Karte, Dialoge, Panels
    Game/GameComponent.cs      Basisklasse: rendert bei Zustandsänderung neu
    Admin/                     Layout und Eingabefelder der Verwaltung
    Pages/Admin/               Seiten der Verwaltung (/admin …)
  wwwroot/app.css              gesamtes Styling
  wwwroot/game.js              Tastatur- und Fenstergrößen-Weiterleitung an Blazor
```

---

## 3. Ablauf eines Spielzugs

Beispiel: Der Spieler drückt `D`.

1. `game.js` fängt das `keydown` ab und ruft `GamePage.OnKey("d")` auf.
2. `OnKey` prüft, welcher Dialog offen ist. Ist keiner offen, ruft es `Game.Move(1, 0)` auf.
3. `Move` holt das Zielfeld aus `WorldGen.Tile(x, y)`:
   - **unpassierbar** → Logeintrag, Ende
   - Position setzen, `Turn++`, Umgebung aufdecken (`Explore`)
   - **Bunker (0,0)** → Logeintrag
   - **Ort, noch nicht erledigt** → `OpenEvent(poi, …)`
   - sonst mit `Biome.EncounterChance` → `TriggerEncounter` (zufälliges `encounter`-Ereignis)
4. `Persist()` speichert den Zustand in `save.db` und löst `Changed` aus.
5. Alle Komponenten, die von `GameComponent` erben, rendern neu.

### Ereignisse und die Effekt-Warteschlange

```
OpenEvent ──► Spieler wählt Option ──► ChooseOption
                                         │ ggf. Probe würfeln (RollRaw)
                                         │ Effekt-String der Option zerlegen → _effects (Queue)
                                         ▼
                                     RunEffects ──► ApplyEffect(effect) für jeden Eintrag
                                         │              │
                                         │              └─ "combat:…" → StartCombat, RunEffects PAUSIERT
                                         │                                   │
                                         │       Spieler kämpft …            ▼
                                         │                               EndCombat
                                         │                    gewonnen → RunEffects läuft weiter
                                         │                    geflohen/tot → Rest der Queue verfällt
                                         ▼
                                   Event.Finished = true
                                   Ort als erledigt markieren (außer bei "persist")
                                         ▼
                                   Spieler klickt „Weiter“ → CloseEvent (prüft Tod)
```

Deshalb kann ein Ereignis wie das Rumtreiber-Lager `combat:raider;combat:raider;loot:3` haben: zwei Kämpfe nacheinander, danach Beute.

Regeln für „erledigt“:
- Ein Ort (`poi`) wird nach Abschluss als `Resolved` gespeichert und verschwindet von der Karte.
- Ausnahme: Effekt `persist` (z. B. Option „Weitergehen“). Dann bleibt der Ort.
- Bei Flucht oder Tod im Kampf wird der Ort **nicht** als erledigt markiert, er kann erneut versucht werden.

### Dialog-Priorität

In `GamePage.razor` wird immer nur ein Dialog angezeigt, in dieser Reihenfolge:

1. `Game.Combat` (Kampf)
2. `Game.Trade` (Tauschhandel)
3. `Game.Event` (Ereignis)
4. `Game.Notice` (Hinweise aus einer Warteschlange: Intro, Stufenaufstieg, Tod)

Solange irgendetwas davon offen ist, ist `Game.Busy == true` und Bewegung/Rasten sind gesperrt.

---

## 4. Die Dienste im Detail

### ContentStore

- `Settings` liest du über `Num(key, fallback)`, `Int(key, fallback)`, `Str(key, fallback)`. **Gib immer einen sinnvollen Fallback an**, damit eine fehlende Zeile das Spiel nicht kaputt macht.
- `Text(key)` liefert Einträge aus der Tabelle `Texts`.
- `Biomes` ist nach `Priority` **absteigend** sortiert. Das nutzt `WorldGen` direkt.
- `Events` enthält die Optionen bereits eingehängt (`EventDef.Options`).

### WorldGen

- `Tile(x, y)` → `TileInfo(X, Y, Biome, Danger, Poi)`, mit kleinem Cache.
- **Biom:** zwei Rauschwerte (Höhe, Feuchte) zwischen 0 und 1. Das erste Biom (höchste Priorität), dessen Bereiche passen, gewinnt. Biome mit `Generated = 0` (z. B. `bunker`) werden nie per Rauschen gewählt.
- **Schutzzone:** Innerhalb von `SafeRadius` um den Bunker wird unpassierbares Gelände durch passierbares ersetzt, damit man nie eingesperrt startet.
- **Gefahrenstufe:** `floor(Entfernung / DangerDistance) + Biome.DangerBonus` (Bunker immer 0).
- **Orte:** `WorldHash.Unit(seed, x, y, SaltPoi) < Biome.EventChance` → es gibt einen Ort. Welcher, wird per Hash gewichtet aus allen passenden `poi`-Ereignissen gezogen.
- Das Rauschen ist Value-Noise mit 4 Oktaven und Kontraststreckung (`Fractal`). Der Maßstab steht in `Build` (`x / 11.0` für Höhe, `x / 15.0` für Feuchte). Größere Divisoren ergeben größere Biomflächen.

### SaveStore

Tabellen in `save.db`:

| Tabelle | Inhalt |
|---|---|
| `Character` | genau eine Zeile (`Id = 1`): Name, Seed, Stufe, EP, LP, Position, freie Punkte, Statistik |
| `CharacterAttributes` / `CharacterSkills` | Key → Wert/Rang |
| `Inventory` | Gegenstände (`ItemKey`, `Level`, `Quantity`, `Equipped`) |
| `Tiles` | nur veränderte Felder: Bitflags `1 = erkundet`, `2 = erledigt` |
| `FoundLore` | IDs gefundener Infofragmente |
| `Log` | die letzten ~200 Logzeilen |

`Save()` schreibt Charakter, Attribute, Fertigkeiten und Inventar komplett neu. Felder, Lore und Log werden **inkrementell** geschrieben, über die Mengen `DirtyTiles`, `NewLore` und `NewLog` in `GameState`. Wenn du Felder änderst, immer `State.SetTile(...)` benutzen, nie direkt ins Dictionary schreiben, sonst wird die Änderung nicht gespeichert.

### GameService – wichtige Methoden

| Bereich | Methoden |
|---|---|
| Spielstand | `NewGame`, `Load`, `HasSave`, `PeekSave` |
| Werte | `Attr`, `Ranks`, `SkillValue`, `MaxHp`, `XpForNext`, `Dodge`, `ArmorTotal`, `SightRadius` |
| Gegenstände | `ItemName`, `ItemDamage`, `ItemArmor`, `Equipped(slot)`, `Count(key)`, `Equip`, `Unequip`, `Drop`, `UseItem`, `DropObsolete` |
| Proben | `CheckChance(option, danger)`, `RollRaw(name, chance)`, `RollText` |
| Welt | `Move`, `StepToward`, `Rest`, `CanEnter`, `CurrentTile` |
| Ereignisse | `ChooseOption`, `CloseEvent`, `LeaveEvent`, intern `OpenEvent`, `RunEffects`, `ApplyEffect` |
| Handel | `ItemValue`, `PayValue`, `PriceValue`, `ChangeOffer`, `ChangeRequest`, `ExecuteTrade`, `EndTrade`, intern `StartTrade` |
| Kampf | `CombatAttack(ranged)`, `CombatUseItem`, `CombatFlee`, `EndCombat`, intern `StartCombat`, `EnemyTurn`, `WinCombat` |
| Fortschritt | `GainXp` (intern), `SpendAttribute`, `SpendSkill` |

**Jede öffentliche Methode, die den Zustand ändert, muss am Ende `Persist()` aufrufen.** Nur so wird gespeichert und die Oberfläche aktualisiert.

---

## 5. Die Oberfläche

- **Render-Modus:** In `App.razor` ist global `InteractiveServer` mit `prerender: false` gesetzt. Das Prerendering ist bewusst aus, sonst würde `GameService` (scoped) zweimal erzeugt.
- **Neu rendern:** Komponenten erben von `GameComponent` (`@inherits GameComponent`). Die Basisklasse injiziert `Game` und abonniert `Game.Changed`. Eine neue Spielkomponente sollte das ebenfalls tun.
- **Tastatur:** `game.js` leitet jeden Tastendruck an `GamePage.OnKey` weiter. Neue Tastenkürzel trägst du dort ein.
- **Kartengröße:** `game.js` meldet die Fensterbreite an `GamePage.OnResize`. Dort wird die Spaltenzahl gewählt (9 / 13 / 19) und an `MapView` übergeben.
- **Karte:** `MapView.razor` zeichnet ein SVG mit 48×48 Einheiten pro Feld. Das Biom-Symbol (`Biomes.Glyph`) wird als roher SVG-Code eingefügt und muss deshalb in dieses 48×48-Raster passen. Gegner-Icons (`Enemies.Icon`) nutzen ein 64×64-Raster.
- **Styling:** alles in `wwwroot/app.css`. Farben und Schriften stehen als CSS-Variablen in `:root` (`--amber`, `--red`, `--panel` …).

---

## 6. Formeln

Alle Zahlen in eckigen Klammern sind Schlüssel aus der Tabelle `Settings`.

| Wert | Formel |
|---|---|
| Fertigkeitswert | `[SkillBase] + Attribut × [SkillPerAttribute] + Rang × [SkillPerRank]` |
| Jede Chance | begrenzt auf `[ChanceMin]` bis `[ChanceMax]` |
| Ereignisprobe | `Fertigkeitswert + Difficulty − (DangerScaling ? Gefahr × [DangerCheckPenalty] : 0)` |
| Kritisch | Wurf ≤ max(1, Chance / 10) |
| Max. LP | `[HpBase] + AUS × [HpPerEndurance] + (Stufe − 1) × [HpPerLevel]` |
| EP für nächste Stufe | `[XpBase] × Stufe ^ [XpExponent]` |
| Eigener Angriff | `Waffenfertigkeit + [AttackBonus] − Gegner.Defense` |
| Nahkampfschaden | `Waffenschaden + STR / [MeleeStrengthDivisor]`, ×2 bei kritisch, − Gegnerrüstung, mindestens 1 |
| Gegnerangriff | `Gegner.Attack − GEW × [DodgePerAgility]` |
| Erlittener Schaden | `Gegnerschaden`, ×2 bei kritisch, − eigene Rüstung, mindestens 1 |
| Flucht | `[FleeBase] + Schleichen / 2 − Gefahr × 2` |
| Gegnerskalierung | `lvl = max(0, Gefahr − Enemy.MinDanger)`; LP × (1 + lvl × `[EnemyHpPerDanger]`), Schaden × (1 + lvl × `[EnemyDamagePerDanger]`), Angriff + lvl × `[EnemyAttackPerDanger]`, Verteidigung + lvl, Rüstung + lvl / 3 |
| Gegner-EP | `Enemy.Xp × (1 + Gefahr × [EnemyXpPerDanger])` |
| Gegenstandsstufe | Gefahr des Fundorts, je 20 % Chance auf +1 bzw. −1 (nur bei `Scales = 1`) |
| Waffenschaden | `Basis × (1 + Stufe × [ItemDamagePerLevel])` |
| Rüstung | `Basis + floor(Stufe × [ItemArmorPerLevel])` |
| Heilgegenstand | Heilung-Probe: Erfolg = `HealMax + Heilung-Rang`, sonst zufällig `HealMin..HealMax` |
| Tauschwert | `Items.Value × (1 + Stufe × [ItemValuePerLevel])` pro Stück |
| Händler zahlt | `floor(Tauschwert × Traders.PayFactor)` |
| Händler verlangt | `ceil(Tauschwert × Traders.PriceFactor)`, mindestens 1 |
| Rasten im Freien | Heilung-Probe: 35 % / 15 % der max. LP; Begegnungsrisiko = `EncounterChance × [RestEncounterFactor]` |

---

## 7. Rezepte: typische Erweiterungen

### Neuer Inhalt (Gegenstand, Gegner, Ereignis, Biom, Lore)

Kein Code nötig. Über die Verwaltung anlegen, siehe README.

### Neuer Effekt-Typ für Ereignisse

Beispiel: `skillxp:hacking:1` soll einen Fertigkeitsrang schenken.

1. In `GameService.ApplyEffect` einen neuen `case` ergänzen:

   ```csharp
   case "skillxp":
       if (p.Length > 1 && _c.Skill(p[1]) is { } sk)
       {
           State!.Skills[sk.Key] = Ranks(sk.Key) + ParseInt(p, 2, 1);
           lines.Add($"+{ParseInt(p, 2, 1)} Rang {sk.Name}");
       }
       break;
   ```

2. Den Effekt in `Services/Admin/EffectCatalog.cs` eintragen: in der Liste `All` (Hilfetext in der Verwaltung) **und** als `case` in `Validate`. Sonst meldet die Inhaltsprüfung ihn als „unbekannter Effekt“.

   ```csharp
   new("skillxp", "skillxp:SKILL:N", "Fertigkeitsrang geschenkt"),
   ...
   case "skillxp":
       if (c.Skill(Arg(1)) is null) yield return $"„{raw}“: Fertigkeit „{Arg(1)}“ existiert nicht";
       break;
   ```

3. In der README in der Effekt-Liste ergänzen.
4. In der Verwaltung bei einer Ereignis-Option verwenden: `skillxp:hacking:1;xp:10`.

Gibt `ApplyEffect` `true` zurück, pausiert die Warteschlange. Das brauchst du nur für Effekte, die einen eigenen Dialog öffnen (wie `combat`).

### Neuer Balancing-Wert

1. In der Verwaltung unter „Regeln & Balancing“ eine Zeile anlegen.
2. Im Code mit Fallback lesen: `_c.Num("MeinWert", 1.0)`.

### Neue Spalte in einer Inhaltstabelle

Beispiel: Gegner sollen eine Spalte `Poison` bekommen.

1. `ALTER TABLE Enemies ADD COLUMN Poison INTEGER NOT NULL DEFAULT 0;` in `content.db` ausführen, z. B. mit DB Browser for SQLite. Danach in der Verwaltung „Inhalte neu laden“ und „content.sql jetzt schreiben“.
2. Property `public int Poison { get; set; }` in `EnemyDef` (`Models/ContentModels.cs`). Dapper mappt per Spaltenname.
3. In `GameService` verwenden.
4. Optional: In der Verwaltung unter „Spaltenbeschreibungen“ eine Zeile für `Enemies` / `Poison` mit Hilfetext und Eingabefeld-Typ anlegen. Die Spalte erscheint auch ohne diesen Eintrag im Editor, dann als einfaches Zahlenfeld.
5. Falls die Inhaltsprüfung die neue Spalte prüfen soll: Regel in `ContentValidator.cs` ergänzen.

### Neuer Wert im Spielstand

Beispiel: Hunger.

1. Property in `CharacterState` (`GameState.cs`).
2. In `SaveStore`: Spalte im `CREATE TABLE Character` **und** im `INSERT OR REPLACE` ergänzen.
3. **Migration für bestehende Spielstände:** `CREATE TABLE IF NOT EXISTS` ändert eine vorhandene Tabelle nicht. Im Konstruktor von `SaveStore` zusätzlich die Spalte nachrüsten, z. B.:

   ```csharp
   var cols = c.Query<string>("SELECT name FROM pragma_table_info('Character')").ToList();
   if (!cols.Contains("Hunger")) c.Execute("ALTER TABLE Character ADD COLUMN Hunger INTEGER NOT NULL DEFAULT 0");
   ```

   Oder einfach `save.db` löschen, solange du allein entwickelst.

### Neues Panel in der Seitenleiste

1. `Components/Game/MeinPanel.razor` mit `@inherits GameComponent` anlegen.
2. In `GamePage.razor` einen weiteren `<button class="tab">` und einen `case` im `switch (_tab)` ergänzen.
3. Optional ein Tastenkürzel in `OnKey`.

### Neue Kampfaktion

1. Öffentliche Methode in `GameService` nach dem Muster von `CombatFlee`: Prüfen, ob `Combat` offen und nicht `Over` ist, Aktion ausführen, danach `EnemyTurn()` und `Persist()`.
2. Button in `CombatDialog.razor`, Taste in `GamePage.OnKey` (Block `if (Game.Combat is { } cb)`).

---

## 7a. Beispiel einer größeren Erweiterung: Tauschhändler

Die Rezepte oben reichen, solange du vorhandene Mechaniken kombinierst. Eine **neue Mechanik** wie Tauschhandel muss einmal im Code gebaut werden. Danach sind die einzelnen Händler, Sortimente und Preise wieder reine Datenbankeinträge. Der Händler ist so umgesetzt und dient als Vorlage für ähnliche Erweiterungen (Crafting, Quests, Begleiter …).

### Leitfrage: Was ist Mechanik, was ist Inhalt?

| Mechanik (Code, einmalig) | Inhalt (Datenbank, beliebig oft) |
|---|---|
| Wie ein Tausch funktioniert | Welche Händler es gibt |
| Wie Werte berechnet werden | Wert jedes Gegenstands, Ankaufs-/Verkaufsfaktor |
| Wie das Sortiment ausgewürfelt wird | Sortimentsgröße und Kategorien je Händler |
| Wie ein Händler ins Spiel kommt (Effekt `trade:`) | Wo und wie oft Händler auftauchen (Ereignisse) |

### Was geändert wurde, Schritt für Schritt

**1. Datenbank** (`content.sql` / `content.db`)
- `Items` bekam die Spalte `Value` (Tauschwert).
- Neue Tabelle `Traders`.
- Neuer Balancing-Wert `ItemValuePerLevel` in `Settings`.
- Zwei Ereignisse, die den neuen Effekt nutzen: `wandering_trader` (Begegnung) und `trader_post` (fester Ort mit `persist`, bleibt also auf der Karte).

**2. Modelle** (`Models/ContentModels.cs`)
- `ItemDef.Value` und neue Klasse `TraderDef`. Die Property-Namen entsprechen den Spaltennamen, Dapper mappt automatisch.

**3. Laden** (`Services/ContentStore.cs`)
- Eine Zeile: `Traders = c.Query<TraderDef>(...)`.

**4. Laufzeitobjekt** (`Services/GameState.cs`)
- Klasse `Trade`, analog zu `Combat`: Händler, ausgewürfeltes Sortiment (`Stock`), aktuelle Auswahl (`Offer`, `Request`) und bisherige Tausche (`History`).
- Bewusste Entscheidung: Das Sortiment wird **nicht gespeichert**. Ein reisender Händler würfelt bei jeder Begegnung neu, deshalb war keine Änderung an `save.db` nötig.

**5. Regeln** (`Services/GameService.cs`, Abschnitt „Tauschhandel“)
- Property `Trade` und Einbindung in `Busy` und `Notice`, damit während des Handels nichts anderes passiert.
- `case "trade":` in `ApplyEffect`. Er gibt `true` zurück und **pausiert dadurch die Effekt-Warteschlange**, genau wie `combat`.
- `StartTrade` würfelt das Sortiment mit dem vorhandenen `PickLoot` aus, die Beute-Logik wird also wiederverwendet.
- `ChangeOffer` / `ChangeRequest` ändern nur die Auswahl. `ExecuteTrade` verschiebt die Gegenstände. `EndTrade` schließt den Handel und setzt die Warteschlange mit `RunEffects()` fort, wie `EndCombat`.
- Inventar-Aktionen (`Equip`, `Drop` …) sind während des Handels gesperrt.

**6. Oberfläche**
- `Components/Game/TradeDialog.razor`: zwei Spalten mit −/+ und einer Bilanzanzeige. Der Dialog enthält keine Logik, er ruft nur `GameService` auf.
- `GamePage.razor`: Handel als zusätzliche Dialogstufe und Tasten (`Enter` tauschen, `Esc` beenden).
- `InventoryPanel.razor`: zeigt den Wert jedes Gegenstands.
- `app.css`: Abschnitt „Tauschhandel“.

### Checkliste für deine eigene Erweiterung

1. Trennen: Was ist Regel (Code), was ist Inhalt (Datenbank)?
2. Neue Tabellen/Spalten per SQL in `content.db` anlegen (danach „Inhalte neu laden“ und „content.sql jetzt schreiben“ in der Verwaltung), Modellklasse ergänzen, in `ContentStore` laden. Die Verwaltung zeigt die neue Tabelle sofort an.
3. Braucht die Mechanik einen eigenen Dialog? Dann ein Laufzeitobjekt in `GameState.cs` und eine Property in `GameService`, und sie in `Busy` und `Notice` berücksichtigen.
4. Einstieg über einen neuen Effekt in `ApplyEffect`. So bestimmt die Datenbank, wann die Mechanik ausgelöst wird.
5. Muss etwas über das Neuladen hinaus erhalten bleiben? Dann `SaveStore` erweitern (siehe Rezept „Neuer Wert im Spielstand“).
6. Dialog-Komponente mit `@inherits GameComponent`, in `GamePage.razor` einhängen, Tasten in `OnKey`.
7. Jede zustandsändernde Methode endet mit `Persist()`. Reine Auswahländerungen, die nichts speichern müssen, rufen nur `Changed?.Invoke()` auf.
8. Effekt in `EffectCatalog.cs` eintragen. Spalten in `_ColumnDocs` beschreiben. Sinnvolle Prüfungen in `ContentValidator.cs` ergänzen. README aktualisieren.

---

## 7b. Die Verwaltung

Die Verwaltung unter `/admin` arbeitet **generisch auf dem Datenbankschema**. Sie kennt keine einzelnen Tabellen, sondern liest Tabellen, Spalten, Typen und Fremdschlüssel direkt aus SQLite. Deshalb erscheint eine neue Tabelle oder Spalte automatisch, ohne Codeänderung.

### Bausteine

| Datei | Aufgabe |
|---|---|
| `Services/Admin/ContentAdmin.cs` | Liest das Schema (`TableInfo`, `ColumnInfo`). Liest und schreibt Zeilen, sichert, exportiert `content.sql`, lädt `ContentStore` nach jeder Änderung neu. |
| `Services/Admin/ContentValidator.cs` | Inhaltsprüfung. Arbeitet auf den geladenen Objekten aus `ContentStore`. |
| `Services/Admin/EffectCatalog.cs` | Liste und Prüfung der Effekt-Sprache (Hilfe im Editor, Live-Prüfung, Inhaltsprüfung). |
| `Components/Admin/AdminLayout.razor` | Layout mit Menü. Die Gruppen kommen aus `_TableDocs.GroupName`. |
| `Components/Admin/AdminField.razor` | Ein Eingabefeld. Wählt die Darstellung anhand von `ColumnInfo.Editor`. |
| `Components/Admin/CellView.razor` | Darstellung einer Zelle in Listen (Farbfeld, SVG-Vorschau, Häkchen). |
| `Components/Pages/Admin/*.razor` | Seiten: Übersicht, Liste, Zeilen-Editor, Prüfung, Spielstand, Weltvorschau |

### Meta-Tabellen

Beschriftungen und Eingabefelder stehen selbst in der Datenbank und sind in der Verwaltung bearbeitbar:

- **`_TableDocs`**: Anzeigename, Menügruppe, Beschreibung, Spalten der Listenansicht und Reihenfolge je Tabelle. Tabellen ohne Eintrag landen in der Gruppe „Weitere“ und zeigen die ersten sechs Spalten.
- **`_ColumnDocs`**: Hilfetext und Eingabefeld-Typ (`Editor`) je Spalte.

| Editor | Eingabefeld |
|---|---|
| *(leer)* | automatisch nach Spaltentyp: Text oder Zahl |
| `multiline` | mehrzeiliges Textfeld |
| `bool` | Häkchen (speichert 0/1) |
| `color` | Farbwähler + Textfeld |
| `enum:a,b,c` | Auswahlliste mit festen Werten |
| `ref:Tabelle` | Auswahlliste mit den Schlüsseln einer Tabelle. Echte Fremdschlüssel werden auch ohne diesen Eintrag erkannt. |
| `biomes` | Häkchen je Biom oder „überall (*)“, speichert eine kommagetrennte Liste |
| `cats` | wie `biomes`, aber für Kategorien und Slots |
| `effects` | Effekt-Feld mit Live-Prüfung und Hilfe |
| `svg:48` / `svg:64` | SVG-Code mit Vorschau |

Einen neuen Editor-Typ baust du in `AdminField.razor` als weiteren Zweig ein.

### Wie Änderungen ins Spiel kommen

1. `ContentAdmin.Insert/Update/Delete` schreibt in `content.db`, vorher ggf. eine Sicherung.
2. `ExportSql()` schreibt `content.sql` neu. Die Tabellen werden so sortiert, dass referenzierte Tabellen zuerst kommen. Die `CREATE TABLE`-Anweisungen werden wörtlich aus SQLite übernommen, einschließlich der Kommentare darin.
3. `ContentStore.Load()` lädt alles neu und erhöht `ContentStore.Version`.
4. `WorldGen` bemerkt die neue Version und leert seinen Cache. Ab dem nächsten Schritt gelten die neuen Biome und Ereignisse.

Ein bereits geöffneter Dialog (Ereignis, Kampf, Handel) läuft mit den alten Werten zu Ende.

### Spielstand ändern, während das Spiel läuft

Der Spielstand-Editor schreibt über `SaveStore.Save` und ruft danach `SaveStore.NotifyExternalChange()` auf. Jeder `GameService` hört auf dieses Ereignis und lädt den Spielstand neu (`OnSaveChangedExternally`). Offene Dialoge werden dabei verworfen. Ohne diesen Mechanismus würde das offene Spiel die Änderungen beim nächsten Zug mit seinem alten Stand überschreiben. Wenn du an anderer Stelle `save.db` von außen änderst, rufe ebenfalls `NotifyExternalChange()` auf.

### Bewusste Einschränkungen

- **Schlüssel sind nach dem Anlegen fest.** Andere Einträge, Effekte und Biom-Listen verweisen per Text darauf. Zum Umbenennen: „Duplizieren“, Verweise umstellen, Original löschen. Die Inhaltsprüfung zeigt vergessene Verweise.
- **Löschen** entfernt Einträge, die per Pflicht-Fremdschlüssel abhängen, gleich mit (z. B. die Optionen eines Ereignisses). Optionale Verweise werden geleert. Verweise in Textfeldern (Effekte, Biom-Listen) bleiben stehen und tauchen in der Inhaltsprüfung auf.
- **Tabellen und Spalten anlegen** geht nicht in der Verwaltung, sondern per SQL (siehe Rezept „Neue Spalte“). Das ist Absicht: Neue Spalten brauchen ohnehin Code, der sie benutzt.
- **Kein Login.** Siehe README.

---

## 8. Stolperfallen

**Fest im Code verwendete Schlüssel.** Diese Keys aus der Datenbank werden vom Code direkt angesprochen. Nicht umbenennen oder löschen, sonst funktionieren Teile der Regeln nicht mehr:

| Art | Keys | Wo benutzt |
|---|---|---|
| Attribute | `str`, `end`, `agi` | Schaden, LP, Ausweichen |
| Fertigkeiten | `melee`, `ranged`, `healing`, `stealth`, `perception` | Kampf, Heilung, Flucht, Sichtweite |
| Slots | `melee`, `ranged`, `body`, `head` | Ausrüstung, Kampf, Inventar-Anzeige |
| Kategorien | `weapon`, `armor`, `consumable`, `ammo` | Inventar, Stapeln, Benutzen |
| Event-Kinds | `poi`, `encounter` | Weltgenerierung, Begegnungen |
| Biom | Wert von `Settings.StartBiome` (Standard `bunker`) | Startfeld (0,0) |

**Weltgenerierung und bestehende Spielstände.** Die Welt wird bei jedem Laden aus dem Seed neu berechnet. Wenn du Biom-Bereiche, `EventChance`, die Rauschparameter in `WorldGen` oder die Liste der `poi`-Ereignisse änderst, sieht die Welt eines **bestehenden** Spielstands danach anders aus. Erkundete und erledigte Felder bleiben gespeichert, aber Gelände und Orte können sich verschieben. Für Tests egal, für einen laufenden Spielstand ggf. ärgerlich.

**`content.db` ist die Quelle, `content.sql` wird erzeugt.** Das Spiel liest nur `content.db`. Die Verwaltung schreibt `content.sql` bei jeder Änderung komplett neu. Handänderungen an `content.sql` gehen dabei verloren, es sei denn, du hast vorher `content.db` gelöscht und neu erzeugen lassen. Kommentare gehören deshalb nicht in `content.sql`, sondern in `_TableDocs` / `_ColumnDocs`. Kommentare innerhalb von `CREATE TABLE` bleiben erhalten.

**Effekt-Tippfehler stören das Spiel nicht, verpuffen aber.** Ein Effekt wie `lot:2` wird im Spiel stillschweigend ignoriert. Die Verwaltung markiert ihn beim Eintippen, und die Inhaltsprüfung listet ihn auf.

**Proben ohne Fertigkeit gelingen immer.** Wenn `SkillKey` leer ist (`NULL`), werden nur `SuccessText`/`SuccessEffects` benutzt.

**Encounter mit Kampf lassen sich nicht wegklicken.** `CanLeaveEvent` verhindert „Später“ bei Begegnungen, deren Optionen einen Kampf enthalten. Orte (`poi`) lassen sich immer verlassen.

**Laufzeitzustand wird nicht gespeichert.** Ein offener Kampf oder ein offenes Ereignis geht beim Neuladen der Seite verloren. Der Rest (Position, Inventar, LP …) ist nach jeder Aktion gespeichert.

**Texte in der Datenbank haben keine Umlaute** (ae/oe/ue). Echte Umlaute funktionieren problemlos, SQLite speichert UTF-8. Die aktuelle Schreibweise ist nur eine historische Entscheidung.

---

## 9. Testen

Es gibt keine Unit-Tests. Zum Balancing liegt ein automatischer Spieltest bei: [`tools/bot-playtest.js`](../tools/bot-playtest.js). Er legt einen Charakter an, läuft zufällig durch die Welt, wählt bei Ereignissen die erste verfügbare Option, kämpft, heilt, flieht, rastet und verteilt Punkte. Am Ende gibt er die Statistik aus und speichert einen Screenshot.

Voraussetzung: Node.js und Playwright (`npm install playwright`, danach `npx playwright install chromium`).

```bash
cd EndlessSurvive
dotnet run
```

In einem zweiten Terminal:

```bash
node tools/bot-playtest.js 500
```

Der Test **überschreibt den aktuellen Spielstand**. Beispielausgabe:

```
Kaempfe 25 | Ereignisse 50 | Haendler 1 | Fehler []
Zuege 351 | Besiegte Gegner 16 | Tode 2 | Hoechste Gefahrenstufe 7 | ...
```

Als grobe Orientierung: Viele Tode bei wenigen Siegen bedeuten, dass das Spiel zu schwer ist. Ohne Tode bis Gefahrenstufe 5+ ist es eher zu leicht.
