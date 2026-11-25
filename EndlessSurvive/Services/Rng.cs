namespace EndlessSurvive.Services;

/// <summary>Deterministisches Hashing fuer die prozedurale Welt.</summary>
public static class WorldHash
{
    public static ulong Mix(ulong z)
    {
        z += 0x9E3779B97F4A7C15UL;
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9UL;
        z = (z ^ (z >> 27)) * 0x94D049BB133111EBUL;
        return z ^ (z >> 31);
    }

    public static ulong Hash(long seed, int x, int y, int salt)
    {
        ulong h = Mix((ulong)seed);
        h = Mix(h ^ (ulong)(uint)x);
        h = Mix(h ^ ((ulong)(uint)y << 1));
        h = Mix(h ^ (ulong)(uint)salt * 0x632BE59BD9B4E019UL);
        return h;
    }

    /// <summary>Wert in [0,1).</summary>
    public static double Unit(long seed, int x, int y, int salt) =>
        (Hash(seed, x, y, salt) >> 11) * (1.0 / (1UL << 53));
}

/// <summary>Wuerfel fuer Proben und Zufall im Spiel.</summary>
public sealed class Dice
{
    private readonly Random _r = new();

    public int D100() => _r.Next(1, 101);
    public int Range(int min, int max) => max <= min ? min : _r.Next(min, max + 1);
    public double Unit() => _r.NextDouble();
    public bool Chance(double p) => _r.NextDouble() < p;

    public T? Weighted<T>(IReadOnlyList<T> items, Func<T, int> weight) where T : class
    {
        int total = items.Sum(i => Math.Max(0, weight(i)));
        if (total <= 0) return null;
        int roll = _r.Next(total);
        foreach (var i in items)
        {
            roll -= Math.Max(0, weight(i));
            if (roll < 0) return i;
        }
        return items[^1];
    }
}
