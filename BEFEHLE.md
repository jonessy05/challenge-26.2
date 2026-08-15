
## Nützliche Befehle


| Aktion                                          | Befehl                                      |
| ----------------------------------------------- | ------------------------------------------- |
| Logs live                                       | `docker compose logs -f`                    |
| Status                                          | `docker compose ps`                         |
| Minecraft-Befehl senden                         | `docker compose exec mc rcon-cli list`      |
| Interaktive MC-Konsole                          | `docker compose exec -i mc rcon-cli`        |
| Direkte Konsole (detach: Strg+P, Strg+Q)        | `docker compose attach mc`                  |
| Stoppen (Welt speichern)                        | `docker compose stop`                       |
| Starten                                         | `docker compose start`                      |
| Nach Änderung an `compose.yaml`                 | `docker compose up -d`                      |
| Komplett neu starten                            | `docker compose restart`                    |
| Container entfernen (Daten in `./data` bleiben) | `docker compose down`                       |




## Firewall

Port **25565** auf der VM und in der Cloud-Security-Group öffnen, z. B. mit UFW:

```bash
sudo ufw allow 25565/tcp
sudo ufw status
```



## Häufige Probleme

**Container wird vom OOM-Killer beendet**  
`MEMORY` ist zu hoch für den VM-RAM. Heap senken (z. B. auf `5G`) und `docker compose up -d`.

**Spieler kann nicht joinen**  
Client muss **Minecraft 26.2** sein. Port 25565 prüfen (Firewall, Security Group, `docker compose ps`).

`No build found for version …`  
`VERSION` muss `"26.2"` sein (nicht `"1.26.2"`). Bei Pre-Releases ggf. `PAPER_CHANNEL: experimental`.

**Permission-Fehler unter** `./data`  

```bash
sudo chown -R 1000:1000 ./data
```

