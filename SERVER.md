# Auto-Setup für Paper 26.2 Server

Nach dem Klonen reicht `./setup.sh` — Docker, Paper 26.2 und die Plugins aus dem Repo werden damit eingerichtet.

## Ablauf auf dem Server

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/jonessy05/challenge-26.2.git minecraft-paper
cd minecraft-paper
chmod +x setup.sh
./setup.sh
```

Das Skript:

- Installiert Docker und Docker Compose
- Startet den Paper-26.2-Server
- Öffnet Port 25565 in der Firewall
- Kopiert alle Plugins aus dem Repo

Sobald in den Logs **"Done"** steht, kannst du joinen.

## Spiel-Einstellungen

Defaults stehen in `minecraft.env` (Hardcore ist an). Nach dem Ändern:

```bash
docker compose up -d
```

Eine schon vorhandene Welt in `data/` übernimmt Hardcore nicht zuverlässig. Dann Welt löschen und neu generieren:

```bash
docker compose stop
rm -rf data/world data/world_nether data/world_the_end
docker compose up -d
```

## Neue JARs später hinzufügen

```bash
# JARs nach plugins/ legen, dann:
docker compose up -d
```

Der Server lädt die neuen Plugins beim Neustart.

## Schnelle Befehle


| Aktion           | Befehl                                 |
| ---------------- | -------------------------------------- |
| Logs ansehen     | `docker compose logs -f`               |
| Server stoppen   | `docker compose stop`                  |
| Server starten   | `docker compose start`                 |
| Status           | `docker compose ps`                    |
| Minecraft-Befehl | `docker compose exec mc rcon-cli list` |


