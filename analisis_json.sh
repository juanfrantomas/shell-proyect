#!/bin/bash
echo "Análisis de JSON"
echo "=================="


# Script: proceso - Nacho

echo "Petición de estaciones de la provincia de Valencia" > log.txt

urlValencia='https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46'

# URL base (no usada actualmente, pero se mantiene por compatibilidad)
url='https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/'

# Archivo donde se guarda/lee la respuesta JSON
archivoGuardar="datos/estacionesValencia.json"
archivoGuardarCache="datos/estacionesValenciaFormat.json"

# Controla si se usa el archivo local en vez de hacer curl
# true = usar el archivo local si existe (evita peticiones repetidas)
# false = realizar curl a la URL y actualizar el archivo
USE_LOCAL_CACHE=true

if [ "$USE_LOCAL_CACHE" = true ] && [ -f "$archivoGuardar" ]; then
	echo "Usando cache local: $archivoGuardarCache" >> log.txt
	getEstacionesValencia=$(cat "$archivoGuardarCache")
else
	echo "Haciendo petición a $urlValencia" >> log.txt
	# Realiza la petición y guarda el cuerpo en archivoGuardar
	status=$(curl -sS -H "Accept: application/json" -o "$archivoGuardar" -w '%{http_code}' "$urlValencia" 2>> log.txt)
	if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]; then
		echo "OK: $status" >> log.txt
		getEstacionesValencia=$(cat "$archivoGuardar")
	else
		echo "Ha fallado la petición a $urlValencia. Error HTTP: $status" >> log.txt
		# Intentamos leer del archivo si existe, sino salimos con error
		if [ -f "$archivoGuardar" ]; then
			echo "Usando archivo existente a pesar del error: $archivoGuardar" >> log.txt
			getEstacionesValencia=$(cat "$archivoGuardar")
		else
			echo "No hay datos disponibles. Salida." >> log.txt
			exit 1
		fi
	fi
fi

# Procesar JSON con jq: extraer Dirección por cada estación
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
]')

$totalEESS = (estaciones | length)

$mediaPrecioDiesel = '1,29'

$mediaPrecio = '1,30'

# PRUEBA Guardar el JSON formateado en archivo
echo "$estaciones" > "$archivoGuardar"

# Generar mas variables para utilizarlas en los informes

#-------------------

# Generar Informes y Texto - JF
# Generar HTML y TXT

