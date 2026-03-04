# server-simulator/runner.py
import os
import time
from server_lib.server import Server
from server_lib.workload import Workload

def main():
    # Récupération de l'id du serveur
    server_id = os.environ.get("SERVER_ID", "srv_default")
    
    # Récupération du workload et création du serveur
    workload = Workload()
    server = Server(server_id)
    print("Serveur initialisé :", server)

    # Boucle pour faire vivre le serveur
    while True:
        
        load = workload.get_global_load()
        server.step(load)
        
        print("État actuel du serveur", server.id, " : ", server.cpu_usage_percent, "%")
        time.sleep(30)


if __name__ == "__main__":
    main()