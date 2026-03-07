using GreenAIT.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace GreenAIT.Data;

public class GreenAITDbContext : DbContext
{
    public GreenAITDbContext(DbContextOptions<GreenAITDbContext> options) : base(options) { }

    public DbSet<Cluster> Clusters => Set<Cluster>();
    public DbSet<Server> Servers => Set<Server>();
    public DbSet<ServerMetrics> ServerMetrics => Set<ServerMetrics>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cluster>(e =>
        {
            e.ToTable("clusters");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(128).IsRequired();
            e.Property(x => x.Description).HasColumnName("description");
            e.Property(x => x.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("NOW()");
        });

        modelBuilder.Entity<Server>(e =>
        {
            e.ToTable("servers");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id").HasDefaultValueSql("gen_random_uuid()");
            e.Property(x => x.ClusterId).HasColumnName("cluster_id");
            e.Property(x => x.Name).HasColumnName("name").HasMaxLength(128).IsRequired();
            e.Property(x => x.Description).HasColumnName("description");
            e.Property(x => x.CreatedAt).HasColumnName("created_at").HasDefaultValueSql("NOW()");
            e.Property(x => x.LastSeenAt).HasColumnName("last_seen_at");

            e.HasOne(x => x.Cluster)
             .WithMany(x => x.Servers)
             .HasForeignKey(x => x.ClusterId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ServerMetrics>(e =>
        {
            e.ToTable("server_metrics");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id").UseIdentityByDefaultColumn();
            e.Property(x => x.ServerId).HasColumnName("server_id");
            e.Property(x => x.RecordedAt).HasColumnName("recorded_at").HasDefaultValueSql("NOW()");
            e.Property(x => x.SimulatedHour).HasColumnName("simulated_hour");
            e.Property(x => x.IncomingLoad).HasColumnName("incoming_load");
            e.Property(x => x.PoweredOn).HasColumnName("powered_on");
            e.Property(x => x.EcoMode).HasColumnName("eco_mode");
            e.Property(x => x.CpuPercent).HasColumnName("cpu_percent");
            e.Property(x => x.RamPercent).HasColumnName("ram_percent");
            e.Property(x => x.DiskPercent).HasColumnName("disk_percent");
            e.Property(x => x.NetInMbps).HasColumnName("net_in_mbps");
            e.Property(x => x.NetOutMbps).HasColumnName("net_out_mbps");
            e.Property(x => x.CpuTempC).HasColumnName("cpu_temp_c");
            e.Property(x => x.PowerW).HasColumnName("power_w");

            e.HasOne(x => x.Server)
             .WithMany(x => x.Metrics)
             .HasForeignKey(x => x.ServerId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
