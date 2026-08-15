# Auto-Setup für Paper 26.2 Server

Nach dem Klonen reicht `./setup.sh` — Docker, Paper 26.2 und die Plugins aus dem Repo werden damit eingerichtet.

## Ablauf auf dem Server

```bash
sudo apt update
sudo apt install -y git
git clone <REPO-URL> minecraft-paper
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

## Plugins hinzufügen

**JARs ins Git-Repo legen** und committen. Beim Start kopiert das Image sie nach `data/plugins/`:

```bash
# 1. Plugin-JAR nach plugins/ kopieren
cp MyPlugin.jar plugins/

# 2. Git committen
git add plugins/MyPlugin.jar
git commit -m "Add MyPlugin"
git push
```

Welt und Plugin-Configs bleiben in `data/` und sind `.gitignore`d (lokal).

## Neue JARs später hinzufügen

```bash
# JARs nach plugins/ legen, dann:
docker compose up -d
```

Der Server lädt die neuen Plugins beim Neustart.

## Voraussetzung

Das Repo muss auf **GitHub, GitLab oder ähnlich** liegen. Nur dann kann man es mit `git clone` von der VM aus holen.

## Schnelle Befehle

| Aktion | Befehl |
| --- | --- |
| Logs ansehen | `docker compose logs -f` |
| Server stoppen | `docker compose stop` |
| Server starten | `docker compose start` |
| Status | `docker compose ps` |
| Minecraft-Befehl | `docker compose exec mc rcon-cli list` |
