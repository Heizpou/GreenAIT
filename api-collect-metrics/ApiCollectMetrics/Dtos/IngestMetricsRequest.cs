namespace ApiCollectMetrics.Dtos;

public record IngestMetricsRequest(
    Guid ServerId,
    bool PoweredOn,
    bool EcoMode,
    double CpuPercent,
    double RamPercent,
    double DiskPercent,
    double NetInMbps,
    double NetOutMbps,
    double CpuTempC,
    double PowerW,
    double SimulatedHour,
    double IncomingLoad,
    double? Timestamp  // Unix timestamp (secondes) issu de time.time() Python
);
