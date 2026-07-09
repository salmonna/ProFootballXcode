using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using System.Text.Json.Serialization;
using AiServer.Services;
using server.Services.Rag;
using server.Services.Vector;



var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // שומר על אותיות גדולות כפי שמוגדר ב-Models
        options.JsonSerializerOptions.NumberHandling = JsonNumberHandling.AllowReadingFromString;
        // מונע בעיות של Reference Cycles במידה ותוסיף קשרים בין אובייקטים בעתיד
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// --- 2. הגדרות CORS ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(origin => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .WithExposedHeaders("Content-Disposition"); // מאפשר לאפליקציה לקרוא שמות קבצים בהורדה
    });
});

// --- 3. אתחול Firebase ---
if (FirebaseApp.DefaultInstance == null)
{
    try
    {
        // בדיקה אם קיים נתיב במשתנה סביבה, אחרת שימוש בברירת מחדל
        string authPath = Path.Combine(Directory.GetCurrentDirectory(), "firebase-key.json");

        Console.WriteLine($"[Firebase Setup] Attempting to load credentials from: {authPath}");

        if (!File.Exists(authPath))
        {
            throw new FileNotFoundException($"Firebase key file not found at: {authPath}");
        }

        FirebaseApp.Create(new AppOptions
        {
            Credential = GoogleCredential.FromFile(authPath)
        });

        Console.WriteLine("[Firebase Setup] Firebase initialized successfully.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[Firebase Error] Failed to initialize Firebase: {ex.Message}");
        // אפשר לבחור אם להמשיך או להפסיק את האפליקציה
        throw; 
    }
}

// Services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IRagService, RagService>();
builder.Services.AddScoped<PromptBuilderService>();
builder.Services.AddScoped<RetrievalService>();
builder.Services.AddHttpClient<GeminiService>();

builder.Services.AddSingleton<VectorDbService>();
builder.Services.AddHttpClient<EmbeddingService>();
builder.Services.AddSingleton<KnowledgeIndexer>();


var app = builder.Build();

app.Use(async (context, next) =>
{
    Console.WriteLine($"[REQUEST] {context.Request.Method} {context.Request.Path}");
    await next();
});

using var scope = app.Services.CreateScope();

var vectorDb =
    scope.ServiceProvider.GetRequiredService<VectorDbService>();

vectorDb.Load();

if (!File.Exists("Data/vectordb/vectors.json"))
{
    var indexer =
        scope.ServiceProvider.GetRequiredService<KnowledgeIndexer>();

    await indexer.IndexFolder(
        "Data/knowledge_base/examples_kb",
        "example");

    vectorDb.Save();
}

app.Urls.Add("http://0.0.0.0:8080");

// --- 5. Request Pipeline (סדר הפעולות קריטי) ---

//if (app.Environment.IsDevelopment())
//{
//    app.UseSwagger();
//    app.UseSwaggerUI();
//}

app.UseSwagger();
app.UseSwaggerUI();

//// ב-Development מומלץ לכבות HttpsRedirection כדי למנוע בעיות עם תעודות SSL לא חתומות ב-Mobile
//if (!app.Environment.IsDevelopment())
//{
//    app.UseHttpsRedirection();
//}

app.UseRouting();

// CORS חייב להיות לפני ה-Middleware של ה-Auth
app.UseCors("AllowAll");

// Middleware של Firebase (מחלץ את ה-UID ומאמת את ה-Token)
app.UseMiddleware<FirebaseAuthMiddleware>();

app.MapControllers();

app.UseAuthorization();

app.MapControllers();

app.Run();

