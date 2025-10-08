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
  echo "Generando informe en txt" >> $NOMBRE_ARCHIVO_LOG
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
  } > "$NOMBRE_ARCHIVO_INFORME_TXT"

  echo "✅ Informe generado en: $NOMBRE_ARCHIVO_INFORME_TXT" >> $NOMBRE_ARCHIVO_LOG
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


# Igual hay que meter estas variables mas tarde (ojo con los >> log)
echo "Identificador de la ejecución del CRON(FECHA)=$RUN_ID" >> $NOMBRE_ARCHIVO_LOG

echo "Petición de estaciones de la provincia de Valencia" >> $NOMBRE_ARCHIVO_LOG

urlValencia='https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46'

echo "Haciendo petición a $urlValencia" >> $NOMBRE_ARCHIVO_LOG
# Realiza la petición y guarda
status=$(curl -sS -H "Accept: application/json" -o "$NOMBRE_ARCHIVO_GUARDAR_ESTACIONES" -w '%{http_code}' "$urlValencia" 2>> $NOMBRE_ARCHIVO_LOG)

if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]; then
  echo "Petición OK: Estado Petición HTTP = $status" >> $NOMBRE_ARCHIVO_LOG
  getEstacionesValencia=$(cat "$NOMBRE_ARCHIVO_GUARDAR_ESTACIONES")
else
  echo "Ha fallado la petición a $urlValencia. Error HTTP: $status" >> $NOMBRE_ARCHIVO_LOG
fi

# Procesar JSON con jq: extraer Dirección por cada estación

echo "Comprobando que la variable no este vacia" >> $NOMBRE_ARCHIVO_LOG
if [ -z "$getEstacionesValencia" ]; then
  echo "getEstacionesValencia vacío. Termino." >> $NOMBRE_ARCHIVO_LOG
  exit 1
fi

echo "Comprobando que el JSON es válido" >> $NOMBRE_ARCHIVO_LOG
echo "$getEstacionesValencia" | jq empty > /dev/null 2>>$NOMBRE_ARCHIVO_LOG || { echo "JSON inválido" >> $NOMBRE_ARCHIVO_LOG; exit 1; }

echo "Comprobando que existe la variable con la lista de estaciones y precios" >> $NOMBRE_ARCHIVO_LOG
echo "$getEstacionesValencia" | jq -e '.ListaEESSPrecio | type=="array"' >/dev/null 2>>$NOMBRE_ARCHIVO_LOG || { echo "Falta .ListaEESSPrecio[]" >> $NOMBRE_ARCHIVO_LOG; exit 1; }

echo "Comprobando que existe la variable Fecha de la API" >> $NOMBRE_ARCHIVO_LOG
echo "$getEstacionesValencia" | jq -e '.Fecha | type=="string"' >/dev/null 2>>$NOMBRE_ARCHIVO_LOG || { echo "Falta .ListaEESSPrecio[]" >> $NOMBRE_ARCHIVO_LOG; exit 1; }


echo "Procesando el JSON para extraer las variables necesarias" >> $NOMBRE_ARCHIVO_LOG
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
]') || { echo "Fallo transformando con jq." >> $NOMBRE_ARCHIVO_LOG; exit 1; }

echo "Estaciones procesadas: $(echo "$estaciones" | jq 'length')" >> $NOMBRE_ARCHIVO_LOG

# Métricas gasolina
G95_MIN=$(echo "$estaciones" | jq ' [ .[] | .priceGasolina ] | map(select(.!=null)) | min ')
G95_MAX=$(echo "$estaciones" | jq ' [ .[] | .priceGasolina ] | map(select(.!=null)) | max ')
G95_AVG=$(echo "$estaciones" | jq ' [ .[] | .priceGasolina ] | map(select(.!=null)) | if length>0 then (add/length) else null end ')
echo "[stats] INFO G95 min=$G95_MIN max=$G95_MAX avg=$G95_AVG" >> $NOMBRE_ARCHIVO_LOG

# Métricas diesel
DIESEL_MIN=$(echo "$estaciones" | jq ' [ .[] | .priceDiesel ] | map(select(.!=null)) | min ')
DIESEL_MAX=$(echo "$estaciones" | jq ' [ .[] | .priceDiesel ] | map(select(.!=null)) | max ')
DIESEL_AVG=$(echo "$estaciones" | jq ' [ .[] | .priceDiesel ] | map(select(.!=null)) | if length>0 then (add/length) else null end ')
echo "[stats] INFO Diesel min=$DIESEL_MIN max=$DIESEL_MAX avg=$DIESEL_AVG" >> $NOMBRE_ARCHIVO_LOG

# Top 5 G95 por precio
TOP5_G95=$(echo "$estaciones" | jq ' 
  [ .[] | select(.priceGasolina!=null) 
    | { id, name, addr, lat, lon, priceGasolina } 
  ] 
  | sort_by(.priceGasolina) 
  | .[0:5]
') || { echo "[jq] ERROR creando top5_g95" >> $NOMBRE_ARCHIVO_LOG; exit 1; }
echo "[rank] INFO top5_g95 generado" >> $NOMBRE_ARCHIVO_LOG

# Top 5 Diesel por precio
TOP5_DIESEL=$(echo "$estaciones" | jq ' 
  [ .[] | select(.priceDiesel!=null) 
    | { id, name, addr, lat, lon, priceDiesel } 
  ] 
  | sort_by(.priceDiesel) 
  | .[0:5]
') || { echo "[jq] ERROR creando top5_diesel" >> $NOMBRE_ARCHIVO_LOG; exit 1; }
echo "[rank] INFO top5_diesel generado" >> $NOMBRE_ARCHIVO_LOG

TOTAL_EESS_SIN_PRECIO_GASOLINA=$(echo "$estaciones"   | jq '[.[] | select(.priceGasolina==null)] | length')
TOTAL_EESS_SIN_PRECIO_DIESEL=$(echo "$estaciones"| jq '[.[] | select(.priceDiesel==null)]  | length')
TOTAL_EESS_SIN_COORDENADAS=$(echo "$estaciones"| jq '[.[] | select(.lat==null or .lon==null)] | length')

echo "[$(date '+%F %T')] [stats] INFO sin_G95=$TOTAL_EESS_SIN_PRECIO_GASOLINA sin_Diesel=$TOTAL_EESS_SIN_PRECIO_DIESEL sin_Coords=$TOTAL_EESS_SIN_COORDENADAS" >> $NOMBRE_ARCHIVO_LOG

TOTAL_EESS=$(echo "$estaciones" | jq '. | length')


generar_informe_txt
# Generar mas variables para utilizarlas en los informes

#-------------------

# Generar Informes y Texto - JF
# Generar HTML y TXT