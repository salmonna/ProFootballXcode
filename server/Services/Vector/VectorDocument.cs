namespace server.Services.Vector
{
    public class VectorDocument
    {
        public string Id { get; set; } = "";
        public string Text { get; set; } = "";
        public float[] Embedding { get; set; } = [];
        public string Source { get; set; } = "";
    }
}
