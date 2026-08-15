# Paper 26.2 mit Docker (Ubuntu CLI)

Minecraft **26.2** („Chaos Cubed“) per Docker Compose auf einer Ubuntu-VM. Das Image `itzg/minecraft-server` lädt Java und PaperMC automatisch.

## Schnellstart: Repo klonen und automatisch einrichten

Auf der Ubuntu-VM reicht das:

```bash
sudo apt update
sudo apt install -y git
git clone <REPO-URL> minecraft-paper
cd minecraft-paper
chmod +x setup.sh
./setup.sh
```

Das Skript installiert Docker + Compose, startet den Paper-Server und kopiert alle `.jar`-Dateien aus dem Ordner `plugins/` in den laufenden Server (`data/plugins/`).

Plugin-JARs **vor dem Push** nach `plugins/` legen, dann sind sie beim Clone mit dabei. Nachträglich JARs in `plugins/` legen und neu starten:

```bash
docker compose up -d
```

Logs:

```bash
docker compose logs -f
```

## Wichtige Korrekturen

Die Version heißt wirklich **26.2**, nicht `1.26.2`. Mojang nutzt seit 2026 das Schema `Jahr.Drop`.


| Thema             | Richtig                                      | Falsch / veraltet            |
| ----------------- | -------------------------------------------- | ---------------------------- |
| Minecraft / Paper | `VERSION: "26.2"`                            | `1.26.2`                     |
| Java              | **Java 25** (`itzg/minecraft-server:java25`) | Java 21                      |
| Paper-Download    | Fill-API (`fill.papermc.io`)                 | alte `api.papermc.io/v2`     |
| JVM-Flags         | MeowIce (`USE_MEOWICE_FLAGS`)                | Aikar (älter, für Java 8–17) |


Aktuell: **Paper 26.2 Build 112** (stable). Das Image holt automatisch den neuesten 26.2-Build.

## Ressourcen: View-Distance 32

`view-distance` und `simulation-distance` **32** laden rund **4.225 Chunks pro Spieler**. Das braucht viel RAM und eine starke CPU, sonst laggt der Server sofort.

`MEMORY` in der Compose-Datei ist nur der **Java-Heap**. OS, Docker und Non-Heap brauchen zusätzlich etwa **2 GB**.


| VM-RAM   | Sinnvolles `MEMORY`                                  |
| -------- | ---------------------------------------------------- |
| 8 GB     | `5G`–`6G`                                            |
| 10–12 GB | `8G`                                                 |
| 16 GB+   | `12G` (besser für Distance 32 mit mehreren Spielern) |


Aktuell steht in `compose.yaml` **6G**. Anpassen, falls die VM mehr oder weniger RAM hat.

## 1. Docker und Docker Compose installieren

```bash
apt update && apt upgrade -y
sudo apt install docker.io docker-compose-v2 -y
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Danach **einmal ausloggen und wieder einloggen** (oder `newgrp docker`), damit Docker ohne `sudo` läuft.

Prüfen:

```bash
docker --version
docker compose version
```



## 2. Server-Ordner anlegen

```bash
mkdir -p ~/minecraft-paper
cd ~/minecraft-paper
```

Diese Projektdateien dorthin kopieren, vor allem `compose.yaml`, `setup.sh`, `patches/` und `plugins/`. Oder einfach das Repo klonen und `./setup.sh` ausführen.

## 3. Konfiguration

Die Datei `compose.yaml` enthält bereits die aktuelle Konfiguration:

- Paper **26.2**
- Image-Tag **java25**
- Heap **6G**
- View-/Simulation-Distance **32**
- MeowIce-Flags
- Chunk-System: **4 Worker-Threads**, **1 I/O-Thread** (wird beim Start in `data/config/paper-global.yml` gesetzt)
- `stop_grace_period: 1m` (Welt wird beim Stop sauber gespeichert)
- Daten persistieren unter `./data`

Zum Bearbeiten auf der VM:

```bash
nano compose.yaml
```

Speichern: `Strg + O`, Enter, dann `Strg + X`.

## 4. Server starten

```bash
docker compose up -d
```

Beim ersten Start lädt Docker das Image, holt Paper 26.2 und generiert die Welt. Das kann einige Minuten dauern.

## 5. Logs prüfen

```bash
docker compose logs -f
```

Mit `Strg + C` die Log-Ansicht verlassen. Der Server läuft im Hintergrund weiter.

Sobald **Done** in den Logs steht, kannst du mit der IP der Ubuntu-VM in Minecraft **26.2** beitreten (Port **25565**).

## 6. Befehle in die Minecraft-Konsole schicken

`docker compose logs -f` zeigt nur Logs. Zum **Eingeben** von Server-Befehlen (`op`, `whitelist`, `say`, …) gibt es zwei Wege. Am einfachsten ist **rcon-cli**.

### Einzelne Befehle (empfohlen)

Im Ordner mit der `compose.yaml`:

```bash
cd ~/minecraft-paper

docker compose exec mc rcon-cli list
docker compose exec mc rcon-cli say Server ist online
docker compose exec mc rcon-cli op DeinMinecraftName
docker compose exec mc rcon-cli whitelist add DeinMinecraftName
docker compose exec mc rcon-cli save-all
```

### Interaktive Konsole (mehrere Befehle hintereinander)

```bash
docker compose exec -i mc rcon-cli
```

Dann normal Minecraft-Befehle tippen, z. B. `list` oder `op Spieler`. Beenden mit `Strg + C` oder `exit`. Der Server läuft weiter.

### Direkte Server-Konsole (attach)

`tty` und `stdin_open` sind in der `compose.yaml` schon aktiv. Damit kannst du dich an die echte Minecraft-Konsole hängen:

```bash
docker compose attach mc
```

**Wichtig:** Nicht mit `Strg + C` rausgehen — das kann den Server stoppen. Stattdessen **detach**:

`Strg + P`, danach `Strg + Q`

Der Server bleibt dann im Hintergrund laufen.

### Hinweis

`docker compose exec mc bash` öffnet nur eine Linux-Shell im Container, **nicht** die Minecraft-Konsole. Für Spiel-Befehle immer `rcon-cli` oder `attach` nutzen.

## Dateien und Plugins

Serverdateien (Welt, Configs, Laufzeit) liegen unter:

```text
./data/
```

**Plugins ins Git-Repo** (werden beim Start automatisch nach `data/plugins/` kopiert):

```text
./plugins/*.jar
```

Nur `.jar`-Dateien committen, die zu Paper **26.2** passen. Plugin-Configs entstehen danach in `data/plugins/` und bleiben lokal (nicht im Git).

Nach neuen JARs in `plugins/`:

```bash
docker compose up -d
```



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

