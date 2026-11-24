#!/usr/bin/env bash
# Auditoria propia (EP3 - IE5): falla si detecta secretos o CVE criticas.
# Uso: bash audit/auditoria.sh   (requiere Docker)
set -uo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
fallas=0

echo "== 1/2 Secretos en el repositorio (gitleaks, historial completo) =="
if docker run --rm \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
    -v "$RAIZ:/repo" \
    zricethezav/gitleaks:latest git --redact -v /repo; then
  echo "OK: no se detectaron secretos"
else
  echo "FALLA: se detectaron secretos en el repositorio"
  fallas=$((fallas + 1))
fi

echo "== 2/2 Vulnerabilidades CRITICAL en dependencias (Trivy) =="
if docker run --rm \
    -v "$RAIZ:/repo" \
    aquasec/trivy:latest fs \
    --scanners vuln --severity CRITICAL --ignore-unfixed \
    --ignorefile /repo/.trivyignore --exit-code 1 /repo; then
  echo "OK: sin CVE CRITICAL corregibles"
else
  echo "FALLA: hay CVE CRITICAL con correccion disponible"
  fallas=$((fallas + 1))
fi

if [ "$fallas" -gt 0 ]; then
  echo "AUDITORIA RECHAZADA: $fallas control(es) fallaron"
  exit 1
fi
echo "AUDITORIA APROBADA: todos los controles pasaron"