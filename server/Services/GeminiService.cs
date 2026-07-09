using System.Text;
using System.Text.Json;

namespace AiServer.Services;

public class GeminiService
{
    private readonly HttpClient _http;
    private readonly string _apiKey;

    public GeminiService(IConfiguration config, HttpClient http)
    {
        _http = http;
        _apiKey = config["Gemini:ApiKey"] ?? throw new Exception("Gemini API key is missing");

    }

    public async Task<string> GenerateAsync(string prompt)
    {
        var body = new
        {
            contents = new[]
            {
                new
                {
                    role = "user",
                    parts = new[]
                    {
                        new { text = prompt }
                    }
                }
            }
        };

        var json = JsonSerializer.Serialize(body);

        var response = await _http.PostAsync(
    $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={_apiKey}",
    new StringContent(json, Encoding.UTF8, "application/json")
);

        response.EnsureSuccessStatusCode();

        var resultJson = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Gemini Error:\n{resultJson}");
        }

        using var doc = JsonDocument.Parse(resultJson);

        return doc.RootElement
            .GetProperty("candidates")[0]
            .GetProperty("content")
            .GetProperty("parts")[0]
            .GetProperty("text")
            .GetString()!;
    }

}