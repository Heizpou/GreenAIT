namespace GreenAIT.Data.Entities;

public class ServerMetrics
{
    public long Id { get; set; }
    public Guid ServerId { get; set; }
    public DateTime RecordedAt { get; set; }

    // Contexte de simulation
    public double SimulatedHour { get; set; }
    public double IncomingLoad { get; set; }

    // État du serveur
    public bool PoweredOn { get; set; }
    public bool EcoMode { get; set; }

    // Métriques
    public double CpuPercent { get; set; }
    public double RamPercent { get; set; }
    public double DiskPercent { get; set; }
    public double NetInMbps { get; set; }
    public double NetOutMbps { get; set; }
    public double CpuTempC { get; set; }
    public double PowerW { get; set; }

    public Server Server { get; set; } = null!;
}
