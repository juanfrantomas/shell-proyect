#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Funciones necesarias
crear_carpetas() {
  for dir in datos informes planificacion; do
    path="$BASE_DIR/$dir"
    if [ ! -d "$path" ]; then
      mkdir -p "$path"
      echo "[$(date '+%F %T')] (Inicio) INFO Creada carpeta: $path" >> $CRON_LOG_FILE
    else
      echo "[$(date '+%F %T')] (Inicio) INFO La carpeta ya existe: $path" >> $CRON_LOG_FILE
    fi
  done
}

generar_informe_html() {
  echo "Generando informe en html" >> "$NOMBRE_ARCHIVO_LOG"

  cat > "$NOMBRE_ARCHIVO_INFORME_HTML" <<EOF
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Informe de Gasolineras de Valencia</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); color: #333; }
        h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; font-size: 2.5em; text-shadow: 1px 1px 2px rgba(0,0,0,0.1); }
        h2 { color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 10px; margin-top: 40px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 8px; overflow: hidden; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background: #2d3748; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #e8f4fd; transition: background-color 0.3s; }
        .section { margin-bottom: 40px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        p { margin: 10px 0; }
        footer { text-align: center; margin-top: 40px; font-style: italic; color: #7f8c8d; }
        .price.low { color: green; font-weight: bold; }
        .price.high { color: red; font-weight: bold; }
        .price.avg { color: black; }
      </style>
    </head>
    <body>
      <h1>Informe de Gasolineras de Valencia</h1>
      <p>🕒 Fecha del cron: $FECHA_CRON</p>
      <p>📅 Fechas de la API: $FECHAS_API</p>

      <div class="section">
        <h2>🚗 GASOLINA 95</h2>
        <p>Precio mínimo: <span class="price low">$G95_MIN €/L</span></p>
        <p>Precio máximo: <span class="price high">$G95_MAX €/L</span></p>
        <p>Precio medio: <span class="price avg">$G95_AVG €/L</span></p>
        <h3>Top 5 más baratas:</h3>
        <table>
          <tr><th>ID</th><th>Nombre</th><th>Dirección</th><th>Latitud</th><th>Longitud</th><th>Precio Gasolina (€)</th></tr>
    $(echo "$TOP5_G95" | jq --arg avg "$G95_AVG" -r '.[] | "<tr><td>\(.id)</td><td>\(.name)</td><td>\(.addr)</td><td>\(.lat)</td><td>\(.lon)</td><td class='"'"'price " + (if .priceGasolina < ($avg | tonumber) then "low" elif .priceGasolina > ($avg | tonumber) then "high" else "avg" end) + "'"'"'>\((.priceGasolina * 1000 | round / 1000))</td></tr>"')
        </table>
      </div>

      <div class="section">
        <h2>⛽ DIÉSEL</h2>
        <p>Precio mínimo: <span class="price low">$DIESEL_MIN €/L</span></p>
        <p>Precio máximo: <span class="price high">$DIESEL_MAX €/L</span></p>
        <p>Precio medio: <span class="price avg">$DIESEL_AVG €/L</span></p>
        <h3>Top 5 más baratas:</h3>
        <table>
          <tr><th>ID</th><th>Nombre</th><th>Dirección</th><th>Latitud</th><th>Longitud</th><th>Precio Diésel (€)</th></tr>
    $(echo "$TOP5_DIESEL" | jq --arg avg "$DIESEL_AVG" -r '.[] | "<tr><td>\(.id)</td><td>\(.name)</td><td>\(.addr)</td><td>\(.lat)</td><td>\(.lon)</td><td class='"'"'price " + (if .priceDiesel < ($avg | tonumber) then "low" elif .priceDiesel > ($avg | tonumber) then "high" else "avg" end) + "'"'"'>\((.priceDiesel * 1000 | round / 1000))</td></tr>"')
        </table>
      </div>

      <div class="section">
        <h2>📊 ESTADÍSTICAS GENERALES</h2>
        <p>Total de estaciones: $TOTAL_EESS</p>
        <p>Estaciones sin precio diésel: $TOTAL_EESS_SIN_PRECIO_DIESEL</p>
        <p>Estaciones sin precio gasolina: $TOTAL_EESS_SIN_PRECIO_GASOLINA</p>
        <p>Estaciones sin coordenadas: $TOTAL_EESS_SIN_COORDENADAS</p>
      </div>

      <footer><p>Fin del informe generado automáticamente.</p></footer>
    </body>
    </html>
EOF
}

generar_informe_txt() {
  if (( ${TOTAL_EESS:-0} > 0 )); then
    echo "[$(date '+%F %T')] (Informe) INFO Generando informe en txt" >> "$NOMBRE_ARCHIVO_LOG"
    {
      echo "=============================================="
      echo "      INFORME DE GASOLINERAS DE VALENCIA"
      echo "=============================================="
      echo ""
      echo "🕒 Fecha del cron:        $FECHA_CRON"
      echo "📅 Fechas de la API:      $FECHAS_API"
      echo ""
      echo "----------------------------------------------"
      echo "🚗 GASOLINA 95"
      echo "----------------------------------------------"
      echo "Precio mínimo:            $G95_MIN €/L"
      echo "Precio máximo:            $G95_MAX €/L"
      echo "Precio medio:             $G95_AVG €/L"
      echo ""
      echo "Top 5 más baratas:"
      echo "$TOP5_G95"
      echo ""
      echo "----------------------------------------------"
      echo "⛽ DIÉSEL"
      echo "----------------------------------------------"
      echo "Precio mínimo:            $DIESEL_MIN €/L"
      echo "Precio máximo:            $DIESEL_MAX €/L"
      echo "Precio medio:             $DIESEL_AVG €/L"
      echo ""
      echo "Top 5 más baratas:"
      echo "$TOP5_DIESEL"
      echo ""
      echo "----------------------------------------------"
      echo "📊 ESTADÍSTICAS GENERALES"
      echo "----------------------------------------------"
      echo "Total de estaciones:                      $TOTAL_EESS"
      echo "Estaciones sin precio diésel:             $TOTAL_EESS_SIN_PRECIO_DIESEL"
      echo "Estaciones sin precio gasolina:           $TOTAL_EESS_SIN_PRECIO_GASOLINA"
      echo "Estaciones sin coordenadas:               $TOTAL_EESS_SIN_COORDENADAS"
      echo ""
      echo "=============================================="
      echo "Fin del informe generado automáticamente."
      echo "=============================================="
    } > "$NOMBRE_ARCHIVO_INFORME_TXT" 2>>"$NOMBRE_ARCHIVO_LOG" \
    && echo "[$(date '+%F %T')] (Informe) OK Informe generado en: $NOMBRE_ARCHIVO_INFORME_TXT" >> "$NOMBRE_ARCHIVO_LOG" \
    || { echo "[$(date '+%F %T')] (Informe) ERROR Fallo en la generación del informe" >> "$NOMBRE_ARCHIVO_LOG"; return 1; }
  else
    echo "[$(date '+%F %T')] (Informe) ERROR TOTAL_EESS=${TOTAL_EESS:-0} El informe no se puede generar" >> "$NOMBRE_ARCHIVO_LOG"
  fi
}

echo "Empieza el programa" >> "$BASE_DIR/log.txt"
echo "==================" >> "$BASE_DIR/log.txt"

# Identificador de ejecución: nos permite atar logs, salidas y futuros informes.
RUN_ID="$(date +%Y%m%d-%H%M%S)"

CRON_LOG_FILE="$BASE_DIR/cron.log"

# Creacion de carpetas necesarios en caso de que no existan
crear_carpetas

# Nombre de archivos que se van a guardar
NOMBRE_ARCHIVO_VARIOS_LOG="$BASE_DIR/log_${RUN_ID}.txt"

NOMBRE_ARCHIVO_LOG="$BASE_DIR/log.txt"
NOMBRE_ARCHIVO_GUARDAR_ESTACIONES="$BASE_DIR/datos/estacionesValencia_${RUN_ID}.json"

NOMBRE_ARCHIVO_INFORME_TXT="$BASE_DIR/informes/informe_${RUN_ID}.txt"
NOMBRE_ARCHIVO_INFORME_HTML="$BASE_DIR/informes/informe_${RUN_ID}.html"

# Variables extraidas
FECHA_CRON="$(date '+%d/%m/%Y %H:%M:%S')"
FECHAS_API=$(echo "$getEstacionesValencia" | jq -r '.Fecha')

TOP5_G95=""
TOP5_DIESEL=""

DIESEL_MIN=""
DIESEL_MAX=""
DIESEL_AVG=""

G95_MIN=""
G95_MAX=""
G95_AVG=""

TOTAL_EESS=""

TOTAL_EESS_SIN_PRECIO_DIESEL=""
TOTAL_EESS_SIN_PRECIO_GASOLINA=""
TOTAL_EESS_SIN_COORDENADAS=""

# Trap para comprobar el éxito de la ejecución 
trap 'code=$?; if [ $code -eq 0 ]; then
  echo "[$(date "+%F %T")] (Finalizacion) INFO El programa se ha ejecutado correctamente" >> "$NOMBRE_ARCHIVO_LOG"
else
  echo "[$(date "+%F %T")] (Finalizacion) ERROR El programa terminó con código $code" >> "$NOMBRE_ARCHIVO_LOG"
fi' EXIT

# Igual hay que meter estas variables mas tarde (ojo con los >> log)
echo "[$(date '+%F %T')] (Inicio) INFO Identificador de la ejecución del CRON(FECHA)=$RUN_ID" >> $NOMBRE_ARCHIVO_LOG

echo "[$(date '+%F %T')] (Descarga) INFO Petición de estaciones de la provincia de Valencia" >> $NOMBRE_ARCHIVO_LOG

urlValencia='https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46'

echo "[$(date '+%F %T')] (Descarga) INFO Haciendo petición a $urlValencia" >> $NOMBRE_ARCHIVO_LOG
# Realiza la petición y guarda
status=$(curl -sS -H "Accept: application/json" -o "$NOMBRE_ARCHIVO_GUARDAR_ESTACIONES" -w '%{http_code}' "$urlValencia" 2>> $NOMBRE_ARCHIVO_LOG)

if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]; then
  echo "[$(date '+%F %T')] (Descarga) OK Petición Válida: Estado Petición HTTP = $status" >> $NOMBRE_ARCHIVO_LOG
  getEstacionesValencia=$(cat "$NOMBRE_ARCHIVO_GUARDAR_ESTACIONES")
else
  echo "[$(date '+%F %T')] (Descarga) ERROR Ha fallado la petición a $urlValencia. Error HTTP: $status" >> $NOMBRE_ARCHIVO_LOG
  exit 1
fi

# Procesar JSON con jq: extraer Dirección por cada estación

echo "[$(date '+%F %T')] (Procesamiento) INFO Comprobando que la variable no este vacia" >> $NOMBRE_ARCHIVO_LOG
if [ -z "$getEstacionesValencia" ]; then
  echo "[$(date '+%F %T')] (Procesamiento) ERROR la variable está vacia" >> $NOMBRE_ARCHIVO_LOG
  exit 1
fi

echo "[$(date '+%F %T')] (Procesamiento) INFO Comprobando que el JSON es válido" >> "$NOMBRE_ARCHIVO_LOG"
echo "$getEstacionesValencia" | jq empty > /dev/null 2>>"$NOMBRE_ARCHIVO_LOG" \
  && echo "[$(date '+%F %T')] (Procesamiento) OK JSON válido" >> "$NOMBRE_ARCHIVO_LOG" \
  || { echo "[$(date '+%F %T')] (Procesamiento) ERROR JSON inválido" >> "$NOMBRE_ARCHIVO_LOG"; exit 1; }

echo "[$(date '+%F %T')] (Procesamiento) INFO Verificando ListaEESSPrecio como array" >> "$NOMBRE_ARCHIVO_LOG"
echo "$getEstacionesValencia" | jq -e '.ListaEESSPrecio | type=="array"' > /dev/null 2>>"$NOMBRE_ARCHIVO_LOG" \
  && echo "[$(date '+%F %T')] (Procesamiento) OK ListaEESSPrecio presente y es array" >> "$NOMBRE_ARCHIVO_LOG" \
  || { echo "[$(date '+%F %T')] (Procesamiento) ERROR Falta ListaEESSPrecio[] o no es array" >> "$NOMBRE_ARCHIVO_LOG"; exit 1; }

echo "[$(date '+%F %T')] (Procesamiento) INFO Verificando Fecha como string" >> "$NOMBRE_ARCHIVO_LOG"
echo "$getEstacionesValencia" | jq -e '.Fecha | type=="string"' > /dev/null 2>>"$NOMBRE_ARCHIVO_LOG" \
  && echo "[$(date '+%F %T')] (Procesamiento) OK Fecha presente" >> "$NOMBRE_ARCHIVO_LOG" \
  || { echo "[$(date '+%F %T')] (Procesamiento) ERROR Falta Fecha" >> "$NOMBRE_ARCHIVO_LOG"; exit 1; }

echo "[$(date '+%F %T')] (Procesamiento) INFO Procesando el JSON para extraer las variables necesarias" >> $NOMBRE_ARCHIVO_LOG
estaciones=$(echo "$getEstacionesValencia" | jq '[
  .ListaEESSPrecio[]
  | {
      id: (.IDEESS | tonumber?),
      name: .["Rótulo"],
      lat: ( (.Latitud // "") | gsub(",";".") | (if . == "" then null else tonumber end) ),
      lon: ( (.["Longitud (WGS84)"] // "") | gsub(",";".") | (if . == "" then null else tonumber end) ),
      addr: ( [ .["Dirección"], .["Localidad"], .["Provincia"] ] | map(select(. != null and . != "")) | join(", ") ),
      priceDiesel: ( (.["Precio Gasoleo A"] // "") | gsub(",";".") | (if . == "" then null else tonumber end) ),
      priceGasolina: ( ( .["Precio Gasolina 95 E5"]
                         // .["Precio Gasolina 95 E10"]
                         // .["Precio Gasolina 95 E5 Premium"]
                         // "" )
                         | gsub(",";".") | (if . == "" then null else tonumber end) )
    }
]') || { echo "[$(date '+%F %T')] (Procesamiento) ERROR Fallo transformando con jq." >> $NOMBRE_ARCHIVO_LOG; exit 1; }

echo "[$(date '+%F %T')] (Procesamiento) Estaciones procesadas con éxito" >> $NOMBRE_ARCHIVO_LOG

# ── Métricas Gasolina 95 ──────────────────────────────────────────────────────
G95_COUNT=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | length' 2>>"$NOMBRE_ARCHIVO_LOG")
if (( ${G95_COUNT:-0} > 0 )); then
  G95_MIN=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | min  | (. * 1000 | round / 1000)' 2>>"$NOMBRE_ARCHIVO_LOG")
  G95_MAX=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | max  | (. * 1000 | round / 1000)' 2>>"$NOMBRE_ARCHIVO_LOG")
  G95_AVG=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | if length>0 then ((add/length) * 1000 | round / 1000) else null end' 2>>"$NOMBRE_ARCHIVO_LOG")
  echo "[$(date '+%F %T')] (Informe) OK Estadísticos descriptivos (mínimo, media, máximo) obtenidos para Gasolina 95" >> "$NOMBRE_ARCHIVO_LOG"
else
  G95_MIN=""; G95_MAX=""; G95_AVG=""
  echo "[$(date '+%F %T')] (Informe) ERROR No hay datos válidos para Gasolina 95; no se pueden calcular estadísticos descriptivos" >> "$NOMBRE_ARCHIVO_LOG"
fi

# ── Métricas Diésel ──────────────────────────────────────────────────────────
DIESEL_COUNT=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | length' 2>>"$NOMBRE_ARCHIVO_LOG")
if (( ${DIESEL_COUNT:-0} > 0 )); then
  DIESEL_MIN=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | min | (. * 1000 | round / 1000)' 2>>"$NOMBRE_ARCHIVO_LOG")
  DIESEL_MAX=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | max | (. * 1000 | round / 1000)' 2>>"$NOMBRE_ARCHIVO_LOG")
  DIESEL_AVG=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | if length>0 then ((add/length) * 1000 | round / 1000) else null end' 2>>"$NOMBRE_ARCHIVO_LOG")
  echo "[$(date '+%F %T')] (Informe) OK Estadísticos descriptivos (mínimo, media, máximo) obtenidos para Diésel" >> "$NOMBRE_ARCHIVO_LOG"
else
  DIESEL_MIN=""; DIESEL_MAX=""; DIESEL_AVG=""
  echo "[$(date '+%F %T')] (Informe) ERROR No hay datos válidos para Diésel; no se pueden calcular estadísticos descriptivos" >> "$NOMBRE_ARCHIVO_LOG"
fi

# ── Top 5 Gasolina 95 por precio ─────────────────────────────────────────────
echo "[$(date '+%F %T')] (Informe) INFO Calculando Top 5 Gasolina 95 por precio" >> "$NOMBRE_ARCHIVO_LOG"
TOP5_G95=$(echo "$estaciones" | jq '
  [ .[] | select(.priceGasolina!=null)
    | { id, name, addr, lat, lon, priceGasolina }
  ]
  | sort_by(.priceGasolina)
  | .[0:5]
' 2>>"$NOMBRE_ARCHIVO_LOG") \
|| { echo "[$(date '+%F %T')] (Informe) ERROR Fallo al crear Top 5 Gasolina 95 (jq)" >> "$NOMBRE_ARCHIVO_LOG"; exit 1; }

G95_TOP_N=$(echo "$TOP5_G95" | jq 'length' 2>>"$NOMBRE_ARCHIVO_LOG" || echo 0)
if (( ${G95_TOP_N:-0} > 0 )); then
  echo "[$(date '+%F %T')] (Informe) OK Ranking Top 5 Gasolina 95 generado (registros=$G95_TOP_N)" >> "$NOMBRE_ARCHIVO_LOG"
else
  echo "[$(date '+%F %T')] (Informe) ERROR Sin datos válidos para Top 5 Gasolina 95; no se puede generar ranking" >> "$NOMBRE_ARCHIVO_LOG"
fi

# ── Top 5 Diésel por precio ──────────────────────────────────────────────────
echo "[$(date '+%F %T')] (Informe) INFO Calculando Top 5 Diésel por precio" >> "$NOMBRE_ARCHIVO_LOG"
TOP5_DIESEL=$(echo "$estaciones" | jq '
  [ .[] | select(.priceDiesel!=null)
    | { id, name, addr, lat, lon, priceDiesel }
  ]
  | sort_by(.priceDiesel)
  | .[0:5]
' 2>>"$NOMBRE_ARCHIVO_LOG") \
|| { echo "[$(date '+%F %T')] (Informe) ERROR Fallo al crear Top 5 Diésel (jq)" >> "$NOMBRE_ARCHIVO_LOG"; exit 1; }

DIESEL_TOP_N=$(echo "$TOP5_DIESEL" | jq 'length' 2>>"$NOMBRE_ARCHIVO_LOG" || echo 0)
if (( ${DIESEL_TOP_N:-0} > 0 )); then
  echo "[$(date '+%F %T')] (Informe) OK Ranking Top 5 Diésel generado (registros=$DIESEL_TOP_N)" >> "$NOMBRE_ARCHIVO_LOG"
else
  echo "[$(date '+%F %T')] (Informe) ERROR Sin datos válidos para Top 5 Diésel; no se puede generar ranking" >> "$NOMBRE_ARCHIVO_LOG"
fi

TOTAL_EESS_SIN_PRECIO_GASOLINA=$(echo "$estaciones"   | jq '[.[] | select(.priceGasolina==null)] | length')
TOTAL_EESS_SIN_PRECIO_DIESEL=$(echo "$estaciones"| jq '[.[] | select(.priceDiesel==null)]  | length')
TOTAL_EESS_SIN_COORDENADAS=$(echo "$estaciones"| jq '[.[] | select(.lat==null or .lon==null)] | length')

echo "[$(date '+%F %T')] (Informe) INFO Carencia de datos: sin_G95=$TOTAL_EESS_SIN_PRECIO_GASOLINA sin_Diesel=$TOTAL_EESS_SIN_PRECIO_DIESEL sin_Coords=$TOTAL_EESS_SIN_COORDENADAS" >> $NOMBRE_ARCHIVO_LOG

TOTAL_EESS=$(echo "$estaciones" | jq '. | length')


generar_informe_txt

generar_informe_html
