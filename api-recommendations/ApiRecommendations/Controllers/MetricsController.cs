using GreenAIT.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiRecommendations.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MetricsController : ControllerBase
{
    private readonly GreenAITDbContext _db;

    public MetricsController(GreenAITDbContext db) => _db = db;

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
