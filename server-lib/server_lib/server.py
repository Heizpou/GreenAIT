import random

class Server:
    def __init__(self, id: str):
        self.id = id
        self.cpu_usage_percent = random.uniform(5, 15)
        self.ram_usage_percent = random.uniform(25, 60)
        self.disk_usage_percent = random.uniform(20, 70)
        self.network_in_mbps = random.uniform(0, 100)
        self.network_out_mbps = random.uniform(0, 100)
        self.cpu_temperature_c = random.uniform(40, 55)
        self.power_w = random.uniform(50, 150)
        self.eco_mode = False
        self.powered_on = True
        self.queue = 0.0

    def step(self, incoming_load: float):
        if not self.powered_on:
            self.cpu_usage_percent = 0
            self.ram_usage_percent = 0
            self.network_in_mbps = 0
            self.network_out_mbps = 0
            self.cpu_temperature_c = 24
            self.power_w = 5
            return

        # Ajustement de la charge selon mode éco
        eco_factor = 0.6 if self.eco_mode else 1.0
        load_effective = incoming_load * eco_factor

        # Simulation de la file d'attente
        incoming = load_effective * random.uniform(0.8, 1.2) * 0.5e6
        if random.random() < 0.1:
            incoming += random.uniform(0.5e6, 2e6)
        self.queue += incoming

        # Capacité de traitement du serveur
        processing_capacity = self.cpu_usage_percent / 100.0 * 1.0e5 * eco_factor
        processed = min(self.queue, processing_capacity)
        self.queue -= processed

        # CPU proportionnel à la charge + lissage
        queue_pressure = min(100, self.queue / 1e6)
        target_cpu_percent = queue_pressure
        self.cpu_usage_percent += (target_cpu_percent - self.cpu_usage_percent) * random.uniform(0.15, 0.25)
        self.cpu_usage_percent += random.uniform(-1, 1)
        self.cpu_usage_percent = max(0, min(100, self.cpu_usage_percent))

        # RAM proportionnelle au CPU
        self.ram_usage_percent = min(100, self.cpu_usage_percent * random.uniform(0.6, 0.9))

        # Température CPU
        self.cpu_temperature_c = min(100, max(20, 24 + (self.cpu_usage_percent * 0.6) * random.uniform(0.8, 1.2)))

        # Disk usage fluctue légèrement
        self.disk_usage_percent += random.uniform(-0.5, 0.5)
        self.disk_usage_percent = min(100, max(0, self.disk_usage_percent))

        # Network fluctue avec charge
        net_in_delta = load_effective * 0.05 * random.uniform(0.8, 1.2)
        net_out_delta = load_effective * 0.05 * random.uniform(0.8, 1.2)
        self.network_in_mbps = min(500, self.network_in_mbps + net_in_delta)
        self.network_out_mbps = min(500, self.network_out_mbps + net_out_delta)

        # Puissance approximative
        self.power_w = 50 + self.cpu_usage_percent * 1.5 + self.ram_usage_percent * 0.5

    def get_metrics(self):
        return {
            "cpu": self.cpu_usage_percent,
            "ram": self.ram_usage_percent,
            "disk": self.disk_usage_percent,
            "net_in": self.network_in_mbps,
            "net_out": self.network_out_mbps,
            "temp": self.cpu_temperature_c,
            "power": self.power_w
        }
