-- =====================================================================
--  EndlessSurvive - Inhaltsdatenbank (content.db)
--  Alle Spielinhalte stehen hier. Neue Inhalte = neue Zeilen.
--  Der Code enthaelt keine Inhalte, nur Regeln.
-- =====================================================================
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------
-- Globale Spielregeln / Balancing (Key/Value)
-- ---------------------------------------------------------------------
CREATE TABLE Settings (
    Key         TEXT PRIMARY KEY,
    Value       TEXT NOT NULL,
    Description TEXT
);

INSERT INTO Settings VALUES
 ('XpBase',               '100',  'XP fuer Stufe 2. Benoetigte XP je Stufe = XpBase * Stufe^XpExponent'),
 ('XpExponent',           '1.6',  'Exponent der XP-Kurve (endlos steigend)'),
 ('AttributeStart',       '5',    'Startwert jedes Attributs'),
 ('AttributeCreationPoints','8',  'Freie Attributpunkte bei Charaktererstellung'),
 ('AttributeCreationMax', '10',   'Maximalwert eines Attributs bei Charaktererstellung'),
 ('SkillCreationPoints',  '6',    'Freie Fertigkeitspunkte bei Charaktererstellung'),
 ('AttributePointsPerLevel','1',  'Attributpunkte pro Stufenaufstieg'),
 ('SkillPointsPerLevel',  '3',    'Fertigkeitspunkte pro Stufenaufstieg'),
 ('SkillBase',            '10',   'Grundwert jeder Fertigkeit in Prozent'),
 ('SkillPerAttribute',    '3',    'Prozentpunkte pro Punkt im Leitattribut'),
 ('SkillPerRank',         '4',    'Prozentpunkte pro Fertigkeitsrang'),
 ('ChanceMin',            '5',    'Minimale Erfolgschance einer Probe'),
 ('ChanceMax',            '95',   'Maximale Erfolgschance einer Probe'),
 ('HpBase',               '20',   'Lebenspunkte Basis'),
 ('HpPerEndurance',       '4',    'Lebenspunkte pro Punkt Ausdauer'),
 ('HpPerLevel',           '3',    'Lebenspunkte pro Stufe'),
 ('DangerDistance',       '8',    'Felder Entfernung vom Bunker pro Gefahrenstufe'),
 ('DangerCheckPenalty',   '2',    'Malus auf Proben pro Gefahrenstufe (bei DangerScaling=1)'),
 ('EnemyHpPerDanger',     '0.22', 'Gegner-LP-Zuwachs je Gefahrenstufe (Faktor)'),
 ('EnemyDamagePerDanger', '0.12', 'Gegner-Schadenszuwachs je Gefahrenstufe (Faktor)'),
 ('EnemyAttackPerDanger', '2',    'Gegner-Angriff (Prozent) je Gefahrenstufe'),
 ('EnemyXpPerDanger',     '0.3',  'Gegner-XP-Zuwachs je Gefahrenstufe (Faktor)'),
 ('ItemDamagePerLevel',   '0.15', 'Waffenschaden-Zuwachs je Gegenstandsstufe (Faktor)'),
 ('ItemArmorPerLevel',    '0.5',  'Ruestung je Gegenstandsstufe'),
 ('EventXpPerDanger',     '0.25', 'Ereignis-XP-Zuwachs je Gefahrenstufe (Faktor)'),
 ('SightRadius',          '2',    'Sichtweite in Feldern'),
 ('DodgePerAgility',      '2',    'Ausweichen (Prozent) pro Punkt Gewandtheit'),
 ('MeleeStrengthDivisor', '2',    'Nahkampf-Bonusschaden = Staerke / Wert'),
 ('FleeBase',             '25',   'Basis-Fluchtchance'),
 ('AttackBonus',          '15',   'Bonus auf eigene Angriffsproben im Kampf (Prozent)'),
 ('StartBiome',           'bunker','Biom des Startfeldes'),
 ('SafeRadius',           '2',    'Radius um den Bunker ohne unpassierbares Gelaende und Begegnungen'),
 ('RestEncounterFactor',  '2.5',  'Begegnungsrisiko beim Rasten im Freien (Faktor auf Biom-Wert)'),
 ('DeathXpLossPercent',   '25',   'Verlust des XP-Fortschritts der aktuellen Stufe beim Tod'),
 ('ItemValuePerLevel',    '0.25', 'Tauschwert-Zuwachs je Gegenstandsstufe (Faktor)'),
 ('StartItems',           'pipe:1;medkit_small:2;rags:1', 'Startausruestung key:Anzahl');

-- ---------------------------------------------------------------------
-- Texte (Intro, Tod, ...)
-- ---------------------------------------------------------------------
CREATE TABLE Texts (
    Key  TEXT PRIMARY KEY,
    Text TEXT NOT NULL
);

INSERT INTO Texts VALUES
 ('title',      'ENDLESS SURVIVE'),
 ('subtitle',   'Die Welt ist vorbei. Du bist es noch nicht.'),
 ('intro',      'Ein Summen. Notbeleuchtung, rot und flackernd. Die Kryokapsel oeffnet sich mit einem Zischen, und kalte, abgestandene Luft fuellt deine Lungen. Die anderen Kapseln sind leer – oder schlimmer. Auf dem Terminal blinkt nur ein Datum, das keinen Sinn ergibt, und ein Wort: AUSGANG. Die schwere Bunkertuer steht einen Spalt offen. Dahinter: Asche, Ruinen, Stille.'),
 ('death',      'Dunkelheit. Dann wieder das rote Flackern. Irgendwie hast du es zurueck in den Bunker geschafft – oder jemand hat dich hergebracht. Dein Koerper schmerzt, deine Erinnerungen an die letzten Stunden sind luekenhaft.'),
 ('bunker',     'Der Bunker. Dicke Betonwaende, ein surrender Generator, deine Kapsel. Hier bist du sicher.'),
 ('levelup',    'Du fuehlst dich staerker. Die Oednis formt dich.');

-- ---------------------------------------------------------------------
-- Attribute
-- ---------------------------------------------------------------------
CREATE TABLE Attributes (
    Key         TEXT PRIMARY KEY,
    Name        TEXT NOT NULL,
    Abbrev      TEXT NOT NULL,
    Description TEXT,
    SortOrder   INTEGER NOT NULL DEFAULT 0
);

INSERT INTO Attributes VALUES
 ('str', 'Staerke',      'STR', 'Rohe Kraft. Erhoeht Nahkampfschaden und Nahkampf.', 1),
 ('end', 'Ausdauer',     'AUS', 'Zaehigkeit. Erhoeht Lebenspunkte und Ueberleben.', 2),
 ('int', 'Intelligenz',  'INT', 'Verstand. Grundlage fuer Hacken, Heilung und Wahrnehmung.', 3),
 ('agi', 'Gewandtheit',  'GEW', 'Geschick und Reflexe. Ausweichen, Fernkampf, Schloesser.', 4);

-- ---------------------------------------------------------------------
-- Fertigkeiten (Prozentwerte, Probe: W100 <= Wert)
-- Key-Werte 'melee','ranged','healing','stealth' werden vom Kampfsystem genutzt.
-- ---------------------------------------------------------------------
CREATE TABLE Skills (
    Key          TEXT PRIMARY KEY,
    Name         TEXT NOT NULL,
    AttributeKey TEXT NOT NULL REFERENCES Attributes(Key),
    Category     TEXT NOT NULL,
    Description  TEXT,
    SortOrder    INTEGER NOT NULL DEFAULT 0
);

INSERT INTO Skills VALUES
 ('melee',      'Nahkampf',          'str', 'Kampf', 'Treffen mit Klingen, Knueppeln und Faeusten.', 1),
 ('ranged',     'Fernkampf',         'agi', 'Kampf', 'Treffen mit Boegen, Pistolen und Gewehren.', 2),
 ('hacking',    'Hacken',            'int', 'Technik', 'Alte Terminals und Sicherheitssysteme ueberlisten.', 3),
 ('lockpick',   'Schloesser knacken','agi', 'Technik', 'Tueren, Kisten und Spinde oeffnen.', 4),
 ('mechanics',  'Mechanik',          'int', 'Technik', 'Maschinen reparieren, Fallen entschaerfen.', 5),
 ('healing',    'Heilung',           'int', 'Ueberleben', 'Wunden versorgen. Verbessert Heilgegenstaende und Rasten.', 6),
 ('survival',   'Ueberleben',        'end', 'Ueberleben', 'Nahrung finden, Wetter trotzen, Spuren lesen.', 7),
 ('stealth',    'Schleichen',        'agi', 'Ueberleben', 'Ungesehen bleiben. Hilft bei Flucht und Hinterhalten.', 8),
 ('perception', 'Wahrnehmung',       'int', 'Ueberleben', 'Verborgenes entdecken, Gefahren frueh erkennen.', 9),
 ('athletics',  'Athletik',          'str', 'Ueberleben', 'Klettern, Springen, Schweres heben.', 10);

-- ---------------------------------------------------------------------
-- Biome. Welt wird aus zwei Rauschwerten (Hoehe, Feuchte, je 0..1) erzeugt.
-- Das passende Biom mit der hoechsten Priority gewinnt.
-- Glyph: SVG-Markup in einem 48x48 Feld.
-- ---------------------------------------------------------------------
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

INSERT INTO Biomes VALUES
 ('bunker', 'Bunker', 'Dein Zuhause. Sicher, kalt, still.', '#3a3f47', '#f2b43a',
  '<rect x="10" y="14" width="28" height="22" rx="3" fill="#23272e" stroke="#f2b43a" stroke-width="2"/><circle cx="24" cy="25" r="6" fill="none" stroke="#f2b43a" stroke-width="2"/><path d="M24 19v12M18 25h12" stroke="#f2b43a" stroke-width="1.5"/>',
  NULL, NULL, NULL, NULL, 0, 0, 0, 0, 1, 0),
 ('wasteland', 'Oedland', 'Rissige Erde, so weit das Auge reicht.', '#6b5d4a', '#8a7a62',
  '<circle cx="12" cy="14" r="1.4" fill="#8a7a62"/><circle cx="34" cy="30" r="1.2" fill="#8a7a62"/><path d="M8 36l6-3 4 4" stroke="#4f4436" fill="none"/><path d="M28 12l5 2 3-3" stroke="#4f4436" fill="none"/>',
  0, 1, 0, 1, 0, 0, 0.10, 0.06, 1, 1),
 ('ashdesert', 'Aschewueste', 'Graue Duenen aus Asche. Der Wind heult.', '#8d867b', '#a9a296',
  '<path d="M4 30q10-8 20 0t20 0" stroke="#a9a296" stroke-width="2" fill="none"/><path d="M8 18q8-6 16 0t16 0" stroke="#787266" stroke-width="1.5" fill="none"/>',
  0.42, 0.78, 0, 0.32, 10, 0, 0.08, 0.07, 1, 1),
 ('ruins', 'Truemmerstadt', 'Skelette von Hochhaeusern, eingestuerzte Strassen.', '#4d4f55', '#6e7179',
  '<rect x="8" y="18" width="9" height="22" fill="#6e7179"/><rect x="20" y="10" width="10" height="30" fill="#5c5f66"/><rect x="33" y="22" width="8" height="18" fill="#6e7179"/><rect x="22" y="14" width="2" height="3" fill="#2f3136"/><rect x="26" y="20" width="2" height="3" fill="#2f3136"/><path d="M30 10l3 5" stroke="#3b3d42" stroke-width="2"/>',
  0.42, 0.75, 0.32, 0.65, 10, 0, 0.14, 0.08, 1, 1),
 ('deadforest', 'Toter Wald', 'Schwarze Baumstuempfe, knisterndes Unterholz.', '#3e3a2c', '#5a5340',
  '<path d="M14 40V18M14 24l-5-5M14 28l5-4" stroke="#1f1c14" stroke-width="2.5" fill="none"/><path d="M32 40V12M32 18l6-5M32 26l-6-4M32 32l5-2" stroke="#26221a" stroke-width="2.5" fill="none"/>',
  0.42, 0.78, 0.65, 1.0, 10, 0, 0.13, 0.09, 1, 1),
 ('swamp', 'Giftsumpf', 'Bruehe in unnatuerlichem Gruen. Blasen steigen auf.', '#3d5236', '#6f9a3a',
  '<ellipse cx="16" cy="20" rx="8" ry="3" fill="#6f9a3a" opacity=".7"/><ellipse cx="32" cy="34" rx="10" ry="3.5" fill="#6f9a3a" opacity=".6"/><circle cx="30" cy="16" r="1.8" fill="#a9d35a"/><circle cx="12" cy="34" r="1.2" fill="#a9d35a"/>',
  0.22, 0.42, 0.55, 1.0, 20, 1, 0.12, 0.10, 1, 1),
 ('scrapyard', 'Industriebrache', 'Rostige Tanks, Kraene und Schrottberge.', '#5e4130', '#9a5b34',
  '<rect x="7" y="22" width="14" height="18" rx="2" fill="#7d4a2b"/><ellipse cx="14" cy="22" rx="7" ry="2.5" fill="#b06a3c"/><path d="M28 40V12h4v28M32 12h12v4M42 16v6" stroke="#b06a3c" stroke-width="2" fill="none"/><path d="M28 18l4 6M32 18l-4 6M28 28l4 6M32 28l-4 6" stroke="#9a5b34"/>',
  0.22, 0.42, 0, 0.55, 20, 1, 0.13, 0.08, 1, 1),
 ('craters', 'Kraterfeld', 'Bombenkrater, glasiger Boden, Strahlung.', '#2f2b2e', '#59505a',
  '<circle cx="18" cy="20" r="9" fill="#1f1c1f" stroke="#59505a" stroke-width="2"/><circle cx="34" cy="34" r="6" fill="#1f1c1f" stroke="#59505a" stroke-width="1.5"/>',
  0.78, 0.90, 0, 1.0, 30, 2, 0.15, 0.12, 1, 1),
 ('mountains', 'Felsgrat', 'Zerklueftete Felsen. Kein Durchkommen.', '#28262a', '#4a464e',
  '<path d="M4 40l12-24 8 12 6-8 14 20z" fill="#4a464e"/><path d="M16 16l3 6-3-1-3 2z" fill="#8f8a94"/>',
  0.90, 1.0, 0, 1.0, 40, 0, 0, 0, 0, 1),
 ('lake', 'Verstrahlter See', 'Schillerndes, totes Wasser. Unpassierbar.', '#1c3a3f', '#2e6b70',
  '<path d="M6 18q6-4 12 0t12 0t12 0" stroke="#3f8d8f" stroke-width="1.5" fill="none"/><path d="M6 32q6-4 12 0t12 0t12 0" stroke="#2e6b70" stroke-width="1.5" fill="none"/>',
  0, 0.22, 0, 1.0, 40, 0, 0, 0, 0, 1);

-- ---------------------------------------------------------------------
-- Gegenstaende
-- Category: weapon | armor | consumable | ammo
-- Slot: melee | ranged | body | head (nur bei weapon/armor)
-- Scales=1: Gegenstand erhaelt beim Fund eine Stufe = Gefahrenstufe
-- Value: interner Tauschwert pro Stueck bei Stufe 0 (0 = wertlos)
-- Biomes: '*' = ueberall, sonst kommagetrennte Biom-Keys
-- ---------------------------------------------------------------------
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

INSERT INTO Items (Key,Name,Description,Category,Slot,SkillKey,DamageMin,DamageMax,Armor,HealMin,HealMax,AmmoKey,Rarity,MinDanger,MaxDanger,Biomes,Scales,Color) VALUES
 -- Nahkampf
 ('pipe',      'Bleirohr',      'Schwer, verbogen, verlaesslich.',  'weapon','melee','melee', 2,5, 0, 0,0, NULL, 12, 0, 4,  '*',1,'#b0b4ba'),
 ('knife',     'Kampfmesser',   'Rostige Klinge mit Profil.',       'weapon','melee','melee', 3,5, 0, 0,0, NULL, 10, 0, 6,  '*',1,'#d0d4da'),
 ('machete',   'Machete',       'Gut fuer Gestruepp und Haelse.',   'weapon','melee','melee', 4,8, 0, 0,0, NULL, 8, 2, NULL,'deadforest,swamp,wasteland',1,'#d8d0b0'),
 ('sledge',    'Vorschlaghammer','Langsam. Endgueltig.',            'weapon','melee','melee', 5,11,0, 0,0, NULL, 6, 3, NULL,'scrapyard,ruins',1,'#a08a70'),
 ('rebarclub', 'Moniereisen-Keule','Beton noch dran.',              'weapon','melee','melee', 4,9, 0, 0,0, NULL, 8, 1, NULL,'ruins,scrapyard',1,'#8f8f8f'),
 ('chainblade','Kettensaegenklinge','Laut, hungrig, unaufhaltsam.', 'weapon','melee','melee', 8,15,0, 0,0, NULL, 3, 6, NULL,'*',1,'#e05a3a'),
 -- Fernkampf
 ('slingshot', 'Schleuder',     'Kinderspielzeug, toedlich mit Muttern.','weapon','ranged','ranged',2,4,0,0,0, NULL, 10, 0, 4, '*',1,'#c9a56a'),
 ('bow',       'Rohrbogen',     'Aus Kunststoffrohr und Draht.',    'weapon','ranged','ranged', 3,7, 0, 0,0, 'arrows', 8, 1, NULL,'deadforest,wasteland',1,'#a0784a'),
 ('pistol',    '9mm Pistole',   'Abgegriffen, aber funktionsfaehig.','weapon','ranged','ranged',5,9, 0, 0,0, 'ammo9', 6, 2, NULL,'ruins,scrapyard,craters',1,'#7a7f88'),
 ('shotgun',   'Schrotflinte',  'Zwei Laeufe, kein Pardon.',        'weapon','ranged','ranged', 7,14,0, 0,0, 'shells', 4, 4, NULL,'*',1,'#6a5a4a'),
 ('rifle',     'Jagdgewehr',    'Zielfernrohr mit Sprung.',         'weapon','ranged','ranged', 9,16,0, 0,0, 'ammo762', 3, 6, NULL,'*',1,'#5a6a5a'),
 -- Munition
 ('arrows',    'Pfeile',        'Gebuendelt, selbstgemacht.',       'ammo', NULL,NULL,0,0,0,0,0,NULL, 12, 1, NULL,'*',0,'#c0a070'),
 ('ammo9',     '9mm Patronen',  'Eine Handvoll Messing.',           'ammo', NULL,NULL,0,0,0,0,0,NULL, 10, 2, NULL,'*',0,'#d8b84a'),
 ('shells',    'Schrotpatronen','Rote Huelsen.',                    'ammo', NULL,NULL,0,0,0,0,0,NULL, 8, 4, NULL,'*',0,'#c04a3a'),
 ('ammo762',   '7.62 Patronen', 'Lang und schwer.',                 'ammo', NULL,NULL,0,0,0,0,0,NULL, 6, 6, NULL,'*',0,'#b8a04a'),
 -- Ruestung
 ('rags',      'Lumpenkleidung','Besser als nichts.',               'armor','body',NULL, 0,0, 1, 0,0, NULL, 10, 0, 3, '*',1,'#8a7a6a'),
 ('leather',   'Lederjacke',    'Zerkratzt, aber zaeh.',            'armor','body',NULL, 0,0, 2, 0,0, NULL, 8, 1, NULL,'*',1,'#7a4a2a'),
 ('scrapmail', 'Schrottpanzer', 'Blechplatten, zusammengenietet.',  'armor','body',NULL, 0,0, 4, 0,0, NULL, 5, 3, NULL,'scrapyard,ruins',1,'#8a8a7a'),
 ('kevlar',    'Kevlarweste',   'Militaerbestand.',                 'armor','body',NULL, 0,0, 5, 0,0, NULL, 3, 5, NULL,'*',1,'#4a5a4a'),
 ('cap',       'Wollmuetze',    'Haelt warm.',                      'armor','head',NULL, 0,0, 0, 0,0, NULL, 6, 0, 3, '*',1,'#6a6a8a'),
 ('helmet',    'Bauhelm',       'Gelb und verbeult.',               'armor','head',NULL, 0,0, 1, 0,0, NULL, 6, 1, NULL,'ruins,scrapyard',1,'#e0c040'),
 ('gasmask',   'Gasmaske',      'Filter fast leer.',                'armor','head',NULL, 0,0, 2, 0,0, NULL, 4, 2, NULL,'swamp,craters,scrapyard',1,'#5a6a5a'),
 -- Verbrauchsgueter
 ('medkit_small','Verbandspaeckchen','Mull und Desinfektion.',      'consumable',NULL,NULL,0,0,0, 6,10, NULL, 14, 0, NULL,'*',0,'#e8e8e8'),
 ('medkit',    'Erste-Hilfe-Kasten','Komplett. Fast.',              'consumable',NULL,NULL,0,0,0, 14,24, NULL, 8, 2, NULL,'*',0,'#e04040'),
 ('stimpak',   'Stimpak',       'Injektion. Wirkt sofort.',         'consumable',NULL,NULL,0,0,0, 30,50, NULL, 4, 5, NULL,'*',0,'#40c0e0'),
 ('cannedfood','Konservendose', 'Bohnen. Ablaufdatum: egal.',       'consumable',NULL,NULL,0,0,0, 3,6,  NULL, 14, 0, NULL,'*',0,'#c0a040'),
 ('water',     'Gefiltertes Wasser','Fast klar.',                   'consumable',NULL,NULL,0,0,0, 2,5,  NULL, 12, 0, NULL,'*',0,'#60a0e0'),
 ('mutfruit',  'Mutantenfrucht','Leuchtet leicht. Schmeckt suess.', 'consumable',NULL,NULL,0,0,0, 4,12, NULL, 8, 1, NULL,'swamp,deadforest',0,'#a0e040');

-- Tauschwerte
UPDATE Items SET Value =   8 WHERE Key = 'pipe';
UPDATE Items SET Value =  10 WHERE Key = 'knife';
UPDATE Items SET Value =  18 WHERE Key = 'machete';
UPDATE Items SET Value =  24 WHERE Key = 'sledge';
UPDATE Items SET Value =  16 WHERE Key = 'rebarclub';
UPDATE Items SET Value =  60 WHERE Key = 'chainblade';
UPDATE Items SET Value =   8 WHERE Key = 'slingshot';
UPDATE Items SET Value =  20 WHERE Key = 'bow';
UPDATE Items SET Value =  35 WHERE Key = 'pistol';
UPDATE Items SET Value =  50 WHERE Key = 'shotgun';
UPDATE Items SET Value =  65 WHERE Key = 'rifle';
UPDATE Items SET Value =   1 WHERE Key = 'arrows';
UPDATE Items SET Value =   2 WHERE Key = 'ammo9';
UPDATE Items SET Value =   3 WHERE Key = 'shells';
UPDATE Items SET Value =   4 WHERE Key = 'ammo762';
UPDATE Items SET Value =   3 WHERE Key = 'rags';
UPDATE Items SET Value =  15 WHERE Key = 'leather';
UPDATE Items SET Value =  30 WHERE Key = 'scrapmail';
UPDATE Items SET Value =  45 WHERE Key = 'kevlar';
UPDATE Items SET Value =   4 WHERE Key = 'cap';
UPDATE Items SET Value =  10 WHERE Key = 'helmet';
UPDATE Items SET Value =  18 WHERE Key = 'gasmask';
UPDATE Items SET Value =   6 WHERE Key = 'medkit_small';
UPDATE Items SET Value =  15 WHERE Key = 'medkit';
UPDATE Items SET Value =  35 WHERE Key = 'stimpak';
UPDATE Items SET Value =   4 WHERE Key = 'cannedfood';
UPDATE Items SET Value =   3 WHERE Key = 'water';
UPDATE Items SET Value =   5 WHERE Key = 'mutfruit';

-- ---------------------------------------------------------------------
-- Gegner
-- Attack/Defense in Prozent. Werte gelten fuer Gefahrenstufe 0 und
-- werden per Settings mit der Gefahrenstufe skaliert.
-- Icon: SVG-Markup in einer 64x64 Box
-- ---------------------------------------------------------------------
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

INSERT INTO Enemies VALUES
 ('rat',     'Riesenratte',    'Groesser als ein Hund, haessliche Zaehne.', 8, 45, 0, 1,3, 0, 12, 0, 5,  '*', 14, 0.15, '#8a6a5a',
  '<ellipse cx="34" cy="38" rx="18" ry="11" fill="currentColor"/><circle cx="16" cy="32" r="8" fill="currentColor"/><circle cx="12" cy="30" r="1.8" fill="#ff4040"/><path d="M50 40q10 4 8 14" stroke="currentColor" stroke-width="2.5" fill="none"/><path d="M10 36l-3 3M12 37l-1 4" stroke="#eee" stroke-width="1.5"/>'),
 ('dog',     'Wilder Hund',    'Abgemagert, rasend vor Hunger.',  12, 50, 5, 2,4, 0, 18, 0, 6, 'wasteland,deadforest,ruins,ashdesert', 10, 0.1, '#7a6040',
  '<path d="M12 30l8-10 6 6h18l8 6v14h-4v-8H24v8h-4V36z" fill="currentColor"/><circle cx="18" cy="26" r="1.6" fill="#ff5030"/><path d="M52 32l8-6" stroke="currentColor" stroke-width="3"/>'),
 ('scav',    'Pluenderer',     'Ein Mensch. Oder was davon uebrig ist.', 16, 50, 5, 2,6, 1, 25, 0, NULL, 'ruins,scrapyard,wasteland,ashdesert', 10, 0.6, '#b07050',
  '<circle cx="32" cy="16" r="8" fill="currentColor"/><path d="M20 58V32q0-6 12-6t12 6v26h-6V42h-12v16z" fill="currentColor"/><rect x="26" y="13" width="12" height="4" fill="#222"/><path d="M44 30l10-10" stroke="#aaa" stroke-width="3"/>'),
 ('ghoul',   'Ghul',           'Verstrahlte Haut, leere Augen, schnelle Beine.', 18, 55, 5, 3,6, 0, 30, 1, NULL, 'craters,ruins,swamp', 9, 0.25, '#7a9a5a',
  '<circle cx="32" cy="16" r="9" fill="currentColor"/><circle cx="28" cy="15" r="2" fill="#ff0"/><circle cx="36" cy="15" r="2" fill="#ff0"/><path d="M22 58l4-30h12l4 30M22 32l-10 12M42 32l10 12" stroke="currentColor" stroke-width="5" fill="none"/>'),
 ('swamper', 'Sumpfkriecher',  'Etwas mit zu vielen Beinen.',     20, 50, 0, 3,7, 2, 32, 1, NULL, 'swamp', 10, 0.2, '#5a8a3a',
  '<ellipse cx="32" cy="34" rx="16" ry="12" fill="currentColor"/><path d="M18 30l-12-8M18 38l-12 4M46 30l12-8M46 38l12 4M24 44l-6 12M40 44l6 12" stroke="currentColor" stroke-width="3"/><circle cx="26" cy="28" r="2.5" fill="#f60"/><circle cx="38" cy="28" r="2.5" fill="#f60"/>'),
 ('drone',   'Wachdrohne',     'Sie hat ihren Befehl nie vergessen.', 14, 55, 15, 3,6, 3, 35, 2, NULL, 'ruins,scrapyard,craters', 7, 0.5, '#8a9aaa',
  '<ellipse cx="32" cy="32" rx="12" ry="8" fill="currentColor"/><circle cx="32" cy="33" r="4" fill="#f22"/><path d="M8 22h16M40 22h16M16 22v6M48 22v6" stroke="currentColor" stroke-width="3"/>'),
 ('raider',  'Rumtreiber',     'Bewaffnet, organisiert, gnadenlos.', 24, 58, 10, 4,8, 2, 45, 3, NULL, '*', 8, 0.7, '#c05030',
  '<circle cx="32" cy="15" r="8" fill="currentColor"/><path d="M18 58V30q0-6 14-6t14 6v28h-7V42H25v16z" fill="currentColor"/><path d="M24 10l16 0l-2-6h-12z" fill="#333"/><path d="M46 34h14" stroke="#555" stroke-width="4"/>'),
 ('mutant',  'Mutant',         'Zwei Meter Muskeln und Wut.',     40, 55, 0, 6,12, 3, 70, 4, NULL, 'craters,ashdesert,swamp,wasteland', 6, 0.5, '#9a6aa0',
  '<circle cx="32" cy="14" r="9" fill="currentColor"/><path d="M12 58l6-34q14-6 28 0l6 34h-10l-4-18h-12l-4 18z" fill="currentColor"/><path d="M14 28l-6 14M50 28l6 14" stroke="currentColor" stroke-width="7"/>'),
 ('sentry',  'Kampfroboter',   'Rost auf Panzerstahl. Rote Optik.', 45, 62, 10, 6,11, 6, 90, 5, NULL, 'ruins,scrapyard,craters', 5, 0.6, '#a0a8b0',
  '<rect x="18" y="8" width="28" height="18" rx="3" fill="currentColor"/><rect x="24" y="14" width="16" height="5" fill="#f22"/><rect x="14" y="28" width="36" height="20" fill="currentColor"/><path d="M20 48v12M44 48v12M14 34H4M50 34h10" stroke="currentColor" stroke-width="5"/>'),
 ('ashwyrm', 'Aschewurm',      'Bricht aus dem Boden wie ein Zug.', 60, 60, 0, 8,15, 4, 120, 6, NULL, 'ashdesert,craters', 3, 0.4, '#c0b0a0',
  '<path d="M6 58q8-30 26-30t26 30" stroke="currentColor" stroke-width="14" fill="none"/><circle cx="32" cy="22" r="11" fill="currentColor"/><path d="M24 22h16" stroke="#300" stroke-width="4"/><path d="M26 19l2 6 2-6 2 6 2-6 2 6" stroke="#fff" stroke-width="1" fill="none"/>'),
 ('behemoth','Behemoth',       'Die Erde bebt bei jedem Schritt.', 90, 65, 0, 10,20, 6, 200, 9, NULL, '*', 2, 0.9, '#a04040',
  '<path d="M6 56l6-30q20-16 40 0l6 30h-12l-4-14H22l-4 14z" fill="currentColor"/><circle cx="24" cy="26" r="3" fill="#ff0"/><circle cx="40" cy="26" r="3" fill="#ff0"/><path d="M14 18l-6-10M50 18l6-10" stroke="currentColor" stroke-width="5"/>');

-- ---------------------------------------------------------------------
-- Ereignisse
-- Kind: poi       = fester Ort auf der Karte (wird einmalig ausgeloest)
--       encounter = zufaellige Begegnung beim Laufen/Rasten
-- Biomes: '*' oder kommagetrennte Biom-Keys
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- Optionen eines Ereignisses
-- SkillKey: Probe auf Fertigkeit (W100). NULL = automatischer Erfolg.
-- Difficulty: Modifikator auf die Chance (negativ = schwerer).
-- DangerScaling: 1 = Malus je Gefahrenstufe (Settings.DangerCheckPenalty).
-- RequiresItem: Option nur verfuegbar, wenn Gegenstand vorhanden.
-- Effekte (Semikolon-getrennt):
--   xp:N            Erfahrung (skaliert mit Gefahr)
--   loot:N          N zufaellige Gegenstaende
--   lootcat:cat:N   N zufaellige Gegenstaende einer Kategorie
--   item:key:N      bestimmter Gegenstand
--   take:key:N      Gegenstand entfernen
--   heal:N | heal:full | heal:pct:N
--   damage:A-B      Schaden (skaliert mit Gefahr)
--   combat:key | combat:*   Kampf gegen Gegner
--   lore            Zufaelliges Infofragment
--   reveal:R        Karte im Radius R aufdecken
--   trade:key | trade:*   Tauschhandel mit einem Haendler (Tabelle Traders)
--   persist         Ort bleibt bestehen (wird nicht als erledigt markiert)
-- ---------------------------------------------------------------------
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

-- ===== Ereignisse: Orte (poi) ========================================

INSERT INTO Events VALUES ('supply_crate','Verschlossene Kiste','Eine olivgruene Militaerkiste, halb im Schutt vergraben. Ein schweres Vorhaengeschloss haelt sie zu.','poi','*',0,NULL,12,'▣');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('supply_crate',1,'Schloss knacken','lockpick',10,1,NULL,'Mit einem leisen Klicken springt das Schloss auf.','loot:2;xp:15','Der Dietrich bricht ab. Das Schloss ist jetzt endgueltig verklemmt.','xp:3'),
 ('supply_crate',2,'Aufbrechen','athletics',-5,1,NULL,'Mit roher Gewalt reisst du den Deckel auf.','loot:1;xp:10','Du rutschst ab und schneidest dich am Blech.','damage:2-5'),
 ('supply_crate',3,'Liegen lassen',NULL,0,0,NULL,'Du gehst weiter.','persist',NULL,NULL);

INSERT INTO Events VALUES ('terminal','Altes Terminal','Ein Bildschirm flackert in einem halb eingestuerzten Kontrollraum. Der Cursor blinkt. PASSWORT:','poi','ruins,scrapyard,craters',0,NULL,10,'⌨');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('terminal',1,'Ins System hacken','hacking',0,1,NULL,'ZUGRIFF GEWAEHRT. Dateien, Karten, Logbuecher.','lore;reveal:6;xp:25','SYSTEM GESPERRT. Ein Alarm heult kurz auf, dann Stille... nicht ganz.','combat:drone'),
 ('terminal',2,'Gehaeuse ausschlachten','mechanics',5,1,NULL,'Du findest brauchbare Teile und ein Notfallfach.','loot:1;xp:12','Ein Funkenschlag. Autsch.','damage:2-4'),
 ('terminal',3,'Weitergehen',NULL,0,0,NULL,'Du laesst das Terminal hinter dir.','persist',NULL,NULL);

INSERT INTO Events VALUES ('corpse','Leiche','Ein ausgetrockneter Koerper in zerrissener Kleidung. Der Rucksack ist noch da.','poi','*',0,NULL,14,'✝');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('corpse',1,'Vorsichtig durchsuchen','perception',15,1,NULL,'Im Futter eingenaeht: ein Zettel. Und im Rucksack noch etwas Brauchbares.','loot:1;lore;xp:8','Nichts Brauchbares. Nur Staub und Erinnerungen.','xp:2'),
 ('corpse',2,'Rucksack schnappen und weg',NULL,0,0,NULL,'Du nimmst, was du tragen kannst.','loot:1',NULL,NULL);

INSERT INTO Events VALUES ('pharmacy','Pluenderte Apotheke','Das gruene Kreuz ist kaum noch zu erkennen. Regale umgeworfen, Glas ueberall.','poi','ruins',0,NULL,8,'✚');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('pharmacy',1,'Regale durchsuchen','perception',0,1,NULL,'Hinter einem Regal: ein unangetasteter Medizinschrank!','lootcat:consumable:2;xp:12','Leergeraeumt. Jemand war vor dir hier.','xp:3'),
 ('pharmacy',2,'Medikamente bestimmen','healing',5,1,NULL,'Du erkennst, welche Ampullen noch wirken.','item:medkit:1;xp:15','Die Beschriftungen sind verblasst. Du nimmst lieber nichts.','xp:3'),
 ('pharmacy',3,'Tresor im Hinterzimmer','lockpick',-15,1,NULL,'Der Betaeubungsmitteltresor! Fast unberuehrt.','item:stimpak:1;item:medkit:1;xp:30','Zu kompliziert. Der Tresor bleibt zu.','xp:5');

INSERT INTO Events VALUES ('car_wreck','Autowrack','Ein ausgebrannter Kombi. Der Kofferraum ist verbeult, aber geschlossen.','poi','wasteland,ashdesert,ruins',0,NULL,12,'⛍');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('car_wreck',1,'Kofferraum aufhebeln','athletics',5,1,NULL,'Knirschend gibt der Deckel nach.','loot:1;xp:8','Zu verbeult. Du hast dir nur den Ruecken gezerrt.','damage:1-3'),
 ('car_wreck',2,'Handschuhfach knacken','lockpick',15,1,NULL,'Eine Pistole! Jemand hatte vorgesorgt.','lootcat:weapon:1;xp:10','Leer, bis auf eine Strassenkarte von einer Welt, die es nicht mehr gibt.','xp:2'),
 ('car_wreck',3,'Weitergehen',NULL,0,0,NULL,'Du laesst das Wrack hinter dir.','persist',NULL,NULL);

INSERT INTO Events VALUES ('radio_tower','Funkmast','Ein verbogener Mast ragt in den Himmel. Unten ein Schaltkasten, oben eine Plattform.','poi','wasteland,ruins,craters,ashdesert',0,NULL,6,'⚡');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('radio_tower',1,'Hochklettern und umsehen','athletics',0,1,NULL,'Von oben ueberblickst du das Land weit und breit.','reveal:9;xp:15','Eine Sprosse bricht. Du faellst.','damage:3-8'),
 ('radio_tower',2,'Funkgeraet reparieren','mechanics',-5,1,NULL,'Rauschen... dann eine Stimme. Eine Aufzeichnung.','lore;xp:25','Ein Kurzschluss. Der Kasten ist hinueber.','damage:1-4'),
 ('radio_tower',3,'Weitergehen',NULL,0,0,NULL,'Der Mast quietscht im Wind.','persist',NULL,NULL);

INSERT INTO Events VALUES ('nest','Nest','Knochen, Fell und ein ekelhafter Gestank. Etwas lebt hier. Daneben liegen die Habseligkeiten frueherer Opfer.','poi','*',0,NULL,10,'☠');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('nest',1,'Hineinschleichen','stealth',0,1,NULL,'Lautlos greifst du dir die Beute und verschwindest.','loot:2;xp:20','Ein Knacken unter deinem Fuss. Es ist wach.','combat:*'),
 ('nest',2,'Angreifen',NULL,0,0,NULL,'Du stuermst vor!','combat:*;loot:1',NULL,NULL),
 ('nest',3,'Umgehen',NULL,0,0,NULL,'Du schlaegst einen weiten Bogen.','persist',NULL,NULL);

INSERT INTO Events VALUES ('vault_door','Versiegelte Schleuse','Eine runde Stahltuer im Hang, wie die deines Bunkers. Ein Ziffernblock leuchtet schwach.','poi','craters,ruins,wasteland',2,NULL,4,'◉');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('vault_door',1,'Zugangscode hacken','hacking',-10,1,NULL,'Die Schleuse rollt zur Seite. Ein Lagerraum, voll bis unter die Decke.','loot:4;lore;xp:50','FEHLER. Selbstverteidigung aktiviert.','combat:sentry'),
 ('vault_door',2,'Wartungsklappe aufschrauben','mechanics',-15,1,NULL,'Du ueberbrueckst den Mechanismus. Drinnen: Vorraete.','loot:3;xp:40','Nichts zu machen.','xp:5'),
 ('vault_door',3,'Spaeter wiederkommen',NULL,0,0,NULL,'Die Schleuse wartet.','persist',NULL,NULL);

INSERT INTO Events VALUES ('campfire','Verlassenes Lager','Ein Zelt, eine kalte Feuerstelle. Wer immer hier war, ist ueberstuerzt aufgebrochen.','poi','wasteland,deadforest,ashdesert',0,NULL,10,'▲');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('campfire',1,'Ausruhen und Wunden versorgen','healing',20,0,NULL,'Du verbindest deine Wunden sorgfaeltig und schlaefst ein paar Stunden.','heal:pct:60;xp:5','Unruhiger Schlaf, aber immerhin.','heal:pct:25'),
 ('campfire',2,'Spuren lesen','survival',0,1,NULL,'Die Spuren fuehren zu einem Versteck unter einem Stein.','loot:2;xp:15','Die Spuren verlieren sich im Staub.','xp:3'),
 ('campfire',3,'Zelt durchsuchen',NULL,0,0,NULL,'Ein paar Kleinigkeiten.','lootcat:consumable:1',NULL,NULL);

INSERT INTO Events VALUES ('toxic_pool','Leuchtender Tuempel','Ein Tuempel, der von innen gruen gluht. Am Grund glitzert Metall.','poi','swamp,craters',0,NULL,10,'☢');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('toxic_pool',1,'Hineintauchen','survival',-5,1,NULL,'Luft anhalten, greifen, raus. Geschafft.','loot:2;xp:18','Das Wasser brennt auf der Haut wie Saeure.','damage:4-9;loot:1'),
 ('toxic_pool',2,'Mit einem Ast angeln','perception',0,1,NULL,'Mit Geduld fischst du etwas heraus.','loot:1;xp:10','Der Ast loest sich zischend auf.','xp:2'),
 ('toxic_pool',3,'Lieber nicht',NULL,0,0,NULL,'Kluge Entscheidung.','persist',NULL,NULL);

INSERT INTO Events VALUES ('tripwire','Stolperdraht','Fast haettest du ihn uebersehen: ein Draht, knoechelhoch, fuehrt zu einer Granate.','poi','ruins,scrapyard,wasteland,deadforest',1,NULL,8,'⚠');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('tripwire',1,'Falle entschaerfen','mechanics',0,1,NULL,'Draht geloest, Splint gesichert. Und dahinter: das Lager des Fallenstellers.','loot:2;xp:20','KLICK.','damage:4-9'),
 ('tripwire',2,'Darueber steigen','athletics',15,1,NULL,'Vorsichtig, ganz vorsichtig... geschafft.','xp:8','Dein Stiefel bleibt haengen.','damage:4-9'),
 ('tripwire',3,'Umkehren',NULL,0,0,NULL,'Nicht dein Problem.','persist',NULL,NULL);

INSERT INTO Events VALUES ('bunker_ruin','Eingestuerzter Bunker','Ein anderer Bunker. Die Decke ist eingebrochen, aber ein Lueftungsschacht fuehrt hinein.','poi','*',1,NULL,5,'⌂');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('bunker_ruin',1,'Durch den Schacht kriechen','athletics',-5,1,NULL,'Unten: ein Schlafsaal und ein Tagebuch.','loot:2;lore;xp:30','Der Schacht gibt nach. Du stuerzt in die Dunkelheit.','damage:4-10;loot:1'),
 ('bunker_ruin',2,'Notstrom aktivieren','mechanics',-10,1,NULL,'Lichter flackern auf. Ein Terminal erwacht.','lore;lore;reveal:5;xp:35','Nur ein muedes Brummen.','xp:4'),
 ('bunker_ruin',3,'Weitergehen',NULL,0,0,NULL,'Totenstille.','persist',NULL,NULL);

INSERT INTO Events VALUES ('scrapheap','Schrotthaufen','Ein Berg aus Metall, Kabeln und Plastik. Irgendwo darin ist sicher etwas Nuetzliches.','poi','scrapyard,ruins',0,NULL,12,'⚙');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('scrapheap',1,'Gezielt suchen','mechanics',10,1,NULL,'Du baust dir aus Teilen etwas Brauchbares zusammen.','lootcat:weapon:1;xp:15','Nur Schrott.','xp:3'),
 ('scrapheap',2,'Durchwuehlen','perception',5,1,NULL,'Zwischen dem Muell: Vorraete!','loot:1;xp:10','Etwas beisst dich aus dem Schrott heraus!','combat:rat');

INSERT INTO Events VALUES ('survivor','Ueberlebender','Ein abgemagerter Mann hockt an einer Mauer, die Haende erhoben. "Bitte... ich will nur Wasser."','poi','*',0,NULL,6,'☺');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('survivor',1,'Wasser geben',NULL,0,0,'water','Er trinkt gierig. Dann drueckt er dir etwas in die Hand und erzaehlt, was er gesehen hat.','take:water:1;loot:2;lore;xp:30',NULL,NULL),
 ('survivor',2,'Wunden versorgen','healing',0,0,NULL,'Du hilfst ihm so gut du kannst. Dankbar zeigt er dir sein Versteck.','loot:1;reveal:4;xp:25','Du tust, was du kannst. Es ist nicht genug.','xp:5'),
 ('survivor',3,'Ihm nicht trauen',NULL,0,0,NULL,'Du gehst weiter. Er ruft dir nichts nach.','',NULL,NULL);

INSERT INTO Events VALUES ('hunter_blind','Jaegerstand','Ein Hochsitz am Rand des toten Waldes. Er sieht stabil aus.','poi','deadforest,wasteland',0,NULL,8,'⌖');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('hunter_blind',1,'Hinaufklettern','athletics',10,1,NULL,'Oben findest du eine Kiste und eine gute Aussicht.','lootcat:ranged:1;lootcat:ammo:1;reveal:5;xp:15','Die Leiter bricht.','damage:2-6'),
 ('hunter_blind',2,'Spuren im Umkreis lesen','survival',0,1,NULL,'Hier wurde gejagt – und Vorraete versteckt.','lootcat:consumable:2;xp:12','Nur alte Faehrten.','xp:2');

INSERT INTO Events VALUES ('crashed_heli','Abgestuerzter Hubschrauber','Ein Militaerhubschrauber, die Rotoren verbogen. Das Cockpit ist intakt.','poi','*',3,NULL,4,'✈');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('crashed_heli',1,'Waffenkiste knacken','lockpick',-10,1,NULL,'Militaerausruestung!','lootcat:weapon:1;lootcat:armor:1;xp:40','Das Schloss ist zu gut.','xp:5'),
 ('crashed_heli',2,'Flugschreiber auslesen','hacking',-5,1,NULL,'Die letzten Minuten des Piloten. Und Koordinaten.','lore;reveal:8;xp:35','Daten korrupt.','xp:5'),
 ('crashed_heli',3,'Wrack durchsuchen','perception',0,1,NULL,'Notfallrationen und ein Erste-Hilfe-Kasten.','item:medkit:1;lootcat:consumable:1;xp:15','Nur Splitter und verkohlte Sitze. Und dann Schritte...','combat:*');

INSERT INTO Events VALUES ('graffiti','Botschaft an der Wand','Riesige Buchstaben, mit Farbe auf eine Hauswand gesprueht.','poi','ruins,scrapyard',0,NULL,7,'✎');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('graffiti',1,'Lesen',NULL,0,0,NULL,'Du liest die Worte.','lore;xp:5',NULL,NULL);

INSERT INTO Events VALUES ('glowing_tree','Leuchtender Baum','Ein toter Baum, an dessen Aesten seltsame Fruechte haengen, die schwach leuchten.','poi','deadforest,swamp',0,NULL,7,'❦');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('glowing_tree',1,'Essbare Fruechte bestimmen','survival',5,1,NULL,'Diese hier sind sicher. Mehr oder weniger.','item:mutfruit:3;xp:10','Die Frucht platzt und spritzt dir Saft in die Augen.','damage:1-4'),
 ('glowing_tree',2,'Hochklettern','athletics',0,1,NULL,'In einer Astgabel: ein altes Vogelnest voller glaenzender Dinge.','loot:1;xp:10','Der Ast bricht.','damage:2-5');

INSERT INTO Events VALUES ('raider_camp','Rumtreiber-Lager','Rauch, Gelaechter, Metallmusik. Ein befestigtes Lager aus Autoteilen. Wachen patrouillieren.','poi','*',3,NULL,5,'⚑');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('raider_camp',1,'Nachts ins Lager schleichen','stealth',-10,1,NULL,'Du greifst dir eine Kiste aus dem Vorratszelt und verschwindest.','loot:3;xp:45','"HEY! Da ist jemand!"','combat:raider;combat:raider'),
 ('raider_camp',2,'Angreifen',NULL,0,0,NULL,'Waffen hoch!','combat:raider;combat:raider;loot:3',NULL,NULL),
 ('raider_camp',3,'Weitergehen',NULL,0,0,NULL,'Heute nicht.','persist',NULL,NULL);

INSERT INTO Events VALUES ('vending','Verkaufsautomat','Ein Getraenkeautomat, die Scheibe zersplittert, aber das Ausgabefach ist verriegelt.','poi','ruins,scrapyard',0,NULL,8,'▤');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('vending',1,'Elektronik ueberlisten','hacking',15,1,NULL,'Bing! Bing! Bing!','item:water:2;item:cannedfood:1;xp:10','Der Automat piepst beleidigt.','xp:2'),
 ('vending',2,'Fach aufhebeln','athletics',5,1,NULL,'Mit einem Ruck.','item:water:1;xp:6','Der Automat kippt dir fast auf den Fuss.','damage:1-3');

-- ===== Ereignisse: Begegnungen (encounter) ==========================

INSERT INTO Events VALUES ('ambush','Hinterhalt!','Eine Bewegung aus dem Augenwinkel – du bist nicht allein.','encounter','*',0,NULL,20,'!');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('ambush',1,'Kaempfen',NULL,0,0,NULL,'Du stellst dich.','combat:*',NULL,NULL),
 ('ambush',2,'Davonschleichen','stealth',0,1,NULL,'Du duckst dich weg und verschwindest im Schatten.','xp:6','Zu spaet – es hat dich gesehen!','combat:*');

INSERT INTO Events VALUES ('ashstorm','Aschesturm','Der Himmel wird schwarz. Eine Wand aus Asche rollt auf dich zu.','encounter','ashdesert,craters,wasteland',0,NULL,8,'≋');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('ashstorm',1,'Unterschlupf suchen','survival',5,1,NULL,'Du findest eine Senke und wartest ab. Im Sand liegt etwas.','xp:10;loot:1','Die Asche schmirgelt dir die Haut ab.','damage:2-6'),
 ('ashstorm',2,'Weiterkaempfen','athletics',-5,1,NULL,'Mit gesenktem Kopf durch den Sturm.','xp:8','Du stolperst und verletzt dich.','damage:3-7');

INSERT INTO Events VALUES ('stray_note','Flatternder Zettel','Ein Blatt Papier, vom Wind herangetragen, verfaengt sich an deinem Bein.','encounter','*',0,NULL,6,'✉');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('stray_note',1,'Lesen',NULL,0,0,NULL,'Handschrift, hastig, verwischt.','lore;xp:4',NULL,NULL);

INSERT INTO Events VALUES ('acid_rain','Saurer Regen','Die ersten Tropfen zischen auf dem Boden.','encounter','swamp,deadforest,ruins,scrapyard',0,NULL,6,'☂');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('acid_rain',1,'Schnell Deckung suchen','perception',10,1,NULL,'Ein Ueberhang schuetzt dich.','xp:6','Zu langsam.','damage:2-5');

INSERT INTO Events VALUES ('stash','Verstecktes Depot','Ein loser Stein, darunter ein Hohlraum. Jemand hat hier etwas versteckt.','encounter','*',0,NULL,5,'◆');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('stash',1,'Nehmen',NULL,0,0,NULL,'Danke, Unbekannter.','loot:1;xp:5',NULL,NULL);

-- ---------------------------------------------------------------------
-- Haendler (Tauschhandel, keine Waehrung)
-- Ein Tausch gelingt, wenn der Wert deines Angebots >= dem Wert deiner
-- Forderung ist. Werte = Items.Value, skaliert mit der Gegenstandsstufe.
-- PayFactor:   so viel ist ihm deine Ware wert (0.7 = 70 %)
-- PriceFactor: so viel verlangt er fuer seine Ware (1.2 = 120 %)
-- Categories:  '*' oder kommagetrennte Kategorien/Slots fuers Sortiment
-- Ausgeloest werden Haendler ueber den Effekt trade:key in EventOptions.
-- ---------------------------------------------------------------------
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

INSERT INTO Traders VALUES
 ('wanderer', 'Reisende Haendlerin', '"Alles hat seinen Preis, Fremder. Zeig mir, was du hast."', '*', 5, 8, 0.7, 1.2, 10, '#c0a070'),
 ('medic',    'Wanderarzt',          '"Verbaende, Pillen, Spritzen. Ich nehme alles, was schiesst."', 'consumable,ammo', 4, 6, 0.8, 1.3, 5, '#e04040'),
 ('scrapper', 'Schrotthaendler',     '"Metall gegen Metall. Und ich sag dir, was es wert ist."', 'weapon,armor', 4, 6, 0.75, 1.25, 6, '#9a5b34');

INSERT INTO Events VALUES ('wandering_trader','Reisende Haendlerin','Ein Handkarren mit Planen, gezogen von einer Frau mit Gasmaske. Sie hebt die Hand – friedlich.','encounter','*',0,NULL,6,'⚖');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('wandering_trader',1,'Tauschen',NULL,0,0,NULL,'Sie schlaegt die Plane zurueck.','trade:wanderer',NULL,NULL),
 ('wandering_trader',2,'Nach Neuigkeiten fragen','perception',10,0,NULL,'Sie erzaehlt dir von ihrer Route und zeigt dir ihre Karte.','reveal:7;lore;xp:10','Sie zuckt nur mit den Schultern.','xp:2'),
 ('wandering_trader',3,'Weitergehen',NULL,0,0,NULL,'Sie nickt dir zu und zieht weiter.','',NULL,NULL);

INSERT INTO Events VALUES ('trader_post','Handelsposten','Ein umgebauter Container mit Gittertuer. Auf einem Schild steht: TAUSCH. KEIN AERGER.','poi','ruins,scrapyard,wasteland,ashdesert',1,NULL,4,'⚖');
INSERT INTO EventOptions (EventKey,SortOrder,Label,SkillKey,Difficulty,DangerScaling,RequiresItem,SuccessText,SuccessEffects,FailText,FailEffects) VALUES
 ('trader_post',1,'Mit dem Schrotthaendler tauschen',NULL,0,0,NULL,'Er mustert dich und deine Ausruestung.','trade:scrapper;persist',NULL,NULL),
 ('trader_post',2,'Mit dem Wanderarzt tauschen',NULL,0,0,NULL,'Der Arzt rueckt seine Brille zurecht.','trade:medic;persist',NULL,NULL),
 ('trader_post',3,'Weitergehen',NULL,0,0,NULL,'Der Posten bleibt, wo er ist.','persist',NULL,NULL);

-- ---------------------------------------------------------------------
-- Infofragmente (Lore). Werden in Reihenfolge der Freischaltbarkeit
-- (MinDanger) zufaellig gefunden.
-- ---------------------------------------------------------------------
CREATE TABLE Lore (
    Id        INTEGER PRIMARY KEY AUTOINCREMENT,
    Title     TEXT NOT NULL,
    Text      TEXT NOT NULL,
    MinDanger INTEGER NOT NULL DEFAULT 0
);

INSERT INTO Lore (Title,Text,MinDanger) VALUES
 ('Notiz, zerknittert','"Tag 3. Die Sirenen haben aufgehoert. Nicht weil es vorbei ist, sondern weil niemand mehr da ist, der sie bedient."',0),
 ('Einkaufsliste','Milch. Brot. Jodtabletten (!!!). Batterien. Mama anrufen.',0),
 ('Kinderzeichnung','Ein Haus, eine Sonne, vier Strichmaennchen. Die Sonne wurde spaeter mit rotem Stift uebermalt.',0),
 ('Radioprotokoll 07','"...wiederhole: Alle Buerger der Zone 4 begeben sich unverzueglich in die zugewiesenen Schutzanlagen. Dies ist keine Uebung..."',0),
 ('Bunker-Handbuch, S. 12','"Die Kryostase ist auf eine Dauer von maximal 18 Monaten ausgelegt. Bei Ueberschreitung koennen Gedaechtnisstoerungen auftreten."',0),
 ('Tagebuch eines Soldaten','"Sie sagen, es war ein Unfall. Ein Fehler im Fruehwarnsystem. Aber ich habe die Befehle gesehen. Die Befehle waren eindeutig."',1),
 ('Graffito','DIE ASCHE ERINNERT SICH AN ALLES.',1),
 ('Laborbericht (Fragment)','"Projekt LAZARUS: Proband 14 zeigt nach 9 Jahren Kryostase keine kognitiven Ausfaelle. Empfehlung: Fortsetzung bis zur Bewohnbarkeit."',1),
 ('Brief, nie abgeschickt','"Liebe Ann, wenn du das liest, bin ich nicht in den Bunker gekommen. Es waren zu wenig Plaetze. Ich habe meinen dem Jungen von nebenan gegeben."',1),
 ('Wartungslog','"Generator 2 ausgefallen. Kapseln 1-11 auf Notstrom umgestellt. Kapsel 12 reagiert nicht. Kapsel 12 ist..." – der Rest ist unleserlich.',2),
 ('Zettel an einer Tuer','"KEIN WASSER. KEINE MEDIZIN. NICHTS ZU HOLEN. GEHT WEITER."',2),
 ('Funkspruch, Aufzeichnung','"Hier spricht Haven. Wir sind 40 Menschen. Wir haben Wasser. Folgt dem Fluss nach Norden..." Die Aufzeichnung ist Jahrzehnte alt.',2),
 ('Militaerbefehl','"Einsatzgruppe Sigma sichert die Kryoanlagen. Ueberlebende Zivilisten sind nicht einzulassen. Prioritaet: Projekt LAZARUS."',3),
 ('Tagebuch, letzte Seite','"Die Ghule waren einmal Menschen. Ich habe meinen Nachbarn erkannt. Er hat mich auch erkannt. Er hat trotzdem angegriffen."',3),
 ('Wissenschaftliche Notiz','"Die Mutationen folgen einem Muster. Das ist keine Strahlung allein. Jemand hat nachgeholfen."',4),
 ('Logbuch Kapsel-Bunker 7','"Du bist nicht der erste, der aufwacht. Und nicht der letzte. Die Anlage weckt uns einzeln, wenn die Werte stimmen. Sie stimmen nie."',4),
 ('Zerrissenes Foto','Eine Gruppe Menschen in weissen Kitteln vor einem Bunkereingang. Einer von ihnen sieht dir verblueffend aehnlich.',5),
 ('Terminal-Ausdruck','"LAZARUS PROBAND 23 – STATUS: ERWACHT. AUFTRAG: KARTOGRAFIERUNG. ERWARTETE UEBERLEBENSDAUER: 14 TAGE."',6),
 ('Stimme auf Band','"Wenn du das hoerst, bist du weiter gekommen als alle anderen. Geh weiter. Irgendwo am Ende ist etwas. Muss es sein."',7),
 ('Inschrift im Fels','ES GIBT KEIN ENDE. NUR DEN NAECHSTEN SCHRITT.',9);
