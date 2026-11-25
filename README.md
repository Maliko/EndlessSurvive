# Endless Survive

Ein Einzelspieler-Browsergame im Endzeit-Setting: Du erwachst in einem Bunker in einer vollständig zerstörten Welt und erkundest eine **unendliche, prozedural erzeugte Karte**. Proben laufen über **Prozentwürfe (W100)**, die Charakterstufen steigen ohne Obergrenze.

**Techstack:** C# / ASP.NET Core 8 / Blazor (Interactive Server), SQLite (Microsoft.Data.Sqlite + Dapper). Die Grafik besteht nur aus HTML, CSS und SVG, es gibt keine Bilddateien.

## Starten

Voraussetzung: [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

```bash
cd EndlessSurvive
dotnet run
```

Dann im Browser **http://localhost:5080** öffnen.

## Spielprinzip

| | |
|---|---|
| **Attribute** | Stärke, Ausdauer, Intelligenz, Gewandtheit |
| **Fertigkeiten** | Nahkampf, Fernkampf, Hacken, Schlösser knacken, Mechanik, Heilung, Überleben, Schleichen, Wahrnehmung, Athletik |
| **Probe** | Fertigkeitswert = 10 % + Attribut × 3 + Rang × 4. Gelingt, wenn W100 ≤ Wert (mindestens 5 %, höchstens 95 %). |
| **Stufen** | Benötigte EP = 100 × Stufe^1,6, endlos. Pro Stufe gibt es Attribut- und Fertigkeitspunkte. |
| **Welt** | Wird aus einem Seed per Value-Noise berechnet (Höhe × Feuchte → Biom). Die Gefahrenstufe steigt mit der Entfernung zum Bunker, und mit ihr Gegner, Beute und Proben. |
| **Orte** | Kisten, Terminals, Leichen, Wracks und Lager liegen fest auf der Karte (`?`-Symbole). Jeder Ort bietet mehrere Optionen mit Fertigkeitsproben. |
| **Begegnungen** | Zufällige Hinterhalte und Wetterereignisse beim Laufen und Rasten |
| **Kampf** | Rundenbasiert: Nahkampf, Fernkampf (mit Munition), Heilen, Fliehen. Ausweichen und Rüstung senken den erlittenen Schaden. |
| **Tod** | Du erwachst wieder im Bunker und verlierst 25 % des EP-Fortschritts der aktuellen Stufe. |

**Steuerung:** WASD/Pfeiltasten oder Klick auf ein Nachbarfeld · `R` rasten (im Bunker: volle Heilung) · `E` Ort untersuchen · `1`–`9` Optionen wählen · `Enter` weiter · `C`/`I`/`J` Reiter wechseln

## Datenbanken

| Datei | Inhalt | Im Repo? |
|---|---|---|
| `EndlessSurvive/Data/content.db` | **Alle Spielinhalte** und Balancing-Werte | ja |
| `EndlessSurvive/Data/content.sql` | Lesbare Quelle, aus der `content.db` erzeugt wurde | ja |
| `EndlessSurvive/Data/save.db` | Spielstand, wird beim ersten Start automatisch angelegt | nein (`.gitignore`) |

Spielstand und Inhalte liegen in getrennten Dateien. So ändert das Spielen nichts an der eingecheckten Inhaltsdatenbank.

## Neue Inhalte hinzufügen

Der Code enthält keine Inhalte, nur Regeln. **Neue Inhalte sind ausschließlich neue Zeilen in `content.db`.** Du kannst die Datei z. B. mit [DB Browser for SQLite](https://sqlitebrowser.org/) bearbeiten. Alternativ änderst du `content.sql`, löschst `content.db` und startest das Spiel neu. Fehlt `content.db`, wird sie beim Start automatisch aus `content.sql` erzeugt.

| Tabelle | Wofür |
|---|---|
| `Settings` | Balancing: XP-Kurve, Probenformel, Gegnerskalierung, Startausrüstung … |
| `Texts` | Intro, Todestext, Titel |
| `Attributes`, `Skills` | Attribute und Fertigkeiten (mit Leitattribut) |
| `Biomes` | Geländetypen: Farbe, SVG-Symbol, Rausch-Bereiche, Gefahrenbonus, Ereignis- und Begegnungsrate, passierbar |
| `Items` | Waffen, Rüstung, Verbrauchsgüter, Munition, mit Seltenheit, Gefahrenbereich und Biomen |
| `Enemies` | Gegner mit Basiswerten, SVG-Icon, Gefahrenbereich und Biomen |
| `Events` + `EventOptions` | Orte (`poi`) und Begegnungen (`encounter`) mit Optionen, Proben und Effekten |
| `Lore` | Infofragmente fürs Journal |

### Effekte in `EventOptions` (Semikolon-getrennt)

```
xp:N             Erfahrung (skaliert mit Gefahrenstufe)
loot:N           N zufällige Gegenstände
lootcat:K:N      N Gegenstände der Kategorie/des Slots K (weapon, armor, consumable, ammo, melee, ranged, body, head)
item:KEY:N       bestimmter Gegenstand
take:KEY:N       Gegenstand abgeben
heal:N | heal:full | heal:pct:N
damage:A-B       Schaden (skaliert mit Gefahrenstufe)
combat:KEY       Kampf gegen bestimmten Gegner, combat:* = passender Zufallsgegner
lore             zufälliges neues Infofragment
reveal:R         Karte im Radius R aufdecken
persist          Ort bleibt auf der Karte (z. B. für "Später wiederkommen")
```

Beispiel für ein neues Ereignis:

```sql
INSERT INTO Events VALUES ('gas_station','Tankstelle','Zapfsäulen ohne Schläuche, ein dunkler Shop.','poi','wasteland,ruins',0,NULL,8,'⛽');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects)
VALUES ('gas_station',1,'Kasse knacken','lockpick',0,1,NULL,'Klick.','loot:2;xp:15','Verklemmt.','xp:2');
```

## Projektstruktur

```
EndlessSurvive/
  Data/                content.db, content.sql (save.db entsteht zur Laufzeit)
  Models/              Abbild der Inhaltstabellen
  Services/
    ContentStore.cs    lädt content.db in den Speicher
    WorldGen.cs        unendliche Welt aus Seed + Koordinaten
    GameService.cs     Spielregeln: Proben, Ereignisse, Effekte, Kampf, Stufen
    SaveStore.cs       Spielstand in save.db
  Components/
    Pages/             Titelbildschirm, Charaktererstellung, Spiel
    Game/              Karte, Dialoge, Charakter, Inventar, Journal, Log
  wwwroot/             app.css, game.js (Tastatur)
```
