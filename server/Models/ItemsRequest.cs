using System.Collections.Generic;

namespace WebApplication1.Models
{
 public class ItemsRequest
    {
        public List<Item> Items { get; set; } = new List<Item>();
        public List<Trajectories> Trajectories { get; set; } = new List<Trajectories>();
    }
}
