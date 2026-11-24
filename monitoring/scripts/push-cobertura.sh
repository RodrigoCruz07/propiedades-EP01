#!/usr/bin/env bash
# Publica la cobertura de lineas (JaCoCo) en el Pushgateway.
# Uso: bash monitoring/scripts/push-cobertura.sh [URL_PUSHGATEWAY]
set -euo pipefail

PUSHGATEWAY="${1:-http://localhost:9091}"
XML="target/site/jacoco/jacoco.xml"

[ -f "$XML" ] || { echo "No existe $XML; ejecuta primero: mvn verify"; exit 1; }

# El ultimo contador LINE del archivo corresponde al total del reporte
linea=$(grep -o '<counter type="LINE" missed="[0-9]*" covered="[0-9]*"/>' "$XML" | tail -n 1)
missed=$(echo "$linea" | sed -E 's/.*missed="([0-9]+)".*/\1/')
covered=$(echo "$linea" | sed -E 's/.*covered="([0-9]+)".*/\1/')
total=$((missed + covered))
[ "$total" -gt 0 ] || { echo "El reporte no tiene lineas medidas"; exit 1; }

pct=$(awk -v c="$covered" -v t="$total" 'BEGIN { printf "%.2f", c * 100 / t }')

printf '# TYPE jacoco_line_coverage_percent gauge\njacoco_line_coverage_percent %s\n' "$pct" \
  | curl -fsS --data-binary @- "$PUSHGATEWAY/metrics/job/pipeline/servicio/propiedades-svc"

echo "Cobertura publicada: ${pct}%"