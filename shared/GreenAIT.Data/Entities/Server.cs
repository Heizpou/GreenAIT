namespace GreenAIT.Data.Entities;

public class Server
{
    public Guid Id { get; set; }
    public Guid ClusterId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastSeenAt { get; set; }

    public Cluster Cluster { get; set; } = null!;
    public ICollection<ServerMetrics> Metrics { get; set; } = [];
}
