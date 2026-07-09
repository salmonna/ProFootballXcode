namespace WebApplication1.Models
{
    public class Item
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // 'player' or 'cone'
        public float X { get; set; }
        public float Y { get; set; }
    }
}
