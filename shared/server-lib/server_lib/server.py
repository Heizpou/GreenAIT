import random


class Server:
    """
    Simule un serveur physique unique.

    Appelez step(incoming_load) à chaque tick pour mettre à jour les métriques.

    incoming_load : charge demandée en % de la capacité nominale du serveur.
        - 0-100 : charge normale
        - > 100  : surcharge (la queue s'accumule)

    Les métriques sont accessibles via get_metrics().
    """

    # Constantes physiques
    POWER_IDLE_W: float = 50.0    # consommation en veille active
    POWER_MAX_W: float = 250.0    # consommation à 100 % CPU
    TEMP_AMBIENT_C: float = 22.0  # température ambiante de la salle
    TEMP_MAX_C: float = 95.0      # limite thermique du CPU

    def __init__(self, server_id: str):
        self.id = server_id

        # Commandes
        self.powered_on: bool = True
        self.eco_mode: bool = False

        # Métriques (valeurs initiales proches du ralenti)
        self.cpu_usage_percent: float = random.uniform(3.0, 8.0)
        self.ram_usage_percent: float = random.uniform(20.0, 35.0)
        self.disk_usage_percent: float = random.uniform(30.0, 60.0)
        self.network_in_mbps: float = random.uniform(1.0, 5.0)
        self.network_out_mbps: float = random.uniform(1.0, 5.0)
        self.cpu_temperature_c: float = self.TEMP_AMBIENT_C + 10.0
        self.power_w: float = self.POWER_IDLE_W + 20.0

        # File d'attente interne (% de capacité accumulée non traitée)
        self._queue: float = 0.0

    def step(self, incoming_load: float) -> None:
        """
        Avance la simulation d'un tick.

        incoming_load : charge reçue ce tick, en % de la capacité nominale.
        """
        if not self.powered_on:
            self._apply_powered_off()
            return

        # En mode éco, la capacité de traitement est réduite
        eco_factor = 0.7 if self.eco_mode else 1.0
        effective_capacity = 100.0 * eco_factor

        # Modèle de file d'attente : accumule puis traite jusqu'à la capacité
        self._queue += incoming_load
        processed = min(self._queue, effective_capacity)
        self._queue = max(0.0, self._queue - processed)

        # CPU : utilisation réelle + légère pression de la file
        utilization = processed / effective_capacity * 100.0
        queue_pressure = min(20.0, self._queue * 0.5)
        target_cpu = min(100.0, utilization + queue_pressure)

        # Lissage exponentiel (lag du scheduler CPU)
        alpha = random.uniform(0.2, 0.35)
        self.cpu_usage_percent += alpha * (target_cpu - self.cpu_usage_percent)
        self.cpu_usage_percent += random.gauss(0, 0.5)
        self.cpu_usage_percent = max(0.0, min(100.0, self.cpu_usage_percent))

        # RAM : base fixe + working set proportionnel au CPU (lissé lentement)
        target_ram = 25.0 + self.cpu_usage_percent * 0.55
        self.ram_usage_percent += 0.1 * (target_ram - self.ram_usage_percent)
        self.ram_usage_percent += random.gauss(0, 0.5)
        self.ram_usage_percent = max(0.0, min(100.0, self.ram_usage_percent))

        # Disque : dérive très lente (logs, fichiers temporaires)
        self.disk_usage_percent += random.gauss(0, 0.05)
        self.disk_usage_percent = max(0.0, min(100.0, self.disk_usage_percent))

        # Réseau : proportionnel à la charge courante (fluctue, ne s'accumule pas)
        net_base = incoming_load * 2.5  # Mbps par % de charge
        self.network_in_mbps = max(0.0, net_base * random.uniform(0.8, 1.2))
        self.network_out_mbps = max(0.0, net_base * random.uniform(0.6, 1.0))

        # Température : lag thermique réaliste
        target_temp = (
            self.TEMP_AMBIENT_C
            + (self.cpu_usage_percent / 100.0) * (self.TEMP_MAX_C - self.TEMP_AMBIENT_C) * 0.6
        )
        self.cpu_temperature_c += 0.15 * (target_temp - self.cpu_temperature_c)
        self.cpu_temperature_c = max(self.TEMP_AMBIENT_C, min(self.TEMP_MAX_C, self.cpu_temperature_c))

        # Puissance : modèle linéaire idle → max
        self.power_w = (
            self.POWER_IDLE_W
            + (self.cpu_usage_percent / 100.0) * (self.POWER_MAX_W - self.POWER_IDLE_W)
        )
        self.power_w *= random.uniform(0.98, 1.02)  # bruit de mesure

    def _apply_powered_off(self) -> None:
        self.cpu_usage_percent = 0.0
        self.ram_usage_percent = 0.0
        self.network_in_mbps = 0.0
        self.network_out_mbps = 0.0
        self.cpu_temperature_c = self.TEMP_AMBIENT_C
        self.power_w = 5.0  # consommation standby
        self._queue = 0.0

    def get_metrics(self) -> dict:
        return {
            "server_id": self.id,
            "powered_on": self.powered_on,
            "eco_mode": self.eco_mode,
            "cpu_percent": round(self.cpu_usage_percent, 2),
            "ram_percent": round(self.ram_usage_percent, 2),
            "disk_percent": round(self.disk_usage_percent, 2),
            "net_in_mbps": round(self.network_in_mbps, 2),
            "net_out_mbps": round(self.network_out_mbps, 2),
            "cpu_temp_c": round(self.cpu_temperature_c, 2),
            "power_w": round(self.power_w, 2),
        }
