using System.Text.Json;

namespace server.Services.Vector;

public class VectorDbService
{
    private readonly List<VectorDocument> _documents = [];

    private readonly string _dbPath =
        "Data/vectordb/vectors.json";

    public void Add(VectorDocument doc)
    {
        _documents.Add(doc);
    }

    public List<VectorDocument> Search(float[] query, int topK = 4)
    {
        return _documents
            .Select(d => new
            {
                Doc = d,
                Score = Cosine(query, d.Embedding)
            })
            .OrderByDescending(x => x.Score)
            .Take(topK)
            .Select(x => x.Doc)
            .ToList();
    }

    private float Cosine(float[] v1, float[] v2)
    {
        float dot = 0, m1 = 0, m2 = 0;

        for (int i = 0; i < v1.Length; i++)
        {
            dot += v1[i] * v2[i];
            m1 += v1[i] * v1[i];
            m2 += v2[i] * v2[i];
        }

        return dot / (MathF.Sqrt(m1) * MathF.Sqrt(m2));
    }

    public void Save()
    {
        var json = JsonSerializer.Serialize(_documents);
        File.WriteAllText(_dbPath, json);
    }

    public void Load()
    {
        if (!File.Exists(_dbPath))
            return;

        var json = File.ReadAllText(_dbPath);

        var docs =
            JsonSerializer.Deserialize<List<VectorDocument>>(json)!;

        _documents.AddRange(docs);
    }
}