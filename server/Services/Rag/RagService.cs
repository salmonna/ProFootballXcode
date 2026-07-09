using System.Text.Json;
using AiServer.Services;

namespace server.Services.Rag;

public class RagService : IRagService
{
    private readonly RetrievalService _retrieval;
    private readonly PromptBuilderService _promptBuilder;
    private readonly GeminiService _gemini;

    public RagService(
        RetrievalService retrieval,
        PromptBuilderService promptBuilder,
        GeminiService gemini)
    {
        _retrieval = retrieval;
        _promptBuilder = promptBuilder;
        _gemini = gemini;
    }

    public async Task<string> GenerateTrainingAsync(string userRequest)
    {
        // 1️⃣ שליפת ידע מה-KB
        var examples = await _retrieval.GetExamplesAsync(userRequest);

        // 2 בניית Prompt
        var prompt = _promptBuilder.BuildPrompt(
            userRequest,
            examples
        );

        // 3 קריאה ל-LLM
        var raw = await _gemini.GenerateAsync(prompt);

        var jsonOnly = ExtractJson(raw);

        using var jsonDoc = JsonDocument.Parse(jsonOnly);

        return jsonDoc.RootElement.GetRawText();

    }

    private string ExtractJson(string text)
    {
        var start = text.IndexOf('{');
        var end = text.LastIndexOf('}');

        if (start >= 0 && end > start)
            return text.Substring(start, end - start + 1);

        throw new Exception("No JSON found");
    }
}