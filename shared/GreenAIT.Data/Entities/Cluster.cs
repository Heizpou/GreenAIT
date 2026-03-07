namespace GreenAIT.Data.Entities;

public class Cluster
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }

    public ICollection<Server> Servers { get; set; } = [];
}
