import math
import random

class Workload:
    def __init__(self):
        self.t = 0.0

    def step_time(self, dt=1):
        self.t += dt

    def get_global_load(self):
        self.step_time()

        # Cycle journalier + bruit
        day_cycle = 30 + 15 * math.sin(2 * math.pi * self.t / 24)
        noise = random.uniform(-5, 5)

        # Pics de charge
        spike = 0
        if random.random() < 0.05:  # 5% de chance
            spike = random.uniform(15, 30)

        load = day_cycle + noise + spike
        return max(5, load)
