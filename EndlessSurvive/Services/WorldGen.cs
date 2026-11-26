using EndlessSurvive.Models;

namespace EndlessSurvive.Services;

public sealed record TileInfo(int X, int Y, BiomeDef Biome, int Danger, EventDef? Poi);

/// <summary>
/// Unendliche, deterministische Welt: Alles wird aus Seed und Koordinaten berechnet.
/// Gespeichert wird nur, was der Spieler veraendert hat.
/// </summary>
public sealed class WorldGen
{
    private const int SaltHeight = 11, SaltMoist = 23, SaltPoi = 37, SaltPoiPick = 41;
    private readonly ContentStore _c;
    private readonly long _seed;
    private readonly Dictionary<(int, int), TileInfo> _cache = new();
    private int _contentVersion;

    public WorldGen(ContentStore content, long seed)
    {
        _c = content;
        _seed = seed;
    }

    public TileInfo Tile(int x, int y)
    {
        if (_contentVersion != _c.Version) { _cache.Clear(); _contentVersion = _c.Version; } // Inhalte wurden neu geladen
        if (_cache.TryGetValue((x, y), out var t)) return t;
        t = Build(x, y);
        if (_cache.Count > 20000) _cache.Clear();
        _cache[(x, y)] = t;
        return t;
    }

    public double Distance(int x, int y) => Math.Sqrt((double)x * x + (double)y * y);

    private TileInfo Build(int x, int y)
    {
        BiomeDef biome;
        if (x == 0 && y == 0)
        {
            biome = _c.Biome(_c.Str("StartBiome", "bunker"));
        }
        else
        {
            double h = Fractal(x / 11.0, y / 11.0, SaltHeight);
            double m = Fractal(x / 15.0 + 100, y / 15.0 - 50, SaltMoist);
            biome = PickBiome(h, m);
            if (!biome.Passable && Distance(x, y) <= _c.Int("SafeRadius", 2))
                biome = PickBiome(0.5, m, passableOnly: true);
        }

        int danger = (int)Math.Floor(Distance(x, y) / Math.Max(1, _c.Num("DangerDistance", 7))) + biome.DangerBonus;
        if (x == 0 && y == 0) danger = 0;

        EventDef? poi = null;
        if (biome.Passable && (x != 0 || y != 0) && WorldHash.Unit(_seed, x, y, SaltPoi) < biome.EventChance)
        {
            var candidates = _c.Events.Values
                .Where(e => e.Kind == "poi" && e.Biomes.AllowsBiome(biome.Key)
                            && e.MinDanger <= danger && (e.MaxDanger is null || e.MaxDanger >= danger))
                .OrderBy(e => e.Key, StringComparer.Ordinal)
                .ToList();
            int total = candidates.Sum(e => e.Weight);
            if (total > 0)
            {
                double r = WorldHash.Unit(_seed, x, y, SaltPoiPick) * total;
                foreach (var e in candidates)
                {
                    r -= e.Weight;
                    if (r < 0) { poi = e; break; }
                }
            }
        }

        return new TileInfo(x, y, biome, danger, poi);
    }

    private BiomeDef PickBiome(double h, double m, bool passableOnly = false)
    {
        foreach (var b in _c.Biomes) // bereits nach Priority absteigend sortiert
            if (b.Matches(h, m) && (!passableOnly || b.Passable)) return b;
        return _c.Biomes.Where(b => b.Generated && b.Passable).OrderBy(b => b.Priority).First();
    }

    // ----- Value-Noise mit Oktaven -----
    private double Fractal(double x, double y, int salt)
    {
        double sum = 0, amp = 1, norm = 0, freq = 1;
        for (int o = 0; o < 4; o++)
        {
            sum += amp * ValueNoise(x * freq, y * freq, salt + o * 101);
            norm += amp;
            amp *= 0.5;
            freq *= 2.03;
        }
        double v = sum / norm;
        // Kontrast strecken, damit Extremwerte (Seen, Gebirge) vorkommen
        v = (v - 0.5) * 2.1 + 0.5;
        return Math.Clamp(v, 0, 1);
    }

    private double ValueNoise(double x, double y, int salt)
    {
        int x0 = (int)Math.Floor(x), y0 = (int)Math.Floor(y);
        double fx = x - x0, fy = y - y0;
        double sx = fx * fx * (3 - 2 * fx), sy = fy * fy * (3 - 2 * fy);
        double a = WorldHash.Unit(_seed, x0, y0, salt);
        double b = WorldHash.Unit(_seed, x0 + 1, y0, salt);
        double c = WorldHash.Unit(_seed, x0, y0 + 1, salt);
        double d = WorldHash.Unit(_seed, x0 + 1, y0 + 1, salt);
        double top = a + (b - a) * sx, bottom = c + (d - c) * sx;
        return top + (bottom - top) * sy;
    }
}
