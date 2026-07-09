using server.Services.Vector;

namespace server.Services.Rag;

public class KnowledgeIndexer
{
    private readonly EmbeddingService _embedding;
    private readonly VectorDbService _vectorDb;

    public KnowledgeIndexer(
        EmbeddingService embedding,
        VectorDbService vectorDb)
    {
        _embedding = embedding;
        _vectorDb = vectorDb;
    }

    public async Task IndexFolder(string path, string source)
    {
        var files = Directory.GetFiles(
            path,
            "*.md",
            SearchOption.AllDirectories);

        foreach (var file in files)
        {
            var text = await File.ReadAllTextAsync(file);

            var vector =
                await _embedding.CreateEmbeddingAsync(text);

            _vectorDb.Add(new VectorDocument
            {
                Id = Guid.NewGuid().ToString(),
                Text = text,
                Embedding = vector,
                Source = source
            });
        }
    }
}