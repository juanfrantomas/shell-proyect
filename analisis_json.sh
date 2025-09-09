#!/bin/bash
echo "Análisis de JSON"
echo "=================="
echo "Petición de estaciones de la provincia de Valencia" > log.txt
# curl -sS -H "Accept: application/json" \
# "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46" > datos/estacionesValencia.json 2>> log.txt


url='https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46'

archivoGuardar="datos/estacionesValencia.json"

status=$(curl -sS -H "Accept: application/json" -o "$archivoGuardar" -w '%{http_code}' "$url")

if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]; then
  echo "OK: $status"
  echo "Datos guardados en $archivoGuardar $(date)" >> log.txt
else
  echo "A fallado la petición de $url. Error HTTP: $status $(date)" >> log.txt
fi