using server.Services.Vector;

namespace server.Services.Rag;

public class RetrievalService
{
    private readonly EmbeddingService _embedding;
    private readonly VectorDbService _vectorDb;

    public RetrievalService(
        EmbeddingService embedding,
        VectorDbService vectorDb)
    {
        _embedding = embedding;
        _vectorDb = vectorDb;
    }

    public async Task<List<string>> GetExamplesAsync(string query)
    {
        var vector =
            await _embedding.CreateEmbeddingAsync(query);

        return _vectorDb
            .Search(vector)
            .Select(x => x.Text)
            .ToList();
    }
}