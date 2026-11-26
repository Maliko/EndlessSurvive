-- =====================================================================
--  EndlessSurvive - Inhaltsdatenbank (content.db) als SQL
--  Diese Datei wird von der Verwaltung (/admin) bei jeder Aenderung neu
--  geschrieben. Fehlt content.db, wird sie beim Start hieraus erzeugt.
--  Spaltenbeschreibungen: Tabelle _ColumnDocs.
-- =====================================================================
PRAGMA foreign_keys = ON;

-- Regeln & Balancing: Globale Spielregeln als Schlüssel/Wert. Der Code liest die Werte mit einem Fallback, fehlende Einträge brechen also nichts.
CREATE TABLE Settings (
    Key         TEXT PRIMARY KEY,
    Value       TEXT NOT NULL,
    Description TEXT
);
INSERT INTO Settings (Key,Value,Description) VALUES ('XpBase', '100', 'XP fuer Stufe 2. Benoetigte XP je Stufe = XpBase * Stufe^XpExponent');
INSERT INTO Settings (Key,Value,Description) VALUES ('XpExponent', '1.6', 'Exponent der XP-Kurve (endlos steigend)');
INSERT INTO Settings (Key,Value,Description) VALUES ('AttributeStart', '5', 'Startwert jedes Attributs');
INSERT INTO Settings (Key,Value,Description) VALUES ('AttributeCreationPoints', '8', 'Freie Attributpunkte bei Charaktererstellung');
INSERT INTO Settings (Key,Value,Description) VALUES ('AttributeCreationMax', '10', 'Maximalwert eines Attributs bei Charaktererstellung');
INSERT INTO Settings (Key,Value,Description) VALUES ('SkillCreationPoints', '6', 'Freie Fertigkeitspunkte bei Charaktererstellung');
INSERT INTO Settings (Key,Value,Description) VALUES ('AttributePointsPerLevel', '1', 'Attributpunkte pro Stufenaufstieg');
INSERT INTO Settings (Key,Value,Description) VALUES ('SkillPointsPerLevel', '3', 'Fertigkeitspunkte pro Stufenaufstieg');
INSERT INTO Settings (Key,Value,Description) VALUES ('SkillBase', '10', 'Grundwert jeder Fertigkeit in Prozent');
INSERT INTO Settings (Key,Value,Description) VALUES ('SkillPerAttribute', '3', 'Prozentpunkte pro Punkt im Leitattribut');
INSERT INTO Settings (Key,Value,Description) VALUES ('SkillPerRank', '4', 'Prozentpunkte pro Fertigkeitsrang');
INSERT INTO Settings (Key,Value,Description) VALUES ('ChanceMin', '5', 'Minimale Erfolgschance einer Probe');
INSERT INTO Settings (Key,Value,Description) VALUES ('ChanceMax', '95', 'Maximale Erfolgschance einer Probe');
INSERT INTO Settings (Key,Value,Description) VALUES ('HpBase', '20', 'Lebenspunkte Basis');
INSERT INTO Settings (Key,Value,Description) VALUES ('HpPerEndurance', '4', 'Lebenspunkte pro Punkt Ausdauer');
INSERT INTO Settings (Key,Value,Description) VALUES ('HpPerLevel', '3', 'Lebenspunkte pro Stufe');
INSERT INTO Settings (Key,Value,Description) VALUES ('DangerDistance', '8', 'Felder Entfernung vom Bunker pro Gefahrenstufe');
INSERT INTO Settings (Key,Value,Description) VALUES ('DangerCheckPenalty', '2', 'Malus auf Proben pro Gefahrenstufe (bei DangerScaling=1)');
INSERT INTO Settings (Key,Value,Description) VALUES ('EnemyHpPerDanger', '0.22', 'Gegner-LP-Zuwachs je Gefahrenstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('EnemyDamagePerDanger', '0.12', 'Gegner-Schadenszuwachs je Gefahrenstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('EnemyAttackPerDanger', '2', 'Gegner-Angriff (Prozent) je Gefahrenstufe');
INSERT INTO Settings (Key,Value,Description) VALUES ('EnemyXpPerDanger', '0.3', 'Gegner-XP-Zuwachs je Gefahrenstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('ItemDamagePerLevel', '0.15', 'Waffenschaden-Zuwachs je Gegenstandsstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('ItemArmorPerLevel', '0.5', 'Ruestung je Gegenstandsstufe');
INSERT INTO Settings (Key,Value,Description) VALUES ('EventXpPerDanger', '0.25', 'Ereignis-XP-Zuwachs je Gefahrenstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('SightRadius', '2', 'Sichtweite in Feldern');
INSERT INTO Settings (Key,Value,Description) VALUES ('DodgePerAgility', '2', 'Ausweichen (Prozent) pro Punkt Gewandtheit');
INSERT INTO Settings (Key,Value,Description) VALUES ('MeleeStrengthDivisor', '2', 'Nahkampf-Bonusschaden = Staerke / Wert');
INSERT INTO Settings (Key,Value,Description) VALUES ('FleeBase', '25', 'Basis-Fluchtchance');
INSERT INTO Settings (Key,Value,Description) VALUES ('AttackBonus', '15', 'Bonus auf eigene Angriffsproben im Kampf (Prozent)');
INSERT INTO Settings (Key,Value,Description) VALUES ('StartBiome', 'bunker', 'Biom des Startfeldes');
INSERT INTO Settings (Key,Value,Description) VALUES ('SafeRadius', '2', 'Radius um den Bunker ohne unpassierbares Gelaende und Begegnungen');
INSERT INTO Settings (Key,Value,Description) VALUES ('RestEncounterFactor', '2.5', 'Begegnungsrisiko beim Rasten im Freien (Faktor auf Biom-Wert)');
INSERT INTO Settings (Key,Value,Description) VALUES ('DeathXpLossPercent', '25', 'Verlust des XP-Fortschritts der aktuellen Stufe beim Tod');
INSERT INTO Settings (Key,Value,Description) VALUES ('ItemValuePerLevel', '0.25', 'Tauschwert-Zuwachs je Gegenstandsstufe (Faktor)');
INSERT INTO Settings (Key,Value,Description) VALUES ('StartItems', 'pipe:1;medkit_small:2;rags:1', 'Startausruestung key:Anzahl');
INSERT INTO Settings (Key,Value,Description) VALUES ('DungeonChance', '0.006', 'Anteil der Felder mit einem Ruineneingang (0–1)');
INSERT INTO Settings (Key,Value,Description) VALUES ('DungeonSightRadius', '3', 'Sichtweite in Ruinen');

-- Texte: Feste Texte: Titel, Intro, Tod, Stufenaufstieg.
CREATE TABLE Texts (
    Key  TEXT PRIMARY KEY,
    Text TEXT NOT NULL
);
INSERT INTO Texts (Key,Text) VALUES ('title', 'ENDLESS SURVIVE');
INSERT INTO Texts (Key,Text) VALUES ('subtitle', 'Die Welt ist vorbei. Du bist es noch nicht.');
INSERT INTO Texts (Key,Text) VALUES ('intro', 'Ein Summen. Notbeleuchtung, rot und flackernd. Die Kryokapsel oeffnet sich mit einem Zischen, und kalte, abgestandene Luft fuellt deine Lungen. Die anderen Kapseln sind leer – oder schlimmer. Auf dem Terminal blinkt nur ein Datum, das keinen Sinn ergibt, und ein Wort: AUSGANG. Die schwere Bunkertuer steht einen Spalt offen. Dahinter: Asche, Ruinen, Stille.');
INSERT INTO Texts (Key,Text) VALUES ('death', 'Dunkelheit. Dann wieder das rote Flackern. Irgendwie hast du es zurueck in den Bunker geschafft – oder jemand hat dich hergebracht. Dein Koerper schmerzt, deine Erinnerungen an die letzten Stunden sind luekenhaft.');
INSERT INTO Texts (Key,Text) VALUES ('bunker', 'Der Bunker. Dicke Betonwaende, ein surrender Generator, deine Kapsel. Hier bist du sicher.');
INSERT INTO Texts (Key,Text) VALUES ('levelup', 'Du fuehlst dich staerker. Die Oednis formt dich.');

-- Infofragmente: Infofetzen fürs Journal. Werden über den Effekt lore gefunden, Fragmente mit niedriger MinDanger bevorzugt.
CREATE TABLE Lore (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    Title     TEXT NOT NULL,
    Text      TEXT NOT NULL,
    MinDanger INTEGER NOT NULL DEFAULT 0
);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (1, 'Notiz, zerknittert', '"Tag 3. Die Sirenen haben aufgehoert. Nicht weil es vorbei ist, sondern weil niemand mehr da ist, der sie bedient."', 0);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (2, 'Einkaufsliste', 'Milch. Brot. Jodtabletten (!!!). Batterien. Mama anrufen.', 0);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (3, 'Kinderzeichnung', 'Ein Haus, eine Sonne, vier Strichmaennchen. Die Sonne wurde spaeter mit rotem Stift uebermalt.', 0);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (4, 'Radioprotokoll 07', '"...wiederhole: Alle Buerger der Zone 4 begeben sich unverzueglich in die zugewiesenen Schutzanlagen. Dies ist keine Uebung..."', 0);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (5, 'Bunker-Handbuch, S. 12', '"Die Kryostase ist auf eine Dauer von maximal 18 Monaten ausgelegt. Bei Ueberschreitung koennen Gedaechtnisstoerungen auftreten."', 0);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (6, 'Tagebuch eines Soldaten', '"Sie sagen, es war ein Unfall. Ein Fehler im Fruehwarnsystem. Aber ich habe die Befehle gesehen. Die Befehle waren eindeutig."', 1);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (7, 'Graffito', 'DIE ASCHE ERINNERT SICH AN ALLES.', 1);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (8, 'Laborbericht (Fragment)', '"Projekt LAZARUS: Proband 14 zeigt nach 9 Jahren Kryostase keine kognitiven Ausfaelle. Empfehlung: Fortsetzung bis zur Bewohnbarkeit."', 1);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (9, 'Brief, nie abgeschickt', '"Liebe Ann, wenn du das liest, bin ich nicht in den Bunker gekommen. Es waren zu wenig Plaetze. Ich habe meinen dem Jungen von nebenan gegeben."', 1);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (10, 'Wartungslog', '"Generator 2 ausgefallen. Kapseln 1-11 auf Notstrom umgestellt. Kapsel 12 reagiert nicht. Kapsel 12 ist..." – der Rest ist unleserlich.', 2);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (11, 'Zettel an einer Tuer', '"KEIN WASSER. KEINE MEDIZIN. NICHTS ZU HOLEN. GEHT WEITER."', 2);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (12, 'Funkspruch, Aufzeichnung', '"Hier spricht Haven. Wir sind 40 Menschen. Wir haben Wasser. Folgt dem Fluss nach Norden..." Die Aufzeichnung ist Jahrzehnte alt.', 2);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (13, 'Militaerbefehl', '"Einsatzgruppe Sigma sichert die Kryoanlagen. Ueberlebende Zivilisten sind nicht einzulassen. Prioritaet: Projekt LAZARUS."', 3);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (14, 'Tagebuch, letzte Seite', '"Die Ghule waren einmal Menschen. Ich habe meinen Nachbarn erkannt. Er hat mich auch erkannt. Er hat trotzdem angegriffen."', 3);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (15, 'Wissenschaftliche Notiz', '"Die Mutationen folgen einem Muster. Das ist keine Strahlung allein. Jemand hat nachgeholfen."', 4);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (16, 'Logbuch Kapsel-Bunker 7', '"Du bist nicht der erste, der aufwacht. Und nicht der letzte. Die Anlage weckt uns einzeln, wenn die Werte stimmen. Sie stimmen nie."', 4);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (17, 'Zerrissenes Foto', 'Eine Gruppe Menschen in weissen Kitteln vor einem Bunkereingang. Einer von ihnen sieht dir verblueffend aehnlich.', 5);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (18, 'Terminal-Ausdruck', '"LAZARUS PROBAND 23 – STATUS: ERWACHT. AUFTRAG: KARTOGRAFIERUNG. ERWARTETE UEBERLEBENSDAUER: 14 TAGE."', 6);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (19, 'Stimme auf Band', '"Wenn du das hoerst, bist du weiter gekommen als alle anderen. Geh weiter. Irgendwo am Ende ist etwas. Muss es sein."', 7);
INSERT INTO Lore (Id,Title,Text,MinDanger) VALUES (20, 'Inschrift im Fels', 'ES GIBT KEIN ENDE. NUR DEN NAECHSTEN SCHRITT.', 9);

-- Attribute: Die Grundwerte des Charakters. Die Keys str, end, agi werden vom Code benutzt.
CREATE TABLE Attributes (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Abbrev      TEXT NOT NULL,
    Description TEXT,
    SortOrder   INTEGER NOT NULL DEFAULT 0
);
INSERT INTO Attributes (Key,Name,Abbrev,Description,SortOrder) VALUES ('str', 'Staerke', 'STR', 'Rohe Kraft. Erhoeht Nahkampfschaden und Nahkampf.', 1);
INSERT INTO Attributes (Key,Name,Abbrev,Description,SortOrder) VALUES ('end', 'Ausdauer', 'AUS', 'Zaehigkeit. Erhoeht Lebenspunkte und Ueberleben.', 2);
INSERT INTO Attributes (Key,Name,Abbrev,Description,SortOrder) VALUES ('int', 'Intelligenz', 'INT', 'Verstand. Grundlage fuer Hacken, Heilung und Wahrnehmung.', 3);
INSERT INTO Attributes (Key,Name,Abbrev,Description,SortOrder) VALUES ('agi', 'Gewandtheit', 'GEW', 'Geschick und Reflexe. Ausweichen, Fernkampf, Schloesser.', 4);

-- Fertigkeiten: Fertigkeiten mit Leitattribut. Die Keys melee, ranged, healing, stealth, perception werden vom Code benutzt.
CREATE TABLE Skills (
    Key          TEXT PRIMARY KEY,
    Name         TEXT NOT NULL,
    AttributeKey TEXT NOT NULL REFERENCES Attributes(Key),
    Category     TEXT NOT NULL,
    Description  TEXT,
    SortOrder    INTEGER NOT NULL DEFAULT 0
);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('melee', 'Nahkampf', 'str', 'Kampf', 'Treffen mit Klingen, Knueppeln und Faeusten.', 1);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('ranged', 'Fernkampf', 'agi', 'Kampf', 'Treffen mit Boegen, Pistolen und Gewehren.', 2);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('hacking', 'Hacken', 'int', 'Technik', 'Alte Terminals und Sicherheitssysteme ueberlisten.', 3);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('lockpick', 'Schloesser knacken', 'agi', 'Technik', 'Tueren, Kisten und Spinde oeffnen.', 4);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('mechanics', 'Mechanik', 'int', 'Technik', 'Maschinen reparieren, Fallen entschaerfen.', 5);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('healing', 'Heilung', 'int', 'Ueberleben', 'Wunden versorgen. Verbessert Heilgegenstaende und Rasten.', 6);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('survival', 'Ueberleben', 'end', 'Ueberleben', 'Nahrung finden, Wetter trotzen, Spuren lesen.', 7);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('stealth', 'Schleichen', 'agi', 'Ueberleben', 'Ungesehen bleiben. Hilft bei Flucht und Hinterhalten.', 8);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('perception', 'Wahrnehmung', 'int', 'Ueberleben', 'Verborgenes entdecken, Gefahren frueh erkennen.', 9);
INSERT INTO Skills (Key,Name,AttributeKey,Category,Description,SortOrder) VALUES ('athletics', 'Athletik', 'str', 'Ueberleben', 'Klettern, Springen, Schweres heben.', 10);

-- Biome: Geländetypen. Die Welt entsteht aus zwei Rauschwerten (Höhe, Feuchte, 0–1); das passende Biom mit der höchsten Priority gewinnt.
CREATE TABLE Biomes (
    Key             TEXT PRIMARY KEY,
    Name            TEXT NOT NULL,
    Description     TEXT,
    Color           TEXT NOT NULL,
    AccentColor     TEXT NOT NULL,
    Glyph           TEXT,
    HeightMin       REAL,
    HeightMax       REAL,
    MoistMin        REAL,
    MoistMax        REAL,
    Priority        INTEGER NOT NULL DEFAULT 0,
    DangerBonus     INTEGER NOT NULL DEFAULT 0,
    EventChance     REAL NOT NULL DEFAULT 0.1,
    EncounterChance REAL NOT NULL DEFAULT 0.05,
    Passable        INTEGER NOT NULL DEFAULT 1,
    Generated       INTEGER NOT NULL DEFAULT 1
);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('bunker', 'Bunker', 'Dein Zuhause. Sicher, kalt, still.', '#3a3f47', '#f2b43a', '<rect x="10" y="14" width="28" height="22" rx="3" fill="#23272e" stroke="#f2b43a" stroke-width="2"/><circle cx="24" cy="25" r="6" fill="none" stroke="#f2b43a" stroke-width="2"/><path d="M24 19v12M18 25h12" stroke="#f2b43a" stroke-width="1.5"/>', NULL, NULL, NULL, NULL, 0, 0, 0, 0, 1, 0);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('wasteland', 'Oedland', 'Rissige Erde, so weit das Auge reicht.', '#6b5d4a', '#8a7a62', '<circle cx="12" cy="14" r="1.4" fill="#8a7a62"/><circle cx="34" cy="30" r="1.2" fill="#8a7a62"/><path d="M8 36l6-3 4 4" stroke="#4f4436" fill="none"/><path d="M28 12l5 2 3-3" stroke="#4f4436" fill="none"/>', 0, 1, 0, 1, 0, 0, 0.1, 0.06, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('ashdesert', 'Aschewueste', 'Graue Duenen aus Asche. Der Wind heult.', '#8d867b', '#a9a296', '<path d="M4 30q10-8 20 0t20 0" stroke="#a9a296" stroke-width="2" fill="none"/><path d="M8 18q8-6 16 0t16 0" stroke="#787266" stroke-width="1.5" fill="none"/>', 0.42, 0.78, 0, 0.32, 10, 0, 0.08, 0.07, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('ruins', 'Truemmerstadt', 'Skelette von Hochhaeusern, eingestuerzte Strassen.', '#4d4f55', '#6e7179', '<rect x="8" y="18" width="9" height="22" fill="#6e7179"/><rect x="20" y="10" width="10" height="30" fill="#5c5f66"/><rect x="33" y="22" width="8" height="18" fill="#6e7179"/><rect x="22" y="14" width="2" height="3" fill="#2f3136"/><rect x="26" y="20" width="2" height="3" fill="#2f3136"/><path d="M30 10l3 5" stroke="#3b3d42" stroke-width="2"/>', 0.42, 0.75, 0.32, 0.65, 10, 0, 0.14, 0.08, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('deadforest', 'Toter Wald', 'Schwarze Baumstuempfe, knisterndes Unterholz.', '#3e3a2c', '#5a5340', '<path d="M14 40V18M14 24l-5-5M14 28l5-4" stroke="#1f1c14" stroke-width="2.5" fill="none"/><path d="M32 40V12M32 18l6-5M32 26l-6-4M32 32l5-2" stroke="#26221a" stroke-width="2.5" fill="none"/>', 0.42, 0.78, 0.65, 1, 10, 0, 0.13, 0.09, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('swamp', 'Giftsumpf', 'Bruehe in unnatuerlichem Gruen. Blasen steigen auf.', '#3d5236', '#6f9a3a', '<ellipse cx="16" cy="20" rx="8" ry="3" fill="#6f9a3a" opacity=".7"/><ellipse cx="32" cy="34" rx="10" ry="3.5" fill="#6f9a3a" opacity=".6"/><circle cx="30" cy="16" r="1.8" fill="#a9d35a"/><circle cx="12" cy="34" r="1.2" fill="#a9d35a"/>', 0.22, 0.42, 0.55, 1, 20, 1, 0.12, 0.1, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('scrapyard', 'Industriebrache', 'Rostige Tanks, Kraene und Schrottberge.', '#5e4130', '#9a5b34', '<rect x="7" y="22" width="14" height="18" rx="2" fill="#7d4a2b"/><ellipse cx="14" cy="22" rx="7" ry="2.5" fill="#b06a3c"/><path d="M28 40V12h4v28M32 12h12v4M42 16v6" stroke="#b06a3c" stroke-width="2" fill="none"/><path d="M28 18l4 6M32 18l-4 6M28 28l4 6M32 28l-4 6" stroke="#9a5b34"/>', 0.22, 0.42, 0, 0.55, 20, 1, 0.13, 0.08, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('craters', 'Kraterfeld', 'Bombenkrater, glasiger Boden, Strahlung.', '#2f2b2e', '#59505a', '<circle cx="18" cy="20" r="9" fill="#1f1c1f" stroke="#59505a" stroke-width="2"/><circle cx="34" cy="34" r="6" fill="#1f1c1f" stroke="#59505a" stroke-width="1.5"/>', 0.78, 0.9, 0, 1, 30, 2, 0.15, 0.12, 1, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('mountains', 'Felsgrat', 'Zerklueftete Felsen. Kein Durchkommen.', '#28262a', '#4a464e', '<path d="M4 40l12-24 8 12 6-8 14 20z" fill="#4a464e"/><path d="M16 16l3 6-3-1-3 2z" fill="#8f8a94"/>', 0.9, 1, 0, 1, 40, 0, 0, 0, 0, 1);
INSERT INTO Biomes (Key,Name,Description,Color,AccentColor,Glyph,HeightMin,HeightMax,MoistMin,MoistMax,Priority,DangerBonus,EventChance,EncounterChance,Passable,Generated) VALUES ('lake', 'Verstrahlter See', 'Schillerndes, totes Wasser. Unpassierbar.', '#1c3a3f', '#2e6b70', '<path d="M6 18q6-4 12 0t12 0t12 0" stroke="#3f8d8f" stroke-width="1.5" fill="none"/><path d="M6 32q6-4 12 0t12 0t12 0" stroke="#2e6b70" stroke-width="1.5" fill="none"/>', 0, 0.22, 0, 1, 40, 0, 0, 0, 0, 1);

-- Gegenstände: Waffen, Rüstung, Verbrauchsgüter und Munition.
CREATE TABLE Items (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Description TEXT,
    Category    TEXT NOT NULL,
    Slot        TEXT,
    SkillKey    TEXT REFERENCES Skills(Key),
    DamageMin   INTEGER NOT NULL DEFAULT 0,
    DamageMax   INTEGER NOT NULL DEFAULT 0,
    Armor       INTEGER NOT NULL DEFAULT 0,
    HealMin     INTEGER NOT NULL DEFAULT 0,
    HealMax     INTEGER NOT NULL DEFAULT 0,
    AmmoKey     TEXT,
    Rarity      INTEGER NOT NULL DEFAULT 10,
    MinDanger   INTEGER NOT NULL DEFAULT 0,
    MaxDanger   INTEGER,
    Biomes      TEXT NOT NULL DEFAULT '*',
    Scales      INTEGER NOT NULL DEFAULT 0,
    Color       TEXT NOT NULL DEFAULT '#cccccc',
    Value       INTEGER NOT NULL DEFAULT 0   -- interner Tauschwert (Stufe 0)
);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('pipe', 'Bleirohr', 'Schwer, verbogen, verlaesslich.', 'weapon', 'melee', 'melee', 2, 5, 0, 0, 0, NULL, 12, 0, 4, '*', 1, '#b0b4ba', 8);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('knife', 'Kampfmesser', 'Rostige Klinge mit Profil.', 'weapon', 'melee', 'melee', 3, 5, 0, 0, 0, NULL, 10, 0, 6, '*', 1, '#d0d4da', 10);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('machete', 'Machete', 'Gut fuer Gestruepp und Haelse.', 'weapon', 'melee', 'melee', 4, 8, 0, 0, 0, NULL, 8, 2, NULL, 'deadforest,swamp,wasteland', 1, '#d8d0b0', 18);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('sledge', 'Vorschlaghammer', 'Langsam. Endgueltig.', 'weapon', 'melee', 'melee', 5, 11, 0, 0, 0, NULL, 6, 3, NULL, 'scrapyard,ruins', 1, '#a08a70', 24);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('rebarclub', 'Moniereisen-Keule', 'Beton noch dran.', 'weapon', 'melee', 'melee', 4, 9, 0, 0, 0, NULL, 8, 1, NULL, 'ruins,scrapyard', 1, '#8f8f8f', 16);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('chainblade', 'Kettensaegenklinge', 'Laut, hungrig, unaufhaltsam.', 'weapon', 'melee', 'melee', 8, 15, 0, 0, 0, NULL, 3, 6, NULL, '*', 1, '#e05a3a', 60);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('slingshot', 'Schleuder', 'Kinderspielzeug, toedlich mit Muttern.', 'weapon', 'ranged', 'ranged', 2, 4, 0, 0, 0, NULL, 10, 0, 4, '*', 1, '#c9a56a', 8);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('bow', 'Rohrbogen', 'Aus Kunststoffrohr und Draht.', 'weapon', 'ranged', 'ranged', 3, 7, 0, 0, 0, 'arrows', 8, 1, NULL, 'deadforest,wasteland', 1, '#a0784a', 20);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('pistol', '9mm Pistole', 'Abgegriffen, aber funktionsfaehig.', 'weapon', 'ranged', 'ranged', 5, 9, 0, 0, 0, 'ammo9', 6, 2, NULL, 'ruins,scrapyard,craters', 1, '#7a7f88', 35);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('shotgun', 'Schrotflinte', 'Zwei Laeufe, kein Pardon.', 'weapon', 'ranged', 'ranged', 7, 14, 0, 0, 0, 'shells', 4, 4, NULL, '*', 1, '#6a5a4a', 50);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('rifle', 'Jagdgewehr', 'Zielfernrohr mit Sprung.', 'weapon', 'ranged', 'ranged', 9, 16, 0, 0, 0, 'ammo762', 3, 6, NULL, '*', 1, '#5a6a5a', 65);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('arrows', 'Pfeile', 'Gebuendelt, selbstgemacht.', 'ammo', NULL, NULL, 0, 0, 0, 0, 0, NULL, 12, 1, NULL, '*', 0, '#c0a070', 1);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('ammo9', '9mm Patronen', 'Eine Handvoll Messing.', 'ammo', NULL, NULL, 0, 0, 0, 0, 0, NULL, 10, 2, NULL, '*', 0, '#d8b84a', 2);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('shells', 'Schrotpatronen', 'Rote Huelsen.', 'ammo', NULL, NULL, 0, 0, 0, 0, 0, NULL, 8, 4, NULL, '*', 0, '#c04a3a', 3);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('ammo762', '7.62 Patronen', 'Lang und schwer.', 'ammo', NULL, NULL, 0, 0, 0, 0, 0, NULL, 6, 6, NULL, '*', 0, '#b8a04a', 4);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('rags', 'Lumpenkleidung', 'Besser als nichts.', 'armor', 'body', NULL, 0, 0, 1, 0, 0, NULL, 10, 0, 3, '*', 1, '#8a7a6a', 3);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('leather', 'Lederjacke', 'Zerkratzt, aber zaeh.', 'armor', 'body', NULL, 0, 0, 2, 0, 0, NULL, 8, 1, NULL, '*', 1, '#7a4a2a', 15);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('scrapmail', 'Schrottpanzer', 'Blechplatten, zusammengenietet.', 'armor', 'body', NULL, 0, 0, 4, 0, 0, NULL, 5, 3, NULL, 'scrapyard,ruins', 1, '#8a8a7a', 30);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('kevlar', 'Kevlarweste', 'Militaerbestand.', 'armor', 'body', NULL, 0, 0, 5, 0, 0, NULL, 3, 5, NULL, '*', 1, '#4a5a4a', 45);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('cap', 'Wollmuetze', 'Haelt warm.', 'armor', 'head', NULL, 0, 0, 0, 0, 0, NULL, 6, 0, 3, '*', 1, '#6a6a8a', 4);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('helmet', 'Bauhelm', 'Gelb und verbeult.', 'armor', 'head', NULL, 0, 0, 1, 0, 0, NULL, 6, 1, NULL, 'ruins,scrapyard', 1, '#e0c040', 10);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('gasmask', 'Gasmaske', 'Filter fast leer.', 'armor', 'head', NULL, 0, 0, 2, 0, 0, NULL, 4, 2, NULL, 'swamp,craters,scrapyard', 1, '#5a6a5a', 18);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('medkit_small', 'Verbandspaeckchen', 'Mull und Desinfektion.', 'consumable', NULL, NULL, 0, 0, 0, 6, 10, NULL, 14, 0, NULL, '*', 0, '#e8e8e8', 6);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('medkit', 'Erste-Hilfe-Kasten', 'Komplett. Fast.', 'consumable', NULL, NULL, 0, 0, 0, 14, 24, NULL, 8, 2, NULL, '*', 0, '#e04040', 15);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('stimpak', 'Stimpak', 'Injektion. Wirkt sofort.', 'consumable', NULL, NULL, 0, 0, 0, 30, 50, NULL, 4, 5, NULL, '*', 0, '#40c0e0', 35);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('cannedfood', 'Konservendose', 'Bohnen. Ablaufdatum: egal.', 'consumable', NULL, NULL, 0, 0, 0, 3, 6, NULL, 14, 0, NULL, '*', 0, '#c0a040', 4);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('water', 'Gefiltertes Wasser', 'Fast klar.', 'consumable', NULL, NULL, 0, 0, 0, 2, 5, NULL, 12, 0, NULL, '*', 0, '#60a0e0', 3);
INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color,Value) VALUES ('mutfruit', 'Mutantenfrucht', 'Leuchtet leicht. Schmeckt suess.', 'consumable', NULL, NULL, 0, 0, 0, 4, 12, NULL, 8, 1, NULL, 'swamp,deadforest', 0, '#a0e040', 5);

-- Gegner: Gegnerwerte gelten für ihre MinDanger und wachsen mit der Gefahrenstufe (siehe Settings).
CREATE TABLE Enemies (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Description TEXT,
    Hp          INTEGER NOT NULL,
    Attack      INTEGER NOT NULL,
    Defense     INTEGER NOT NULL,
    DamageMin   INTEGER NOT NULL,
    DamageMax   INTEGER NOT NULL,
    Armor       INTEGER NOT NULL DEFAULT 0,
    Xp          INTEGER NOT NULL,
    MinDanger   INTEGER NOT NULL DEFAULT 0,
    MaxDanger   INTEGER,
    Biomes      TEXT NOT NULL DEFAULT '*',
    Weight      INTEGER NOT NULL DEFAULT 10,
    LootChance  REAL NOT NULL DEFAULT 0.3,
    Color       TEXT NOT NULL DEFAULT '#c04040',
    Icon        TEXT
);
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('rat', 'Riesenratte', 'Groesser als ein Hund, haessliche Zaehne.', 8, 45, 0, 1, 3, 0, 12, 0, 5, '*', 14, 0.15, '#8a6a5a', '<ellipse cx="34" cy="38" rx="18" ry="11" fill="currentColor"/><circle cx="16" cy="32" r="8" fill="currentColor"/><circle cx="12" cy="30" r="1.8" fill="#ff4040"/><path d="M50 40q10 4 8 14" stroke="currentColor" stroke-width="2.5" fill="none"/><path d="M10 36l-3 3M12 37l-1 4" stroke="#eee" stroke-width="1.5"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('dog', 'Wilder Hund', 'Abgemagert, rasend vor Hunger.', 12, 50, 5, 2, 4, 0, 18, 0, 6, 'wasteland,deadforest,ruins,ashdesert', 10, 0.1, '#7a6040', '<path d="M12 30l8-10 6 6h18l8 6v14h-4v-8H24v8h-4V36z" fill="currentColor"/><circle cx="18" cy="26" r="1.6" fill="#ff5030"/><path d="M52 32l8-6" stroke="currentColor" stroke-width="3"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('scav', 'Pluenderer', 'Ein Mensch. Oder was davon uebrig ist.', 16, 50, 5, 2, 6, 1, 25, 0, NULL, 'ruins,scrapyard,wasteland,ashdesert', 10, 0.6, '#b07050', '<circle cx="32" cy="16" r="8" fill="currentColor"/><path d="M20 58V32q0-6 12-6t12 6v26h-6V42h-12v16z" fill="currentColor"/><rect x="26" y="13" width="12" height="4" fill="#222"/><path d="M44 30l10-10" stroke="#aaa" stroke-width="3"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('ghoul', 'Ghul', 'Verstrahlte Haut, leere Augen, schnelle Beine.', 18, 55, 5, 3, 6, 0, 30, 1, NULL, 'craters,ruins,swamp', 9, 0.25, '#7a9a5a', '<circle cx="32" cy="16" r="9" fill="currentColor"/><circle cx="28" cy="15" r="2" fill="#ff0"/><circle cx="36" cy="15" r="2" fill="#ff0"/><path d="M22 58l4-30h12l4 30M22 32l-10 12M42 32l10 12" stroke="currentColor" stroke-width="5" fill="none"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('swamper', 'Sumpfkriecher', 'Etwas mit zu vielen Beinen.', 20, 50, 0, 3, 7, 2, 32, 1, NULL, 'swamp', 10, 0.2, '#5a8a3a', '<ellipse cx="32" cy="34" rx="16" ry="12" fill="currentColor"/><path d="M18 30l-12-8M18 38l-12 4M46 30l12-8M46 38l12 4M24 44l-6 12M40 44l6 12" stroke="currentColor" stroke-width="3"/><circle cx="26" cy="28" r="2.5" fill="#f60"/><circle cx="38" cy="28" r="2.5" fill="#f60"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('drone', 'Wachdrohne', 'Sie hat ihren Befehl nie vergessen.', 14, 55, 15, 3, 6, 3, 35, 2, NULL, 'ruins,scrapyard,craters', 7, 0.5, '#8a9aaa', '<ellipse cx="32" cy="32" rx="12" ry="8" fill="currentColor"/><circle cx="32" cy="33" r="4" fill="#f22"/><path d="M8 22h16M40 22h16M16 22v6M48 22v6" stroke="currentColor" stroke-width="3"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('raider', 'Rumtreiber', 'Bewaffnet, organisiert, gnadenlos.', 24, 58, 10, 4, 8, 2, 45, 3, NULL, '*', 8, 0.7, '#c05030', '<circle cx="32" cy="15" r="8" fill="currentColor"/><path d="M18 58V30q0-6 14-6t14 6v28h-7V42H25v16z" fill="currentColor"/><path d="M24 10l16 0l-2-6h-12z" fill="#333"/><path d="M46 34h14" stroke="#555" stroke-width="4"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('mutant', 'Mutant', 'Zwei Meter Muskeln und Wut.', 40, 55, 0, 6, 12, 3, 70, 4, NULL, 'craters,ashdesert,swamp,wasteland', 6, 0.5, '#9a6aa0', '<circle cx="32" cy="14" r="9" fill="currentColor"/><path d="M12 58l6-34q14-6 28 0l6 34h-10l-4-18h-12l-4 18z" fill="currentColor"/><path d="M14 28l-6 14M50 28l6 14" stroke="currentColor" stroke-width="7"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('sentry', 'Kampfroboter', 'Rost auf Panzerstahl. Rote Optik.', 45, 62, 10, 6, 11, 6, 90, 5, NULL, 'ruins,scrapyard,craters', 5, 0.6, '#a0a8b0', '<rect x="18" y="8" width="28" height="18" rx="3" fill="currentColor"/><rect x="24" y="14" width="16" height="5" fill="#f22"/><rect x="14" y="28" width="36" height="20" fill="currentColor"/><path d="M20 48v12M44 48v12M14 34H4M50 34h10" stroke="currentColor" stroke-width="5"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('ashwyrm', 'Aschewurm', 'Bricht aus dem Boden wie ein Zug.', 60, 60, 0, 8, 15, 4, 120, 6, NULL, 'ashdesert,craters', 3, 0.4, '#c0b0a0', '<path d="M6 58q8-30 26-30t26 30" stroke="currentColor" stroke-width="14" fill="none"/><circle cx="32" cy="22" r="11" fill="currentColor"/><path d="M24 22h16" stroke="#300" stroke-width="4"/><path d="M26 19l2 6 2-6 2 6 2-6 2 6" stroke="#fff" stroke-width="1" fill="none"/>');
INSERT INTO Enemies (Key,Name,Description,Hp,Attack,Defense,DamageMin,DamageMax,Armor,Xp,MinDanger,MaxDanger,Biomes,Weight,LootChance,Color,Icon) VALUES ('behemoth', 'Behemoth', 'Die Erde bebt bei jedem Schritt.', 90, 65, 0, 10, 20, 6, 200, 9, NULL, '*', 2, 0.9, '#a04040', '<path d="M6 56l6-30q20-16 40 0l6 30h-12l-4-14H22l-4 14z" fill="currentColor"/><circle cx="24" cy="26" r="3" fill="#ff0"/><circle cx="40" cy="26" r="3" fill="#ff0"/><path d="M14 18l-6-10M50 18l6-10" stroke="currentColor" stroke-width="5"/>');

-- Ereignisse: Orte auf der Karte (poi) und zufällige Begegnungen (encounter). Die Optionen stehen in Ereignis-Optionen.
CREATE TABLE Events (
    Key        TEXT PRIMARY KEY,
    Title      TEXT NOT NULL,
    Text       TEXT NOT NULL,
    Kind       TEXT NOT NULL DEFAULT 'poi',
    Biomes     TEXT NOT NULL DEFAULT '*',
    MinDanger  INTEGER NOT NULL DEFAULT 0,
    MaxDanger  INTEGER,
    Weight     INTEGER NOT NULL DEFAULT 10,
    Marker     TEXT NOT NULL DEFAULT '?'
);
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('supply_crate', 'Verschlossene Kiste', 'Eine olivgruene Militaerkiste, halb im Schutt vergraben. Ein schweres Vorhaengeschloss haelt sie zu.', 'poi', '*', 0, NULL, 12, '▣');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('terminal', 'Altes Terminal', 'Ein Bildschirm flackert in einem halb eingestuerzten Kontrollraum. Der Cursor blinkt. PASSWORT:', 'poi', 'ruins,scrapyard,craters', 0, NULL, 10, '⌨');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('corpse', 'Leiche', 'Ein ausgetrockneter Koerper in zerrissener Kleidung. Der Rucksack ist noch da.', 'poi', '*', 0, NULL, 14, '✝');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('pharmacy', 'Pluenderte Apotheke', 'Das gruene Kreuz ist kaum noch zu erkennen. Regale umgeworfen, Glas ueberall.', 'poi', 'ruins', 0, NULL, 8, '✚');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('car_wreck', 'Autowrack', 'Ein ausgebrannter Kombi. Der Kofferraum ist verbeult, aber geschlossen.', 'poi', 'wasteland,ashdesert,ruins', 0, NULL, 12, '⛍');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('radio_tower', 'Funkmast', 'Ein verbogener Mast ragt in den Himmel. Unten ein Schaltkasten, oben eine Plattform.', 'poi', 'wasteland,ruins,craters,ashdesert', 0, NULL, 6, '⚡');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('nest', 'Nest', 'Knochen, Fell und ein ekelhafter Gestank. Etwas lebt hier. Daneben liegen die Habseligkeiten frueherer Opfer.', 'poi', '*', 0, NULL, 10, '☠');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('vault_door', 'Versiegelte Schleuse', 'Eine runde Stahltuer im Hang, wie die deines Bunkers. Ein Ziffernblock leuchtet schwach.', 'poi', 'craters,ruins,wasteland', 2, NULL, 4, '◉');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('campfire', 'Verlassenes Lager', 'Ein Zelt, eine kalte Feuerstelle. Wer immer hier war, ist ueberstuerzt aufgebrochen.', 'poi', 'wasteland,deadforest,ashdesert', 0, NULL, 10, '▲');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('toxic_pool', 'Leuchtender Tuempel', 'Ein Tuempel, der von innen gruen gluht. Am Grund glitzert Metall.', 'poi', 'swamp,craters', 0, NULL, 10, '☢');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('tripwire', 'Stolperdraht', 'Fast haettest du ihn uebersehen: ein Draht, knoechelhoch, fuehrt zu einer Granate.', 'poi', 'ruins,scrapyard,wasteland,deadforest', 1, NULL, 8, '⚠');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('bunker_ruin', 'Eingestuerzter Bunker', 'Ein anderer Bunker. Die Decke ist eingebrochen, aber ein Lueftungsschacht fuehrt hinein.', 'poi', '*', 1, NULL, 5, '⌂');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('scrapheap', 'Schrotthaufen', 'Ein Berg aus Metall, Kabeln und Plastik. Irgendwo darin ist sicher etwas Nuetzliches.', 'poi', 'scrapyard,ruins', 0, NULL, 12, '⚙');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('survivor', 'Ueberlebender', 'Ein abgemagerter Mann hockt an einer Mauer, die Haende erhoben. "Bitte... ich will nur Wasser."', 'poi', '*', 0, NULL, 6, '☺');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('hunter_blind', 'Jaegerstand', 'Ein Hochsitz am Rand des toten Waldes. Er sieht stabil aus.', 'poi', 'deadforest,wasteland', 0, NULL, 8, '⌖');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('crashed_heli', 'Abgestuerzter Hubschrauber', 'Ein Militaerhubschrauber, die Rotoren verbogen. Das Cockpit ist intakt.', 'poi', '*', 3, NULL, 4, '✈');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('graffiti', 'Botschaft an der Wand', 'Riesige Buchstaben, mit Farbe auf eine Hauswand gesprueht.', 'poi', 'ruins,scrapyard', 0, NULL, 7, '✎');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('glowing_tree', 'Leuchtender Baum', 'Ein toter Baum, an dessen Aesten seltsame Fruechte haengen, die schwach leuchten.', 'poi', 'deadforest,swamp', 0, NULL, 7, '❦');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('raider_camp', 'Rumtreiber-Lager', 'Rauch, Gelaechter, Metallmusik. Ein befestigtes Lager aus Autoteilen. Wachen patrouillieren.', 'poi', '*', 3, NULL, 5, '⚑');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('vending', 'Verkaufsautomat', 'Ein Getraenkeautomat, die Scheibe zersplittert, aber das Ausgabefach ist verriegelt.', 'poi', 'ruins,scrapyard', 0, NULL, 8, '▤');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('ambush', 'Hinterhalt!', 'Eine Bewegung aus dem Augenwinkel – du bist nicht allein.', 'encounter', '*', 0, NULL, 20, '!');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('ashstorm', 'Aschesturm', 'Der Himmel wird schwarz. Eine Wand aus Asche rollt auf dich zu.', 'encounter', 'ashdesert,craters,wasteland', 0, NULL, 8, '≋');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('stray_note', 'Flatternder Zettel', 'Ein Blatt Papier, vom Wind herangetragen, verfaengt sich an deinem Bein.', 'encounter', '*', 0, NULL, 6, '✉');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('acid_rain', 'Saurer Regen', 'Die ersten Tropfen zischen auf dem Boden.', 'encounter', 'swamp,deadforest,ruins,scrapyard', 0, NULL, 6, '☂');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('stash', 'Verstecktes Depot', 'Ein loser Stein, darunter ein Hohlraum. Jemand hat hier etwas versteckt.', 'encounter', '*', 0, NULL, 5, '◆');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('wandering_trader', 'Reisende Haendlerin', 'Ein Handkarren mit Planen, gezogen von einer Frau mit Gasmaske. Sie hebt die Hand – friedlich.', 'encounter', '*', 0, NULL, 6, '⚖');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('trader_post', 'Handelsposten', 'Ein umgebauter Container mit Gittertuer. Auf einem Schild steht: TAUSCH. KEIN AERGER.', 'poi', 'ruins,scrapyard,wasteland,ashdesert', 1, NULL, 4, '⚖');
INSERT INTO Events (Key,Title,Text,Kind,Biomes,MinDanger,MaxDanger,Weight,Marker) VALUES ('metro_ticket', 'Fahrkartenautomat', 'Ein Automat der Verkehrsbetriebe. Das Display flackert noch: BITTE ZIEL WÄHLEN.', 'dungeon', '*', 0, NULL, 10, '▤');

-- Ereignis-Optionen: Wahlmöglichkeiten eines Ereignisses, optional mit Probe. Effekte siehe Hilfe am Effekt-Feld.
CREATE TABLE EventOptions (
    Id            INTEGER PRIMARY KEY AUTOINCREMENT,
    EventKey      TEXT NOT NULL REFERENCES Events(Key),
    SortOrder     INTEGER NOT NULL DEFAULT 0,
    Label         TEXT NOT NULL,
    SkillKey      TEXT REFERENCES Skills(Key),
    Difficulty    INTEGER NOT NULL DEFAULT 0,
    DangerScaling INTEGER NOT NULL DEFAULT 1,
    RequiresItem  TEXT,
    SuccessText   TEXT,
    SuccessEffects TEXT,
    FailText      TEXT,
    FailEffects   TEXT
);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (1, 'supply_crate', 1, 'Schloss knacken', 'lockpick', 10, 1, NULL, 'Mit einem leisen Klicken springt das Schloss auf.', 'loot:2;xp:15', 'Der Dietrich bricht ab. Das Schloss ist jetzt endgueltig verklemmt.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (2, 'supply_crate', 2, 'Aufbrechen', 'athletics', -5, 1, NULL, 'Mit roher Gewalt reisst du den Deckel auf.', 'loot:1;xp:10', 'Du rutschst ab und schneidest dich am Blech.', 'damage:2-5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (3, 'supply_crate', 3, 'Liegen lassen', NULL, 0, 0, NULL, 'Du gehst weiter.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (4, 'terminal', 1, 'Ins System hacken', 'hacking', 0, 1, NULL, 'ZUGRIFF GEWAEHRT. Dateien, Karten, Logbuecher.', 'lore;reveal:6;xp:25', 'SYSTEM GESPERRT. Ein Alarm heult kurz auf, dann Stille... nicht ganz.', 'combat:drone');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (5, 'terminal', 2, 'Gehaeuse ausschlachten', 'mechanics', 5, 1, NULL, 'Du findest brauchbare Teile und ein Notfallfach.', 'loot:1;xp:12', 'Ein Funkenschlag. Autsch.', 'damage:2-4');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (6, 'terminal', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Du laesst das Terminal hinter dir.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (7, 'corpse', 1, 'Vorsichtig durchsuchen', 'perception', 15, 1, NULL, 'Im Futter eingenaeht: ein Zettel. Und im Rucksack noch etwas Brauchbares.', 'loot:1;lore;xp:8', 'Nichts Brauchbares. Nur Staub und Erinnerungen.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (8, 'corpse', 2, 'Rucksack schnappen und weg', NULL, 0, 0, NULL, 'Du nimmst, was du tragen kannst.', 'loot:1', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (9, 'pharmacy', 1, 'Regale durchsuchen', 'perception', 0, 1, NULL, 'Hinter einem Regal: ein unangetasteter Medizinschrank!', 'lootcat:consumable:2;xp:12', 'Leergeraeumt. Jemand war vor dir hier.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (10, 'pharmacy', 2, 'Medikamente bestimmen', 'healing', 5, 1, NULL, 'Du erkennst, welche Ampullen noch wirken.', 'item:medkit:1;xp:15', 'Die Beschriftungen sind verblasst. Du nimmst lieber nichts.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (11, 'pharmacy', 3, 'Tresor im Hinterzimmer', 'lockpick', -15, 1, NULL, 'Der Betaeubungsmitteltresor! Fast unberuehrt.', 'item:stimpak:1;item:medkit:1;xp:30', 'Zu kompliziert. Der Tresor bleibt zu.', 'xp:5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (12, 'car_wreck', 1, 'Kofferraum aufhebeln', 'athletics', 5, 1, NULL, 'Knirschend gibt der Deckel nach.', 'loot:1;xp:8', 'Zu verbeult. Du hast dir nur den Ruecken gezerrt.', 'damage:1-3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (13, 'car_wreck', 2, 'Handschuhfach knacken', 'lockpick', 15, 1, NULL, 'Eine Pistole! Jemand hatte vorgesorgt.', 'lootcat:weapon:1;xp:10', 'Leer, bis auf eine Strassenkarte von einer Welt, die es nicht mehr gibt.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (14, 'car_wreck', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Du laesst das Wrack hinter dir.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (15, 'radio_tower', 1, 'Hochklettern und umsehen', 'athletics', 0, 1, NULL, 'Von oben ueberblickst du das Land weit und breit.', 'reveal:9;xp:15', 'Eine Sprosse bricht. Du faellst.', 'damage:3-8');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (16, 'radio_tower', 2, 'Funkgeraet reparieren', 'mechanics', -5, 1, NULL, 'Rauschen... dann eine Stimme. Eine Aufzeichnung.', 'lore;xp:25', 'Ein Kurzschluss. Der Kasten ist hinueber.', 'damage:1-4');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (17, 'radio_tower', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Der Mast quietscht im Wind.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (18, 'nest', 1, 'Hineinschleichen', 'stealth', 0, 1, NULL, 'Lautlos greifst du dir die Beute und verschwindest.', 'loot:2;xp:20', 'Ein Knacken unter deinem Fuss. Es ist wach.', 'combat:*');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (19, 'nest', 2, 'Angreifen', NULL, 0, 0, NULL, 'Du stuermst vor!', 'combat:*;loot:1', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (20, 'nest', 3, 'Umgehen', NULL, 0, 0, NULL, 'Du schlaegst einen weiten Bogen.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (21, 'vault_door', 1, 'Zugangscode hacken', 'hacking', -10, 1, NULL, 'Die Schleuse rollt zur Seite. Ein Lagerraum, voll bis unter die Decke.', 'loot:4;lore;xp:50', 'FEHLER. Selbstverteidigung aktiviert.', 'combat:sentry');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (22, 'vault_door', 2, 'Wartungsklappe aufschrauben', 'mechanics', -15, 1, NULL, 'Du ueberbrueckst den Mechanismus. Drinnen: Vorraete.', 'loot:3;xp:40', 'Nichts zu machen.', 'xp:5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (23, 'vault_door', 3, 'Spaeter wiederkommen', NULL, 0, 0, NULL, 'Die Schleuse wartet.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (24, 'campfire', 1, 'Ausruhen und Wunden versorgen', 'healing', 20, 0, NULL, 'Du verbindest deine Wunden sorgfaeltig und schlaefst ein paar Stunden.', 'heal:pct:60;xp:5', 'Unruhiger Schlaf, aber immerhin.', 'heal:pct:25');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (25, 'campfire', 2, 'Spuren lesen', 'survival', 0, 1, NULL, 'Die Spuren fuehren zu einem Versteck unter einem Stein.', 'loot:2;xp:15', 'Die Spuren verlieren sich im Staub.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (26, 'campfire', 3, 'Zelt durchsuchen', NULL, 0, 0, NULL, 'Ein paar Kleinigkeiten.', 'lootcat:consumable:1', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (27, 'toxic_pool', 1, 'Hineintauchen', 'survival', -5, 1, NULL, 'Luft anhalten, greifen, raus. Geschafft.', 'loot:2;xp:18', 'Das Wasser brennt auf der Haut wie Saeure.', 'damage:4-9;loot:1');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (28, 'toxic_pool', 2, 'Mit einem Ast angeln', 'perception', 0, 1, NULL, 'Mit Geduld fischst du etwas heraus.', 'loot:1;xp:10', 'Der Ast loest sich zischend auf.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (29, 'toxic_pool', 3, 'Lieber nicht', NULL, 0, 0, NULL, 'Kluge Entscheidung.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (30, 'tripwire', 1, 'Falle entschaerfen', 'mechanics', 0, 1, NULL, 'Draht geloest, Splint gesichert. Und dahinter: das Lager des Fallenstellers.', 'loot:2;xp:20', 'KLICK.', 'damage:4-9');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (31, 'tripwire', 2, 'Darueber steigen', 'athletics', 15, 1, NULL, 'Vorsichtig, ganz vorsichtig... geschafft.', 'xp:8', 'Dein Stiefel bleibt haengen.', 'damage:4-9');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (32, 'tripwire', 3, 'Umkehren', NULL, 0, 0, NULL, 'Nicht dein Problem.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (33, 'bunker_ruin', 1, 'Durch den Schacht kriechen', 'athletics', -5, 1, NULL, 'Unten: ein Schlafsaal und ein Tagebuch.', 'loot:2;lore;xp:30', 'Der Schacht gibt nach. Du stuerzt in die Dunkelheit.', 'damage:4-10;loot:1');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (34, 'bunker_ruin', 2, 'Notstrom aktivieren', 'mechanics', -10, 1, NULL, 'Lichter flackern auf. Ein Terminal erwacht.', 'lore;lore;reveal:5;xp:35', 'Nur ein muedes Brummen.', 'xp:4');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (35, 'bunker_ruin', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Totenstille.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (36, 'scrapheap', 1, 'Gezielt suchen', 'mechanics', 10, 1, NULL, 'Du baust dir aus Teilen etwas Brauchbares zusammen.', 'lootcat:weapon:1;xp:15', 'Nur Schrott.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (37, 'scrapheap', 2, 'Durchwuehlen', 'perception', 5, 1, NULL, 'Zwischen dem Muell: Vorraete!', 'loot:1;xp:10', 'Etwas beisst dich aus dem Schrott heraus!', 'combat:rat');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (38, 'survivor', 1, 'Wasser geben', NULL, 0, 0, 'water', 'Er trinkt gierig. Dann drueckt er dir etwas in die Hand und erzaehlt, was er gesehen hat.', 'take:water:1;loot:2;lore;xp:30', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (39, 'survivor', 2, 'Wunden versorgen', 'healing', 0, 0, NULL, 'Du hilfst ihm so gut du kannst. Dankbar zeigt er dir sein Versteck.', 'loot:1;reveal:4;xp:25', 'Du tust, was du kannst. Es ist nicht genug.', 'xp:5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (40, 'survivor', 3, 'Ihm nicht trauen', NULL, 0, 0, NULL, 'Du gehst weiter. Er ruft dir nichts nach.', '', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (41, 'hunter_blind', 1, 'Hinaufklettern', 'athletics', 10, 1, NULL, 'Oben findest du eine Kiste und eine gute Aussicht.', 'lootcat:ranged:1;lootcat:ammo:1;reveal:5;xp:15', 'Die Leiter bricht.', 'damage:2-6');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (42, 'hunter_blind', 2, 'Spuren im Umkreis lesen', 'survival', 0, 1, NULL, 'Hier wurde gejagt – und Vorraete versteckt.', 'lootcat:consumable:2;xp:12', 'Nur alte Faehrten.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (43, 'crashed_heli', 1, 'Waffenkiste knacken', 'lockpick', -10, 1, NULL, 'Militaerausruestung!', 'lootcat:weapon:1;lootcat:armor:1;xp:40', 'Das Schloss ist zu gut.', 'xp:5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (44, 'crashed_heli', 2, 'Flugschreiber auslesen', 'hacking', -5, 1, NULL, 'Die letzten Minuten des Piloten. Und Koordinaten.', 'lore;reveal:8;xp:35', 'Daten korrupt.', 'xp:5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (45, 'crashed_heli', 3, 'Wrack durchsuchen', 'perception', 0, 1, NULL, 'Notfallrationen und ein Erste-Hilfe-Kasten.', 'item:medkit:1;lootcat:consumable:1;xp:15', 'Nur Splitter und verkohlte Sitze. Und dann Schritte...', 'combat:*');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (46, 'graffiti', 1, 'Lesen', NULL, 0, 0, NULL, 'Du liest die Worte.', 'lore;xp:5', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (47, 'glowing_tree', 1, 'Essbare Fruechte bestimmen', 'survival', 5, 1, NULL, 'Diese hier sind sicher. Mehr oder weniger.', 'item:mutfruit:3;xp:10', 'Die Frucht platzt und spritzt dir Saft in die Augen.', 'damage:1-4');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (48, 'glowing_tree', 2, 'Hochklettern', 'athletics', 0, 1, NULL, 'In einer Astgabel: ein altes Vogelnest voller glaenzender Dinge.', 'loot:1;xp:10', 'Der Ast bricht.', 'damage:2-5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (49, 'raider_camp', 1, 'Nachts ins Lager schleichen', 'stealth', -10, 1, NULL, 'Du greifst dir eine Kiste aus dem Vorratszelt und verschwindest.', 'loot:3;xp:45', '"HEY! Da ist jemand!"', 'combat:raider;combat:raider');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (50, 'raider_camp', 2, 'Angreifen', NULL, 0, 0, NULL, 'Waffen hoch!', 'combat:raider;combat:raider;loot:3', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (51, 'raider_camp', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Heute nicht.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (52, 'vending', 1, 'Elektronik ueberlisten', 'hacking', 15, 1, NULL, 'Bing! Bing! Bing!', 'item:water:2;item:cannedfood:1;xp:10', 'Der Automat piepst beleidigt.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (53, 'vending', 2, 'Fach aufhebeln', 'athletics', 5, 1, NULL, 'Mit einem Ruck.', 'item:water:1;xp:6', 'Der Automat kippt dir fast auf den Fuss.', 'damage:1-3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (54, 'ambush', 1, 'Kaempfen', NULL, 0, 0, NULL, 'Du stellst dich.', 'combat:*', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (55, 'ambush', 2, 'Davonschleichen', 'stealth', 0, 1, NULL, 'Du duckst dich weg und verschwindest im Schatten.', 'xp:6', 'Zu spaet – es hat dich gesehen!', 'combat:*');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (56, 'ashstorm', 1, 'Unterschlupf suchen', 'survival', 5, 1, NULL, 'Du findest eine Senke und wartest ab. Im Sand liegt etwas.', 'xp:10;loot:1', 'Die Asche schmirgelt dir die Haut ab.', 'damage:2-6');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (57, 'ashstorm', 2, 'Weiterkaempfen', 'athletics', -5, 1, NULL, 'Mit gesenktem Kopf durch den Sturm.', 'xp:8', 'Du stolperst und verletzt dich.', 'damage:3-7');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (58, 'stray_note', 1, 'Lesen', NULL, 0, 0, NULL, 'Handschrift, hastig, verwischt.', 'lore;xp:4', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (59, 'acid_rain', 1, 'Schnell Deckung suchen', 'perception', 10, 1, NULL, 'Ein Ueberhang schuetzt dich.', 'xp:6', 'Zu langsam.', 'damage:2-5');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (60, 'stash', 1, 'Nehmen', NULL, 0, 0, NULL, 'Danke, Unbekannter.', 'loot:1;xp:5', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (61, 'wandering_trader', 1, 'Tauschen', NULL, 0, 0, NULL, 'Sie schlaegt die Plane zurueck.', 'trade:wanderer', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (62, 'wandering_trader', 2, 'Nach Neuigkeiten fragen', 'perception', 10, 0, NULL, 'Sie erzaehlt dir von ihrer Route und zeigt dir ihre Karte.', 'reveal:7;lore;xp:10', 'Sie zuckt nur mit den Schultern.', 'xp:2');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (63, 'wandering_trader', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Sie nickt dir zu und zieht weiter.', '', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (64, 'trader_post', 1, 'Mit dem Schrotthaendler tauschen', NULL, 0, 0, NULL, 'Er mustert dich und deine Ausruestung.', 'trade:scrapper;persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (65, 'trader_post', 2, 'Mit dem Wanderarzt tauschen', NULL, 0, 0, NULL, 'Der Arzt rueckt seine Brille zurecht.', 'trade:medic;persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (66, 'trader_post', 3, 'Weitergehen', NULL, 0, 0, NULL, 'Der Posten bleibt, wo er ist.', 'persist', NULL, NULL);
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (68, 'metro_ticket', 1, 'Wartungsmenü aufrufen', 'hacking', 5, 1, NULL, 'Das Menü öffnet sich. Der Drucker rattert.', 'story:metro_4;xp:15', 'FEHLER 0x23. Der Automat schaltet sich ab.', 'xp:3');
INSERT INTO EventOptions (Id,EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES (69, 'metro_ticket', 2, 'Geldfach aufbrechen', 'athletics', 0, 1, NULL, 'Münzen, wertlos. Aber dahinter klemmt eine Wasserflasche.', 'item:water:1;xp:5', 'Das Fach hält.', '');

-- Händler: Tauschhändler. Werden über den Effekt trade:KEY in Ereignis-Optionen gestartet.
CREATE TABLE Traders (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Greeting    TEXT NOT NULL,
    Categories  TEXT NOT NULL DEFAULT '*',
    StockMin    INTEGER NOT NULL DEFAULT 4,
    StockMax    INTEGER NOT NULL DEFAULT 7,
    PayFactor   REAL NOT NULL DEFAULT 0.7,
    PriceFactor REAL NOT NULL DEFAULT 1.2,
    Weight      INTEGER NOT NULL DEFAULT 10,
    Color       TEXT NOT NULL DEFAULT '#c0a070'
);
INSERT INTO Traders (Key,Name,Greeting,Categories,StockMin,StockMax,PayFactor,PriceFactor,Weight,Color) VALUES ('wanderer', 'Reisende Haendlerin', '"Alles hat seinen Preis, Fremder. Zeig mir, was du hast."', '*', 5, 8, 0.7, 1.2, 10, '#c0a070');
INSERT INTO Traders (Key,Name,Greeting,Categories,StockMin,StockMax,PayFactor,PriceFactor,Weight,Color) VALUES ('medic', 'Wanderarzt', '"Verbaende, Pillen, Spritzen. Ich nehme alles, was schiesst."', 'consumable,ammo', 4, 6, 0.8, 1.3, 5, '#e04040');
INSERT INTO Traders (Key,Name,Greeting,Categories,StockMin,StockMax,PayFactor,PriceFactor,Weight,Color) VALUES ('scrapper', 'Schrotthaendler', '"Metall gegen Metall. Und ich sag dir, was es wert ist."', 'weapon,armor', 4, 6, 0.75, 1.25, 6, '#9a5b34');

-- Ruinen: Begehbare Ruinen. Erscheinen zufällig auf der Weltkarte (Settings.DungeonChance). Karten im Ruinen-Editor bearbeiten.
CREATE TABLE Dungeons (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Description TEXT NOT NULL DEFAULT '',
    Biomes      TEXT NOT NULL DEFAULT '*',
    MinDanger   INTEGER NOT NULL DEFAULT 0,
    MaxDanger   INTEGER,
    Weight      INTEGER NOT NULL DEFAULT 10,
    Marker      TEXT NOT NULL DEFAULT '▼',
    Color       TEXT NOT NULL DEFAULT '#c0503a'
);
INSERT INTO Dungeons (Key,Name,Description,Biomes,MinDanger,MaxDanger,Weight,Marker,Color) VALUES ('metro', 'U-Bahn-Station Zentrum', 'Ein eingestürzter Treppenabgang. Auf dem verbogenen Schild ist noch ein „U“ zu erkennen. Von unten weht kalte, abgestandene Luft herauf.', 'ruins,wasteland,ashdesert', 0, NULL, 10, 'U', '#5a9ad0');

-- Stockwerke: Karten der Ruinen. Bearbeitung im Ruinen-Editor.
CREATE TABLE DungeonFloors (
    Id           INTEGER PRIMARY KEY AUTOINCREMENT,
    DungeonKey   TEXT NOT NULL REFERENCES Dungeons(Key),
    Name         TEXT NOT NULL,
    SortOrder    INTEGER NOT NULL DEFAULT 0,
    Width        INTEGER NOT NULL,
    Height       INTEGER NOT NULL,
    DangerOffset INTEGER NOT NULL DEFAULT 0,
    Tiles        TEXT NOT NULL                -- Zeilen durch Zeilenumbruch, Zellen durch Komma (Kachel-Keys)
);
INSERT INTO DungeonFloors (Id,DungeonKey,Name,SortOrder,Width,Height,DangerOffset,Tiles) VALUES (1, 'metro', 'Bahnsteigebene', 1, 22, 14, 0, 'void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void
void,wall,wall,wall,wall,wall,wall,wall,wall,void,void,void,void,wall,wall,wall,wall,wall,wall,wall,wall,void
void,wall,tiles,tiles,tiles,tiles,tiles,tiles,wall,void,void,void,void,wall,floor,floor,floor,floor,floor,floor,wall,void
void,wall,tiles,tiles,tiles,tiles,tiles,tiles,corridor_ew,corridor_ew,corridor_ew,corridor_ew,corridor_ew,corridor_door_ew,floor,floor,floor,floor,floor,floor,wall,void
void,wall,tiles,tiles,pillar,tiles,tiles,tiles,wall,void,void,void,void,wall,floor,floor,floor,rubble,floor,floor,wall,void
void,wall,tiles,tiles,tiles,tiles,tiles,tiles,wall,void,void,void,void,wall,floor,floor,floor,floor,floor,floor,wall,void
void,wall,wall,wall,corridor_ns,wall,wall,wall,wall,void,void,void,void,wall,wall,wall,corridor_ns,wall,wall,wall,wall,void
void,void,void,void,corridor_ns,void,void,void,void,void,void,void,void,void,void,void,corridor_ns,void,void,void,void,void
void,wall,wall,wall,corridor_ns,wall,wall,wall,wall,wall,wall,wall,wall,wall,wall,wall,corridor_ns,wall,wall,wall,wall,void
void,wall,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,tiles,wall,void
void,wall,tiles,tiles,pillar,tiles,tiles,tiles,tiles,tiles,pillar,tiles,tiles,tiles,tiles,tiles,pillar,tiles,tiles,tiles,wall,void
void,wall,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,wall,void
void,wall,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,tracks,wall,void
void,wall,wall,wall,wall,wall,rubble,rubble,wall,wall,wall,wall,wall,wall,rubble,rubble,wall,wall,wall,wall,wall,void');
INSERT INTO DungeonFloors (Id,DungeonKey,Name,SortOrder,Width,Height,DangerOffset,Tiles) VALUES (2, 'metro', 'Wartungstunnel', 2, 18, 12, 1, 'void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void,void
void,wall,wall,wall,wall,wall,wall,void,void,void,void,void,void,void,void,void,void,void
void,wall,grate,grate,grate,grate,wall,void,void,void,void,wall,wall,wall,wall,wall,wall,void
void,wall,grate,grate,grate,grate,corridor_ew,corridor_ew,corridor_ew,corridor_ew,corridor_ew,corridor_ew,floor,floor,floor,floor,wall,void
void,wall,grate,grate,grate,grate,wall,void,void,void,void,wall,floor,water,water,floor,wall,void
void,wall,wall,wall,corridor_ns,wall,wall,void,void,void,void,wall,floor,water,water,floor,wall,void
void,void,void,void,corridor_ns,void,void,void,void,void,void,wall,floor,floor,floor,floor,wall,void
void,void,void,void,corridor_ns,void,void,void,void,void,void,wall,wall,corridor_ns,wall,wall,wall,void
void,void,void,wall,corridor_ns,wall,wall,wall,wall,wall,void,void,void,corridor_ns,void,void,void,void
void,void,void,wall,floor,floor,floor,floor,floor,wall,void,void,void,corridor_ns,void,void,void,void
void,void,void,wall,floor,floor,floor,floor,floor,corridor_ew,corridor_ew,corridor_ew,corridor_ew,corridor_nw,void,void,void,void
void,void,void,wall,wall,wall,wall,wall,wall,wall,void,void,void,void,void,void,void,void');

-- Ruinen-Objekte: Ein- und Ausgänge, Übergänge, Behälter, Türen, Gegner, Ereignisse und Auslöser auf einem Stockwerk.
CREATE TABLE DungeonObjects (
    Id            INTEGER PRIMARY KEY AUTOINCREMENT,
    FloorId       INTEGER NOT NULL REFERENCES DungeonFloors(Id),
    X             INTEGER NOT NULL,
    Y             INTEGER NOT NULL,
    Kind          TEXT NOT NULL,              -- entrance, exit, transition, container, door, enemy, event, trigger
    Icon          TEXT,                       -- Kachel-Key (Layer object)
    Label         TEXT,
    Description   TEXT,
    EnemyKey      TEXT REFERENCES Enemies(Key),
    EventKey      TEXT REFERENCES Events(Key),
    SkillKey      TEXT REFERENCES Skills(Key),
    Difficulty    INTEGER NOT NULL DEFAULT 0,
    Effects       TEXT,
    FailEffects   TEXT,
    TargetFloorId INTEGER REFERENCES DungeonFloors(Id),
    TargetX       INTEGER,
    TargetY       INTEGER
);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (1, 1, 3, 3, 'entrance', NULL, 'Treppenabgang', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (2, 1, 2, 2, 'exit', 'obj_exit', 'Treppe nach oben', 'Tageslicht fällt durch die Trümmer.', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (3, 1, 3, 4, 'trigger', NULL, NULL, NULL, NULL, NULL, NULL, 0, 'story:metro_1', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (4, 1, 6, 5, 'container', 'obj_crate', 'Holzkiste', NULL, NULL, NULL, NULL, 0, 'loot:1', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (5, 1, 10, 3, 'enemy', NULL, NULL, 'Eine Ratte, fett vom Müll der Station.', 'rat', NULL, NULL, 0, '', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (6, 1, 13, 3, 'door', 'obj_door', 'Dienstraum', '„NUR FÜR PERSONAL“. Abgeschlossen.', NULL, NULL, 'lockpick', 0, 'xp:10', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (7, 1, 19, 2, 'container', 'obj_locker', 'Spind', 'Ein verbeulter Personalspind.', NULL, NULL, NULL, 0, 'story:metro_3;item:medkit:1;item:ammo9:6', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (8, 1, 15, 5, 'event', 'obj_machine', 'Fahrkartenautomat', NULL, NULL, 'metro_ticket', NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (9, 1, 10, 9, 'trigger', NULL, NULL, NULL, NULL, NULL, NULL, 0, 'story:metro_2;xp:5', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (10, 1, 6, 9, 'container', 'obj_corpse', 'Reisender', 'Ein Skelett im Anzug, die Aktentasche noch in der Hand.', NULL, NULL, NULL, 0, 'loot:1;lore', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (11, 1, 14, 10, 'enemy', NULL, NULL, 'Er hat auf dem Bahnsteig gewartet. Er wartet immer noch.', 'ghoul', NULL, NULL, 0, 'loot:1', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (12, 1, 18, 9, 'container', 'obj_chest', 'Werkzeugkiste', 'Ein Zahlenschloss. Vier Ziffern.', NULL, NULL, 'lockpick', -10, 'lootcat:weapon:1;xp:15', 'damage:1-3', NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (13, 1, 19, 12, 'transition', 'obj_ladder', 'Wartungsschacht', 'Eine Leiter führt hinab in den Wartungstunnel.', NULL, NULL, NULL, 0, NULL, NULL, 2, 4, 9);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (14, 2, 4, 9, 'transition', 'obj_ladder', 'Leiter nach oben', NULL, NULL, NULL, NULL, 0, NULL, NULL, 1, 19, 12);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (15, 2, 7, 9, 'container', 'obj_cabinet', 'Werkzeugschrank', NULL, NULL, NULL, NULL, 0, 'item:medkit_small:2;lootcat:armor:1', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (16, 2, 4, 6, 'enemy', NULL, NULL, 'Rote Optik. Sie hat dich gehört.', 'drone', NULL, NULL, 0, 'xp:10', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (17, 2, 3, 3, 'container', 'obj_barrel', 'Fass mit Warnzeichen', 'Die Aufschrift ist abgeblättert.', NULL, NULL, 'perception', 0, 'item:stimpak:1', 'damage:3-6', NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (18, 2, 13, 4, 'trigger', NULL, NULL, NULL, NULL, NULL, NULL, 0, 'story:metro_5;xp:20', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (19, 2, 15, 6, 'container', 'obj_chest', 'Notfallkiste', 'Rotes Kreuz auf grauem Metall.', NULL, NULL, NULL, 0, 'item:medkit:1;loot:2', NULL, NULL, NULL, NULL);
INSERT INTO DungeonObjects (Id,FloorId,X,Y,Kind,Icon,Label,Description,EnemyKey,EventKey,SkillKey,Difficulty,Effects,FailEffects,TargetFloorId,TargetX,TargetY) VALUES (20, 2, 14, 3, 'enemy', NULL, NULL, 'Etwas regt sich im Wasser.', 'swamper', NULL, NULL, 0, 'loot:1', NULL, NULL, NULL, NULL);

-- Kachel-Palette: Kacheln für Gelände (terrain) und Symbole für Objekte (object), je ein SVG im 48×48-Feld.
CREATE TABLE DungeonTiles (
    Key       TEXT PRIMARY KEY,
    Name      TEXT NOT NULL,
    Layer     TEXT NOT NULL DEFAULT 'terrain',  -- terrain = Gelaende, object = Symbol fuer Objekte
    Svg       TEXT NOT NULL,                     -- SVG im 48x48-Feld
    Passable  INTEGER NOT NULL DEFAULT 1,
    SortOrder INTEGER NOT NULL DEFAULT 0
);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('void', 'Nichts (schwarz)', 'terrain', '<rect width="48" height="48" fill="#050505"/>', 0, 0);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('wall', 'Mauer', 'terrain', '<rect width="48" height="48" fill="#2a2826"/><path d="M0 12H48M0 24H48M0 36H48M12 0V12M36 0V12M24 12V24M0 12V24M12 24V36M36 24V36M24 36V48" stroke="#3b3835" stroke-width="1.5"/>', 0, 1);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('floor', 'Betonboden', 'terrain', '<rect width="48" height="48" fill="#3a3631"/><circle cx="12" cy="15" r="1.2" fill="#4a4540"/><circle cx="33" cy="30" r="1" fill="#4a4540"/><path d="M26 8l5 4" stroke="#2c2925"/>', 1, 2);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('tiles', 'Fliesen', 'terrain', '<rect width="48" height="48" fill="#4a4a46"/><path d="M0 16H48M0 32H48M16 0V48M32 0V48" stroke="#3a3a37" stroke-width="1.5"/><path d="M18 18l10 9" stroke="#2f2f2c"/>', 1, 3);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('grate', 'Gitterboden', 'terrain', '<rect width="48" height="48" fill="#1c1c1c"/><path d="M0 6H48M0 18H48M0 30H48M0 42H48M6 0V48M18 0V48M30 0V48M42 0V48" stroke="#4b4f52" stroke-width="2"/>', 1, 4);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('tracks', 'Gleise', 'terrain', '<rect width="48" height="48" fill="#2b2724"/><path d="M0 6H48M0 18H48M0 30H48M0 42H48" stroke="#4a3a2c" stroke-width="4"/><path d="M14 0V48M34 0V48" stroke="#8a8a88" stroke-width="3"/>', 1, 5);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('water', 'Wasser (seicht)', 'terrain', '<rect width="48" height="48" fill="#17303a"/><path d="M4 16q6-4 12 0t12 0t12 0M8 32q6-4 12 0t12 0t12 0" stroke="#2e6070" stroke-width="2" fill="none"/>', 1, 6);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('rubble', 'Schutt (unpassierbar)', 'terrain', '<rect width="48" height="48" fill="#3a3631"/><path d="M4 40l8-14 8 6 6-12 10 8 8 12z" fill="#5a544c"/><path d="M14 18l6-4 4 6z" fill="#6a645b"/>', 0, 7);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('pillar', 'Säule (unpassierbar)', 'terrain', '<rect width="48" height="48" fill="#3a3631"/><rect x="12" y="12" width="24" height="24" fill="#5c5852" stroke="#6e6a63" stroke-width="2"/>', 0, 8);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_ew', 'Gang waagrecht', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 37H37 M0 11H11 M0 37H11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 20);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_ns', 'Gang senkrecht', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><path d="M11 11V37 M37 11V37 M11 0V11 M37 0V11 M11 37V48 M37 37V48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 21);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_nesw', 'Kreuzung', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 0V11 M37 0V11 M11 37V48 M37 37V48 M0 11H11 M0 37H11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 22);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_ne', 'Ecke Nord-Ost', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 37H37 M11 11V37 M11 0V11 M37 0V11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 23);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_nw', 'Ecke Nord-West', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 37H37 M37 11V37 M11 0V11 M37 0V11 M0 11H11 M0 37H11" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 24);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_es', 'Ecke Süd-Ost', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 11V37 M11 37V48 M37 37V48 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 25);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_sw', 'Ecke Süd-West', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M37 11V37 M11 37V48 M37 37V48 M0 11H11 M0 37H11" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 26);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_new', 'Abzweig ohne Süd', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 37H37 M11 0V11 M37 0V11 M0 11H11 M0 37H11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 27);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_nes', 'Abzweig ohne West', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11V37 M11 0V11 M37 0V11 M11 37V48 M37 37V48 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 28);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_esw', 'Abzweig ohne Nord', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 37V48 M37 37V48 M0 11H11 M0 37H11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 29);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_nsw', 'Abzweig ohne Ost', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><path d="M37 11V37 M11 0V11 M37 0V11 M11 37V48 M37 37V48 M0 11H11 M0 37H11" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 30);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_n', 'Sackgasse Nord', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><path d="M11 37H37 M11 11V37 M37 11V37 M11 0V11 M37 0V11" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 31);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_e', 'Sackgasse Ost', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 37H37 M11 11V37 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 32);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_s', 'Sackgasse Süd', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><path d="M11 11H37 M11 11V37 M37 11V37 M11 37V48 M37 37V48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 33);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_w', 'Sackgasse West', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 37H37 M37 11V37 M0 11H11 M0 37H11" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/>', 1, 34);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_door_ew', 'Gang waagrecht mit Tür', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="0" y="11" width="12" height="26" fill="#3a3631"/><rect x="36" y="11" width="12" height="26" fill="#3a3631"/><path d="M11 11H37 M11 37H37 M0 11H11 M0 37H11 M37 11H48 M37 37H48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/><rect x="21" y="11" width="6" height="26" fill="#7a5530" stroke="#3a2610" stroke-width="1.5"/><circle cx="24" cy="24" r="1.3" fill="#e0c070"/>', 1, 40);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('corridor_door_ns', 'Gang senkrecht mit Tür', 'terrain', '<rect width="48" height="48" fill="#070707"/><rect x="11" y="11" width="26" height="26" fill="#3a3631"/><rect x="11" y="36" width="26" height="12" fill="#3a3631"/><rect x="11" y="0" width="26" height="12" fill="#3a3631"/><path d="M11 11V37 M37 11V37 M11 0V11 M37 0V11 M11 37V48 M37 37V48" stroke="#57524b" stroke-width="2.5" fill="none"/><circle cx="20" cy="27" r="1" fill="#4a4540"/><circle cx="29" cy="19" r="1" fill="#4a4540"/><rect x="11" y="21" width="26" height="6" fill="#7a5530" stroke="#3a2610" stroke-width="1.5"/><circle cx="24" cy="24" r="1.3" fill="#e0c070"/>', 1, 41);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_entrance', 'Eingang (Markierung)', 'object', '<circle cx="24" cy="24" r="10" fill="none" stroke="#8cc152" stroke-width="2.5" stroke-dasharray="4 3"/><path d="M24 17v14M18 25l6 6 6-6" stroke="#8cc152" stroke-width="2.5" fill="none"/>', 1, 100);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_exit', 'Ausgang ins Freie', 'object', '<rect x="12" y="8" width="24" height="32" rx="2" fill="#1a2a14" stroke="#8cc152" stroke-width="2.5"/><path d="M24 30V16M18 22l6-6 6 6" stroke="#8cc152" stroke-width="2.5" fill="none"/>', 1, 101);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_stairs_down', 'Treppe abwärts', 'object', '<path d="M8 12h10v8h10v8h12v10H8z" fill="#5c5852"/><path d="M8 12h10v8h10v8h12" stroke="#8a857c" stroke-width="2" fill="none"/><path d="M38 8v10M34 14l4 4 4-4" stroke="#f2b43a" stroke-width="2" fill="none"/>', 1, 102);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_stairs_up', 'Treppe aufwärts', 'object', '<path d="M8 38h10v-8h10v-8h12V10H8z" fill="#5c5852" transform="scale(1,-1) translate(0,-48)"/><path d="M38 18V8M34 12l4-4 4 4" stroke="#f2b43a" stroke-width="2" fill="none"/>', 1, 103);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_ladder', 'Leiter / Schacht', 'object', '<rect x="10" y="10" width="28" height="28" fill="#0a0a0a" stroke="#5c5852" stroke-width="2"/><path d="M17 6v36M31 6v36M17 13h14M17 21h14M17 29h14M17 37h14" stroke="#a09a8e" stroke-width="2.5"/>', 1, 104);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_door', 'Tür (verschlossen)', 'object', '<rect x="10" y="6" width="28" height="36" rx="2" fill="#6a4a28" stroke="#2a1a08" stroke-width="2"/><path d="M24 6v36" stroke="#4a3018" stroke-width="1.5"/><rect x="19" y="21" width="10" height="9" rx="1.5" fill="#c0a040"/><path d="M21 21v-3a3 3 0 016 0v3" stroke="#c0a040" stroke-width="2" fill="none"/>', 1, 105);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_chest', 'Kiste', 'object', '<rect x="8" y="16" width="32" height="22" rx="2" fill="#6a5030" stroke="#2a1a08" stroke-width="2"/><path d="M8 24h32" stroke="#2a1a08" stroke-width="2"/><rect x="21" y="21" width="6" height="7" fill="#d0b050"/>', 1, 106);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_crate', 'Holzkiste', 'object', '<rect x="9" y="11" width="30" height="28" fill="#8a6a3a" stroke="#4a3418" stroke-width="2"/><path d="M9 11l30 28M39 11L9 39" stroke="#4a3418" stroke-width="2"/>', 1, 107);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_locker', 'Spind', 'object', '<rect x="13" y="5" width="22" height="38" rx="1" fill="#4a5a6a" stroke="#22303a" stroke-width="2"/><path d="M24 5v38" stroke="#22303a" stroke-width="1.5"/><path d="M16 10h5M16 13h5M27 10h5M27 13h5" stroke="#22303a" stroke-width="1.5"/>', 1, 108);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_cabinet', 'Schrank', 'object', '<rect x="8" y="10" width="32" height="30" rx="1" fill="#5a4a3a" stroke="#2a2018" stroke-width="2"/><path d="M8 25h32M24 10v30" stroke="#2a2018" stroke-width="1.5"/><circle cx="21" cy="18" r="1.3" fill="#c0a060"/><circle cx="27" cy="18" r="1.3" fill="#c0a060"/>', 1, 109);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_corpse', 'Leiche', 'object', '<ellipse cx="24" cy="30" rx="15" ry="6" fill="#3a2a22"/><circle cx="12" cy="27" r="5" fill="#8a7a6a"/><path d="M16 28h20M20 24l-4-6M28 24l6-5" stroke="#6a5a4a" stroke-width="4" stroke-linecap="round"/>', 1, 110);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_terminal', 'Terminal', 'object', '<rect x="10" y="10" width="28" height="20" rx="2" fill="#1a1e1a" stroke="#5a6a5a" stroke-width="2"/><path d="M14 16h12M14 21h8" stroke="#6ad06a" stroke-width="2"/><rect x="18" y="30" width="12" height="8" fill="#3a3e3a"/>', 1, 111);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_machine', 'Automat', 'object', '<rect x="12" y="6" width="24" height="36" rx="2" fill="#7a2a2a" stroke="#3a1010" stroke-width="2"/><rect x="16" y="10" width="16" height="12" fill="#1a1a1a"/><rect x="19" y="30" width="10" height="5" fill="#1a1a1a"/>', 1, 112);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_note', 'Notiz', 'object', '<path d="M14 10h16l6 6v22H14z" fill="#d8d0b8" stroke="#8a8270" stroke-width="1.5"/><path d="M18 20h14M18 25h14M18 30h9" stroke="#8a8270" stroke-width="1.5"/>', 1, 113);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_mark', 'Hinweis (!)', 'object', '<circle cx="24" cy="24" r="11" fill="rgba(242,180,58,.15)" stroke="#f2b43a" stroke-width="2"/><path d="M24 17v9" stroke="#f2b43a" stroke-width="3"/><circle cx="24" cy="31" r="1.8" fill="#f2b43a"/>', 1, 114);
INSERT INTO DungeonTiles (Key,Name,Layer,Svg,Passable,SortOrder) VALUES ('obj_barrel', 'Fass', 'object', '<rect x="14" y="10" width="20" height="30" rx="4" fill="#4a6a3a" stroke="#22301a" stroke-width="2"/><path d="M14 18h20M14 32h20" stroke="#22301a" stroke-width="2"/><path d="M20 23l4 4 4-4" stroke="#d0e040" stroke-width="2" fill="none"/>', 1, 115);

-- Storyboard: Story-Texte. Werden über den Effekt story:KEY angezeigt und im Journal gesammelt.
CREATE TABLE DungeonStory (
    Key        TEXT PRIMARY KEY,
    DungeonKey TEXT REFERENCES Dungeons(Key),
    Title      TEXT NOT NULL,
    Text       TEXT NOT NULL,
    SortOrder  INTEGER NOT NULL DEFAULT 0
);
INSERT INTO DungeonStory (Key,DungeonKey,Title,Text,SortOrder) VALUES ('metro_1', 'metro', 'Die Treppe hinab', 'Die Rolltreppe steht still, seit Jahrzehnten. An der Wand klebt ein Plakat: „Schutzraum Zentrum – Kapazität 2.000 Personen“. Darunter hat jemand mit Kreide geschrieben: „Voll. Geht weiter.“', 1);
INSERT INTO DungeonStory (Key,DungeonKey,Title,Text,SortOrder) VALUES ('metro_2', 'metro', 'Bahnsteig 3', 'Auf dem Bahnsteig liegen Koffer, Decken, Kinderspielzeug. Hier haben Menschen gewartet. Auf einen Zug, der nie kam – oder auf etwas anderes.', 2);
INSERT INTO DungeonStory (Key,DungeonKey,Title,Text,SortOrder) VALUES ('metro_3', 'metro', 'Zettel im Spind', '„Schicht 14. Die Lüftung im Wartungstunnel macht wieder Geräusche. Keiner will runter. Ich gehe morgen. Wenn ich nicht zurückkomme: Der Code für die Werkzeugkiste ist 0451.“', 3);
INSERT INTO DungeonStory (Key,DungeonKey,Title,Text,SortOrder) VALUES ('metro_4', 'metro', 'Fahrplan-Ausdruck', 'Der Automat druckt einen letzten Fahrplan aus. Alle Abfahrten: GESTRICHEN. Nur eine Zeile nicht: „Sonderzug LAZARUS – Gleis 0 – 04:51“.', 4);
INSERT INTO DungeonStory (Key,DungeonKey,Title,Text,SortOrder) VALUES ('metro_5', 'metro', 'Gleis 0', 'Hinter dem Wasser, wo kein Gleis sein sollte, endet der Tunnel an einer Betonwand. Jemand hat sie zugemauert, von innen. In den Beton geritzt: 23.', 5);

-- Tabellenbeschreibungen: Beschriftung, Gruppe und Listenspalten der Tabellen in der Verwaltung.
CREATE TABLE _TableDocs (
    TableName      TEXT PRIMARY KEY,
    Label          TEXT NOT NULL,
    GroupName      TEXT NOT NULL DEFAULT 'Weitere',
    Description    TEXT,
    DisplayColumns TEXT,          -- kommagetrennt: Spalten in der Listenansicht
    SortOrder      INTEGER NOT NULL DEFAULT 0
);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Settings', 'Regeln & Balancing', 'Regeln', 'Globale Spielregeln als Schlüssel/Wert. Der Code liest die Werte mit einem Fallback, fehlende Einträge brechen also nichts.', 'Key,Value,Description', 1);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Texts', 'Texte', 'Texte', 'Feste Texte: Titel, Intro, Tod, Stufenaufstieg.', 'Key,Text', 2);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Lore', 'Infofragmente', 'Texte', 'Infofetzen fürs Journal. Werden über den Effekt lore gefunden, Fragmente mit niedriger MinDanger bevorzugt.', 'Id,Title,MinDanger', 3);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Attributes', 'Attribute', 'Charakter', 'Die Grundwerte des Charakters. Die Keys str, end, agi werden vom Code benutzt.', 'Key,Name,Abbrev,SortOrder', 4);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Skills', 'Fertigkeiten', 'Charakter', 'Fertigkeiten mit Leitattribut. Die Keys melee, ranged, healing, stealth, perception werden vom Code benutzt.', 'Key,Name,AttributeKey,Category,SortOrder', 5);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Biomes', 'Biome', 'Welt', 'Geländetypen. Die Welt entsteht aus zwei Rauschwerten (Höhe, Feuchte, 0–1); das passende Biom mit der höchsten Priority gewinnt.', 'Key,Name,Color,Glyph,Priority,DangerBonus,EventChance,Passable', 6);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Items', 'Gegenstände', 'Gegenstände', 'Waffen, Rüstung, Verbrauchsgüter und Munition.', 'Key,Name,Color,Category,Slot,Rarity,MinDanger,Value', 7);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Enemies', 'Gegner', 'Gegner', 'Gegnerwerte gelten für ihre MinDanger und wachsen mit der Gefahrenstufe (siehe Settings).', 'Key,Name,Icon,Hp,Attack,Defense,Xp,MinDanger', 8);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Events', 'Ereignisse', 'Ereignisse', 'Orte auf der Karte (poi) und zufällige Begegnungen (encounter). Die Optionen stehen in Ereignis-Optionen.', 'Key,Title,Marker,Kind,Biomes,MinDanger,Weight', 9);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('EventOptions', 'Ereignis-Optionen', 'Ereignisse', 'Wahlmöglichkeiten eines Ereignisses, optional mit Probe. Effekte siehe Hilfe am Effekt-Feld.', 'EventKey,SortOrder,Label,SkillKey,Difficulty', 10);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Traders', 'Händler', 'Händler', 'Tauschhändler. Werden über den Effekt trade:KEY in Ereignis-Optionen gestartet.', 'Key,Name,Color,Categories,PayFactor,PriceFactor', 11);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('_TableDocs', 'Tabellenbeschreibungen', 'Meta', 'Beschriftung, Gruppe und Listenspalten der Tabellen in der Verwaltung.', 'TableName,Label,GroupName,SortOrder', 90);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('_ColumnDocs', 'Spaltenbeschreibungen', 'Meta', 'Hilfetexte und Eingabefeld-Typ jeder Spalte in der Verwaltung.', 'TableName,ColumnName,Editor,Description', 91);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('Dungeons', 'Ruinen', 'Ruinen', 'Begehbare Ruinen. Erscheinen zufällig auf der Weltkarte (Settings.DungeonChance). Karten im Ruinen-Editor bearbeiten.', 'Key,Name,Marker,Biomes,MinDanger,Weight', 12);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('DungeonFloors', 'Stockwerke', 'Ruinen', 'Karten der Ruinen. Bearbeitung im Ruinen-Editor.', 'Id,DungeonKey,Name,SortOrder,Width,Height,DangerOffset', 13);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('DungeonObjects', 'Ruinen-Objekte', 'Ruinen', 'Ein- und Ausgänge, Übergänge, Behälter, Türen, Gegner, Ereignisse und Auslöser auf einem Stockwerk.', 'Id,FloorId,X,Y,Kind,Label', 14);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('DungeonTiles', 'Kachel-Palette', 'Ruinen', 'Kacheln für Gelände (terrain) und Symbole für Objekte (object), je ein SVG im 48×48-Feld.', 'Key,Name,Svg,Layer,Passable,SortOrder', 15);
INSERT INTO _TableDocs (TableName,Label,GroupName,Description,DisplayColumns,SortOrder) VALUES ('DungeonStory', 'Storyboard', 'Ruinen', 'Story-Texte. Werden über den Effekt story:KEY angezeigt und im Journal gesammelt.', 'Key,DungeonKey,Title,SortOrder', 16);

-- Spaltenbeschreibungen: Hilfetexte und Eingabefeld-Typ jeder Spalte in der Verwaltung.
CREATE TABLE _ColumnDocs (
    TableName   TEXT NOT NULL,
    ColumnName  TEXT NOT NULL,
    Description TEXT,
    Editor      TEXT,             -- Eingabefeld in der Verwaltung, siehe docs/ENTWICKLUNG.md
    PRIMARY KEY (TableName, ColumnName)
);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Settings', 'Key', 'Name der Regel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Settings', 'Value', 'Wert (Zahlen mit Punkt als Dezimaltrenner)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Settings', 'Description', 'Erklärung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Texts', 'Key', 'Schlüssel, z. B. intro, death', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Texts', 'Text', 'Text', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Lore', 'Id', 'Automatische Nummer', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Lore', 'Title', 'Überschrift im Journal', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Lore', 'Text', 'Inhalt', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Lore', 'MinDanger', 'Ab dieser Gefahrenstufe auffindbar', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Attributes', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Attributes', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Attributes', 'Abbrev', 'Kürzel (3 Buchstaben)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Attributes', 'Description', 'Beschreibung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Attributes', 'SortOrder', 'Reihenfolge', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'AttributeKey', 'Leitattribut: zählt × SkillPerAttribute in den Fertigkeitswert', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'Category', 'Gruppe (nur Anzeige)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'Description', 'Beschreibung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Skills', 'SortOrder', 'Reihenfolge', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Description', 'Beschreibung unter der Karte', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Color', 'Grundfarbe des Feldes', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'AccentColor', 'Akzentfarbe', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Glyph', 'SVG-Symbol im 48×48-Feld', 'svg:48');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'HeightMin', 'Höhe von (0–1, leer = 0)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'HeightMax', 'Höhe bis (0–1, leer = 1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'MoistMin', 'Feuchte von (0–1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'MoistMax', 'Feuchte bis (0–1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Priority', 'Bei Überschneidung gewinnt die höhere Priorität', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'DangerBonus', 'Zusätzliche Gefahrenstufen', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'EventChance', 'Anteil der Felder mit einem Ort (0–1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'EncounterChance', 'Begegnungsrisiko pro Schritt (0–1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Passable', 'Begehbar', 'bool');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Biomes', 'Generated', 'Wird von der Weltgenerierung benutzt (Bunker: nein)', 'bool');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Description', 'Beschreibung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Category', 'Art des Gegenstands', 'enum:weapon,armor,consumable,ammo');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Slot', 'Ausrüstungsplatz (nur Waffen/Rüstung)', 'enum:melee,ranged,body,head');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'SkillKey', 'Fertigkeit für den Angriff (nur Waffen)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'DamageMin', 'Schaden min', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'DamageMax', 'Schaden max', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Armor', 'Rüstungswert', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'HealMin', 'Heilung min', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'HealMax', 'Heilung max (bei gelungener Heilung-Probe)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'AmmoKey', 'Verbrauchte Munition (leer = keine)', 'ref:Items');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Rarity', 'Gewicht beim Auswürfeln von Beute (0 = nie)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'MinDanger', 'Ab Gefahrenstufe', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'MaxDanger', 'Bis Gefahrenstufe (leer = unbegrenzt)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Biomes', 'Wo der Gegenstand als Beute vorkommt', 'biomes');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Scales', 'Bekommt beim Fund eine Stufe (+Schaden/+Rüstung)', 'bool');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Color', 'Farbe des Symbols', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Items', 'Value', 'Interner Tauschwert pro Stück bei Stufe 0 (0 = nicht handelbar)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Description', 'Beschreibung im Kampf', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Hp', 'Lebenspunkte', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Attack', 'Trefferchance in % (vor Ausweichen)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Defense', 'Senkt die Trefferchance des Spielers um so viele %', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'DamageMin', 'Schaden min', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'DamageMax', 'Schaden max', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Armor', 'Senkt erlittenen Schaden', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Xp', 'Erfahrung bei Sieg', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'MinDanger', 'Ab Gefahrenstufe', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'MaxDanger', 'Bis Gefahrenstufe (leer = unbegrenzt)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Biomes', 'Wo der Gegner vorkommt', 'biomes');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Weight', 'Häufigkeit bei combat:*', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'LootChance', 'Chance auf Beute (0–1)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Color', 'Farbe des Icons', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Enemies', 'Icon', 'SVG-Icon im 64×64-Feld (currentColor = Farbe)', 'svg:64');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Title', 'Überschrift', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Text', 'Beschreibung der Situation', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Kind', 'poi = fester Ort, encounter = zufällige Begegnung, dungeon = nur in Ruinen', 'enum:poi,encounter,dungeon');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Biomes', 'Wo das Ereignis vorkommt', 'biomes');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'MinDanger', 'Ab Gefahrenstufe', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'MaxDanger', 'Bis Gefahrenstufe (leer = unbegrenzt)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Weight', 'Häufigkeit', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Events', 'Marker', 'Zeichen auf der Karte', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'Id', 'Automatische Nummer', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'EventKey', 'Zugehöriges Ereignis', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'SortOrder', 'Reihenfolge (Taste 1–9)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'Label', 'Text der Option', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'SkillKey', 'Probe auf diese Fertigkeit (leer = gelingt immer)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'Difficulty', 'Modifikator auf die Chance (negativ = schwerer)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'DangerScaling', 'Malus je Gefahrenstufe (Settings.DangerCheckPenalty)', 'bool');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'RequiresItem', 'Nur verfügbar mit diesem Gegenstand', 'ref:Items');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'SuccessText', 'Text bei Erfolg', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'SuccessEffects', 'Effekte bei Erfolg', 'effects');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'FailText', 'Text bei Fehlschlag', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('EventOptions', 'FailEffects', 'Effekte bei Fehlschlag', 'effects');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Key', 'Interner Schlüssel (für trade:KEY)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Greeting', 'Begrüßung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Categories', 'Kategorien/Slots im Sortiment', 'cats');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'StockMin', 'Sortimentsgröße min', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'StockMax', 'Sortimentsgröße max', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'PayFactor', 'So viel ist ihm deine Ware wert (0.7 = 70 %)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'PriceFactor', 'So viel verlangt er für seine Ware (1.2 = 120 %)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Weight', 'Häufigkeit bei trade:*', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Traders', 'Color', 'Farbe', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'TableName', 'Name der Tabelle', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'Label', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'GroupName', 'Gruppe im Menü', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'Description', 'Beschreibung', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'DisplayColumns', 'Spalten der Listenansicht, kommagetrennt', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_TableDocs', 'SortOrder', 'Reihenfolge im Menü', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_ColumnDocs', 'TableName', 'Tabelle', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_ColumnDocs', 'ColumnName', 'Spalte', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_ColumnDocs', 'Description', 'Hilfetext', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('_ColumnDocs', 'Editor', 'Eingabefeld: multiline, bool, color, enum:a,b, ref:Tabelle, biomes, cats, effects, svg:48, svg:64', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'Key', 'Interner Schlüssel', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'Name', 'Anzeigename in der Palette', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'Layer', 'terrain = Gelände, object = Symbol für Objekte', 'enum:terrain,object');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'Svg', 'SVG im 48×48-Feld', 'svg:48');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'Passable', 'Begehbar (nur für Gelände)', 'bool');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonTiles', 'SortOrder', 'Reihenfolge in der Palette', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Key', 'Interner Schlüssel (für dungeon:KEY)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Name', 'Anzeigename', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Description', 'Text am Eingang', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Biomes', 'Wo die Ruine auf der Weltkarte erscheinen kann', 'biomes');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'MinDanger', 'Ab Gefahrenstufe', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'MaxDanger', 'Bis Gefahrenstufe (leer = unbegrenzt)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Weight', 'Häufigkeit im Vergleich zu anderen Ruinen', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Marker', 'Zeichen auf der Weltkarte', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('Dungeons', 'Color', 'Farbe der Markierung', 'color');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'Id', 'Automatische Nummer', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'DungeonKey', 'Zugehörige Ruine', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'Name', 'Name des Stockwerks', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'SortOrder', 'Reihenfolge (das erste Stockwerk mit Eingang ist der Start)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'Width', 'Breite in Kacheln', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'Height', 'Höhe in Kacheln', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'DangerOffset', 'Zusätzliche Gefahrenstufen auf diesem Stockwerk', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonFloors', 'Tiles', 'Kartendaten – im Ruinen-Editor bearbeiten', 'mapdata');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Id', 'Automatische Nummer', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'FloorId', 'Stockwerk', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'X', 'Spalte (0 = links)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Y', 'Zeile (0 = oben)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Kind', 'Art des Objekts', 'enum:entrance,exit,transition,container,door,enemy,event,trigger');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Icon', 'Symbol aus der Kachel-Palette (Layer object)', 'ref:DungeonTiles');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Label', 'Name/Überschrift im Dialog', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Description', 'Beschreibung im Dialog', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'EnemyKey', 'Gegner (nur Art enemy)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'EventKey', 'Ereignis (nur Art event)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'SkillKey', 'Probe zum Öffnen (Behälter/Tür, leer = offen)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Difficulty', 'Modifikator der Probe', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'Effects', 'Inhalt bzw. Wirkung (Behälter, Tür, Auslöser, Gegner nach Sieg)', 'effects');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'FailEffects', 'Wirkung bei misslungener Probe (z. B. Falle). Das Objekt bleibt geschlossen.', 'effects');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'TargetFloorId', 'Ziel-Stockwerk (nur Übergang)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'TargetX', 'Ziel-Spalte', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonObjects', 'TargetY', 'Ziel-Zeile', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonStory', 'Key', 'Schlüssel für story:KEY', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonStory', 'DungeonKey', 'Zugehörige Ruine (leer = allgemein)', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonStory', 'Title', 'Überschrift', NULL);
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonStory', 'Text', 'Text', 'multiline');
INSERT INTO _ColumnDocs (TableName,ColumnName,Description,Editor) VALUES ('DungeonStory', 'SortOrder', 'Reihenfolge im Storyboard', NULL);
