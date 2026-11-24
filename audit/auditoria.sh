#!/usr/bin/env bash
# Auditoria propia (EP3 - IE5): falla si detecta secretos o CVE criticas.
# Uso: bash audit/auditoria.sh   (requiere Docker y haber corrido "mvn dependency:resolve")
# Codigos de salida de las herramientas: 0 = limpio, hallazgo = codigo propio, otro = error de la herramienta.
set -uo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
M2="${HOME}/.m2"
fallas=0

echo "== 1/2 Secretos en el repositorio (gitleaks, historial completo) =="
docker run --rm \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
    -v "$RAIZ:/repo" \
    zricethezav/gitleaks:latest git --redact -v --exit-code 2 /repo
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "OK: no se detectaron secretos"
elif [ "$rc" -eq 2 ]; then
  echo "FALLA: se detectaron secretos en el repositorio"
  fallas=$((fallas + 1))
else
  echo "ERROR: gitleaks no pudo completar el analisis (codigo $rc); no es un hallazgo"
  fallas=$((fallas + 1))
fi

echo "== 2/2 Vulnerabilidades CRITICAL en dependencias (Trivy) =="
mkdir -p "$M2"
docker run --rm \
    -v "$RAIZ:/repo" \
    -v "$M2:/root/.m2" \
    aquasec/trivy:latest fs \
    --scanners vuln --severity CRITICAL --ignore-unfixed \
    --ignorefile /repo/.trivyignore --exit-code 10 /repo
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "OK: sin CVE CRITICAL corregibles"
elif [ "$rc" -eq 10 ]; then
  echo "FALLA: hay CVE CRITICAL con correccion disponible"
  fallas=$((fallas + 1))
else
  echo "ERROR: Trivy no pudo completar el analisis (codigo $rc); no es un hallazgo"
  fallas=$((fallas + 1))
fi

if [ "$fallas" -gt 0 ]; then
  echo "AUDITORIA RECHAZADA: $fallas control(es) no pasaron"
  exit 1
fi
echo "AUDITORIA APROBADA: todos los controles pasaron"