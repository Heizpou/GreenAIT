import math
import random


class Workload:
    """
    Génère un profil de charge journalier réaliste.

    Le temps est compté en secondes réelles : avec step_seconds=30,
    un cycle complet de 24h prend 24×3600/30 = 2880 appels à get_load().

    get_load(num_servers) retourne la charge par serveur [0-100+].
    La charge globale représente la demande totale en % de la capacité
    d'un serveur unique ; avec N serveurs, elle est divisée équitablement.
    """

    def __init__(self, step_seconds: int = 30):
        self.t_seconds: float = 0.0
        self.step_seconds = step_seconds

    def step(self) -> None:
        """Avance le temps d'un step."""
        self.t_seconds += self.step_seconds

    @property
    def hour_of_day(self) -> float:
        """Heure courante dans la journée simulée (0.0 – 24.0)."""
        return (self.t_seconds / 3600.0) % 24.0

    def get_load(self, num_servers: int = 1) -> float:
        """
        Retourne la charge par serveur [0-100+] pour le step courant
        et avance le temps d'un step.

        num_servers : nombre total de serveurs qui se partagent la charge.
        """
        self.step()
        global_load = self._global_load()
        return global_load / max(1, num_servers)

    def _global_load(self) -> float:
        """Charge globale en % de la capacité d'un serveur unique."""
        hour = self.hour_of_day

        # Double pic : rush matinal ~9h et pic du soir ~19h
        morning = math.exp(-((hour - 9.0) ** 2) / (2 * 2.5 ** 2))
        evening = math.exp(-((hour - 19.0) ** 2) / (2 * 2.0 ** 2))
        night_floor = 0.15  # 15 % du pic comme plancher nocturne

        normalized = night_floor + (1 - night_floor) * (0.6 * morning + evening)
        load = 15.0 + 75.0 * normalized  # plage [15, 90]

        # Bruit gaussien
        load += random.gauss(0, 3)

        # Pic de charge ponctuel (2 % de probabilité par step)
        if random.random() < 0.02:
            load += random.uniform(10, 30)

        return max(5.0, load)
