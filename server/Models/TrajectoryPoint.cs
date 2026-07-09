namespace WebApplication1.Models
{
    public class Points
    {
        public float X { get; set; }
        public float Y { get; set; }
    }
    public class Trajectories
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;

        public List<Points> Points { get; set; } = new List<Points>();

    }
}
