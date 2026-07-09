using System.Text;
using System.Text.Json;

namespace server.Services.Vector;

public class EmbeddingService
{
    private readonly HttpClient _http;
    private readonly string _apiKey;

    public EmbeddingService(IConfiguration config, HttpClient http)
    {
        _http = http;
        _apiKey = config["Gemini:ApiKey"] ?? throw new Exception("Gemini API key is missing");
    }

    public async Task<float[]> CreateEmbeddingAsync(string text)
    {
        var body = new
        {
            model = "gemini-embedding-2",
            content = new
            {
                parts = new[]
                {
                    new { text }
                }
            }
        };

        var json = JsonSerializer.Serialize(body);

        var response = await _http.PostAsync(
            $"https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent?key={_apiKey}",
            new StringContent(json, Encoding.UTF8, "application/json")
        );

        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadAsStringAsync();

        using var doc = JsonDocument.Parse(result);

        return doc.RootElement
            .GetProperty("embedding")
            .GetProperty("values")
            .EnumerateArray()
            .Select(x => x.GetSingle())
            .ToArray();
    }
}