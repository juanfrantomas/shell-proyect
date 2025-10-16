#!/bin/bash

# Funciones necesarias
crear_carpetas() {
  for dir in datos informes planificacion; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      echo "📁 Carpeta creada: $dir"
    else
      echo "✔️ Carpeta ya existe: $dir"
    fi
  done
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
echo "Empieza el programa"
echo "=================="

# Creacion de carpetas necesarios en caso de que no existan
crear_carpetas

# Identificador de ejecución: nos permite atar logs, salidas y futuros informes.(NACHO)
RUN_ID="$(date +%Y%m%d-%H%M%S)"

# Nombre de archivos que se van a guardar
NOMBRE_ARCHIVO_VARIOS_LOG="./log_${RUN_ID}.txt"

NOMBRE_ARCHIVO_LOG="./log.txt"

NOMBRE_ARCHIVO_GUARDAR_ESTACIONES="./datos/estacionesValencia_${RUN_ID}.json"

NOMBRE_ARCHIVO_INFORME_TXT="./informes/informe_${RUN_ID}.txt"

# Variables extraidas
FECHA_CRON="$RUN_ID"
FECHAS_API=""

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
  G95_MIN=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | min' 2>>"$NOMBRE_ARCHIVO_LOG")
  G95_MAX=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | max' 2>>"$NOMBRE_ARCHIVO_LOG")
  G95_AVG=$(echo "$estaciones" | jq '[ .[] | .priceGasolina ] | map(select(.!=null)) | if length>0 then (add/length) else null end' 2>>"$NOMBRE_ARCHIVO_LOG")
  echo "[$(date '+%F %T')] (Informe) OK Estadísticos descriptivos (mínimo, media, máximo) obtenidos para Gasolina 95" >> "$NOMBRE_ARCHIVO_LOG"
else
  G95_MIN=""; G95_MAX=""; G95_AVG=""
  echo "[$(date '+%F %T')] (Informe) ERROR No hay datos válidos para Gasolina 95; no se pueden calcular estadísticos descriptivos" >> "$NOMBRE_ARCHIVO_LOG"
fi

# ── Métricas Diésel ──────────────────────────────────────────────────────────
DIESEL_COUNT=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | length' 2>>"$NOMBRE_ARCHIVO_LOG")
if (( ${DIESEL_COUNT:-0} > 0 )); then
  DIESEL_MIN=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | min' 2>>"$NOMBRE_ARCHIVO_LOG")
  DIESEL_MAX=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | max' 2>>"$NOMBRE_ARCHIVO_LOG")
  DIESEL_AVG=$(echo "$estaciones" | jq '[ .[] | .priceDiesel ] | map(select(.!=null)) | if length>0 then (add/length) else null end' 2>>"$NOMBRE_ARCHIVO_LOG")
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