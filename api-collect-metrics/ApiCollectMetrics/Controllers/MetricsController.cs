using ApiCollectMetrics.Dtos;
using GreenAIT.Data;
using GreenAIT.Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiCollectMetrics.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MetricsController : ControllerBase
{
    private readonly GreenAITDbContext _db;

    public MetricsController(GreenAITDbContext db) => _db = db;

    /// <summary>
    /// Reçoit les métriques d'un runner (server-simulator ou serveur réel).
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Ingest([FromBody] IngestMetricsRequest req)
    {
        var server = await _db.Servers.FindAsync(req.ServerId);
        if (server is null)
            return NotFound(new { error = $"Server {req.ServerId} not registered." });

        server.LastSeenAt = DateTime.UtcNow;

        var recordedAt = req.Timestamp.HasValue
            ? DateTimeOffset.FromUnixTimeSeconds((long)req.Timestamp.Value).UtcDateTime
            : DateTime.UtcNow;

        _db.ServerMetrics.Add(new ServerMetrics
        {
            ServerId = req.ServerId,
            RecordedAt = recordedAt,
            SimulatedHour = req.SimulatedHour,
            IncomingLoad = req.IncomingLoad,
            PoweredOn = req.PoweredOn,
            EcoMode = req.EcoMode,
            CpuPercent = req.CpuPercent,
            RamPercent = req.RamPercent,
            DiskPercent = req.DiskPercent,
            NetInMbps = req.NetInMbps,
            NetOutMbps = req.NetOutMbps,
            CpuTempC = req.CpuTempC,
            PowerW = req.PowerW,
        });

        await _db.SaveChangesAsync();
        return Ok();
    }

    /// <summary>
    /// Retourne les dernières métriques d'un serveur.
    /// </summary>
    [HttpGet("{serverId}")]
    public async Task<IActionResult> GetByServer(Guid serverId, [FromQuery] int limit = 100)
    {
        var exists = await _db.Servers.AnyAsync(s => s.Id == serverId);
        if (!exists) return NotFound();

        var metrics = await _db.ServerMetrics
            .Where(m => m.ServerId == serverId)
            .OrderByDescending(m => m.RecordedAt)
            .Take(limit)
            .ToListAsync();

        return Ok(metrics);
    }

    /// <summary>
    /// Retourne les métriques d'un serveur dans une plage de temps.
    /// </summary>
    [HttpGet("{serverId}/range")]
    public async Task<IActionResult> GetByServerAndRange(
        Guid serverId,
        [FromQuery] DateTime from,
        [FromQuery] DateTime to)
    {
        var exists = await _db.Servers.AnyAsync(s => s.Id == serverId);
        if (!exists) return NotFound();

        var metrics = await _db.ServerMetrics
            .Where(m => m.ServerId == serverId && m.RecordedAt >= from && m.RecordedAt <= to)
            .OrderBy(m => m.RecordedAt)
            .ToListAsync();

        return Ok(metrics);
    }
}
