using ApiRecommendations.Dtos;
using GreenAIT.Data;
using GreenAIT.Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiRecommendations.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClustersController : ControllerBase
{
    private readonly GreenAITDbContext _db;

    public ClustersController(GreenAITDbContext db) => _db = db;

    /// <summary>
    /// Liste tous les clusters avec leurs serveurs.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var clusters = await _db.Clusters
            .Include(c => c.Servers)
            .ToListAsync();

        return Ok(clusters);
    }

    /// <summary>
    /// Retourne un cluster par son id.
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var cluster = await _db.Clusters
            .Include(c => c.Servers)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (cluster is null) return NotFound();
        return Ok(cluster);
    }

    /// <summary>
    /// Crée un nouveau cluster. Retourne l'objet avec son UUID généré.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateClusterRequest req)
    {
        var cluster = new Cluster
        {
            Name = req.Name,
            Description = req.Description,
            CreatedAt = DateTime.UtcNow,
        };

        _db.Clusters.Add(cluster);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = cluster.Id }, cluster);
    }

    /// <summary>
    /// Supprime un cluster et tous ses serveurs (cascade).
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var cluster = await _db.Clusters.FindAsync(id);
        if (cluster is null) return NotFound();

        _db.Clusters.Remove(cluster);
        await _db.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>
    /// Ajoute un serveur dans un cluster. Retourne l'UUID à configurer comme SERVER_ID.
    /// </summary>
    [HttpPost("{id}/servers")]
    public async Task<IActionResult> AddServer(Guid id, [FromBody] CreateServerRequest req)
    {
        var clusterExists = await _db.Clusters.AnyAsync(c => c.Id == id);
        if (!clusterExists) return NotFound(new { error = "Cluster not found." });

        var server = new Server
        {
            ClusterId = id,
            Name = req.Name,
            Description = req.Description,
            CreatedAt = DateTime.UtcNow,
        };

        _db.Servers.Add(server);
        await _db.SaveChangesAsync();

        return Ok(server);
    }

    /// <summary>
    /// Supprime un serveur d'un cluster (et toutes ses métriques en cascade).
    /// </summary>
    [HttpDelete("{clusterId}/servers/{serverId}")]
    public async Task<IActionResult> RemoveServer(Guid clusterId, Guid serverId)
    {
        var server = await _db.Servers
            .FirstOrDefaultAsync(s => s.Id == serverId && s.ClusterId == clusterId);

        if (server is null) return NotFound();

        _db.Servers.Remove(server);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}
