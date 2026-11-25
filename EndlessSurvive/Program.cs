using EndlessSurvive.Components;
using EndlessSurvive.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddSingleton<ContentStore>();
builder.Services.AddSingleton<SaveStore>();
builder.Services.AddScoped<GameService>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
}

// Inhalte beim Start laden (Fehler in der DB fallen so sofort auf)
app.Services.GetRequiredService<ContentStore>();
app.Services.GetRequiredService<SaveStore>();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
