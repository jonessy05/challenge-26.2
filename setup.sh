
#!/usr/bin/env bash
# Richtet Docker, Compose und den Paper-26.2-Server in diesem Repo ein.
# Nutzung auf Ubuntu:  git clone … && cd miecratdocker && ./setup.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

run_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

run_docker() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  else
    run_root docker "$@"
  fi
}

echo "==> Paper 26.2 Auto-Setup"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Dieses Skript ist für Ubuntu/Debian (apt) gedacht." >&2
  exit 1
fi

echo "==> Pakete prüfen (Docker, Compose, UFW, Git)"
run_root apt-get update -y
run_root apt-get install -y docker.io docker-compose-v2 git ufw ca-certificates

echo "==> Docker-Dienst starten"
run_root systemctl enable --now docker

if [[ "${EUID}" -ne 0 ]]; then
  if ! id -nG "${USER}" | grep -qw docker; then
    echo "==> Benutzer ${USER} zur Gruppe docker hinzufügen"
    run_root usermod -aG docker "${USER}"
    echo "    Nach dem nächsten Login ist Docker ohne sudo nutzbar."
  fi
fi

mkdir -p "${ROOT}/plugins" "${ROOT}/data" "${ROOT}/patches"

echo "==> Firewall-Port 25565 öffnen (falls UFW aktiv ist oder aktiviert wird)"
if run_root ufw status 2>/dev/null | grep -q "Status: active"; then
  run_root ufw allow 25565/tcp comment "Minecraft Paper"
else
  echo "    UFW ist nicht aktiv — Port in der Cloud-Security-Group selbst öffnen."
fi

echo "==> Server starten (Image, Paper und Plugins werden geladen)"
run_docker compose up -d

echo
echo "Fertig. Plugins aus ./plugins werden nach data/plugins kopiert."
echo "Logs:     docker compose logs -f"
echo "Konsole:  docker compose exec mc rcon-cli"
echo "Status:   docker compose ps"
echo
echo "Sobald in den Logs \"Done\" steht, kannst du joinen (Port 25565)."
