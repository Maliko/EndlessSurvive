using EndlessSurvive.Services;
using Microsoft.AspNetCore.Components;

namespace EndlessSurvive.Components.Game;

/// <summary>Basis fuer alle Spielkomponenten: rendert neu, sobald sich der Spielzustand aendert.</summary>
public abstract class GameComponent : ComponentBase, IDisposable
{
    [Inject] protected GameService Game { get; set; } = default!;

    protected override void OnInitialized() => Game.Changed += OnGameChanged;

    private void OnGameChanged() => InvokeAsync(StateHasChanged);

    public void Dispose()
    {
        Game.Changed -= OnGameChanged;
        GC.SuppressFinalize(this);
    }
}
