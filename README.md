# 🚗 Sistema de Análisis de Precios de Gasolineras de Valencia

[![Bash](https://img.shields.io/badge/Bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success.svg)]()

Sistema automatizado en Bash para descargar, procesar y generar informes diarios de precios de combustible de estaciones de servicio en la provincia de Valencia. Los datos se obtienen de fuentes públicas del Ministerio de Industria y se procesan para ofrecer análisis de precios mínimos, máximos, medios y rankings de las estaciones más económicas.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Automatización con Cron](#-automatización-con-cron)
- [Salidas Generadas](#-salidas-generadas)
- [Arquitectura](#-arquitectura)
- [Documentación](#-documentación)
- [Ejemplos](#-ejemplos)
- [Solución de Problemas](#-solución-de-problemas)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

## ✨ Características

- 🔄 **Descarga automática** de datos en tiempo real desde API pública del Ministerio
- 📊 **Análisis estadístico** completo: precios mínimos, máximos y medios
- 🏆 **Rankings Top-5** de estaciones más económicas por tipo de combustible
- 📝 **Doble formato de salida**: TXT (consola) y HTML (navegador)
- 🔍 **Validación robusta** de datos JSON con verificación de integridad
- 📈 **Trazabilidad completa** con logs detallados y timestamps
- ⚙️ **Ejecución desatendida** mediante cron (cada hora)
- 🗺️ **Geolocalización** incluye coordenadas de cada estación
- 🚦 **Código de colores** en HTML para visualización rápida (verde/rojo/negro)
- 📦 **Sin dependencias externas** complejas (solo bash, curl y jq)

### Combustibles Soportados

- ⛽ **Gasolina 95** (E5, E10, Premium)
- 🚛 **Diésel A**

## 📁 Estructura del Proyecto

```
shell-proyect/
│
├── analisis_json.sh              # Script principal de análisis
├── README.md                      # Este archivo
├── .gitignore                     # Archivos ignorados por git
│
├── datos/                         # JSONs descargados (gitignored)
│   └── estacionesValencia_YYYYMMDD-HHMMSS.json
│
├── informes/                      # Informes generados (gitignored)
│   ├── informe_YYYYMMDD-HHMMSS.txt
│   └── informe_YYYYMMDD-HHMMSS.html
│
├── planificacion/                 # Configuración de tareas programadas
│   └── crontab.txt               # Entrada de cron para automatización
│
├── memoria/                       # Documentación técnica (LaTeX)
│   ├── main.tex                  # Documento principal
│   ├── main.pdf                  # Memoria compilada
│   ├── capitulos/                # Capítulos de la memoria
│   │   ├── 01_introduccion.tex
│   │   ├── 02_objetivos.tex
│   │   ├── 03_analisis.tex
│   │   ├── 04_diseno.tex
│   │   ├── 05_implementacion.tex
│   │   └── 06_resultados.tex
│   ├── config/                   # Configuración LaTeX
│   │   ├── paquetes.tex
│   │   ├── formato.tex
│   │   └── portada.tex
│   └── imagenes/                 # Recursos visuales
│
├── log.txt                        # Registro funcional (gitignored)
└── cron.log                       # Registro de cron (gitignored)
```

## 🔧 Requisitos

### Software Necesario

- **Bash** 4.0 o superior
- **curl** - Para realizar peticiones HTTP
- **jq** - Para procesamiento de JSON
- **cron** - Para automatización (opcional)

### Instalación de Dependencias

#### En Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install bash curl jq cron
```

#### En CentOS/RHEL:
```bash
sudo yum install bash curl jq cronie
```

#### En macOS:
```bash
brew install bash curl jq
```

### Verificar Instalación

```bash
bash --version    # Debe mostrar 4.0+
curl --version    # Cualquier versión reciente
jq --version      # Debe mostrar 1.5+
```

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/juanfrantomas/shell-proyect.git
cd shell-proyect
```

### 2. Dar Permisos de Ejecución

```bash
chmod +x analisis_json.sh
```

### 3. Estructura de Directorios

El script crea automáticamente las carpetas necesarias en la primera ejecución:
- `datos/` - Para almacenar JSONs descargados
- `informes/` - Para guardar informes TXT y HTML
- `planificacion/` - Para configuración de cron

## 💻 Uso

### Ejecución Manual

```bash
./analisis_json.sh
```

### Salida Esperada

El script genera automáticamente:

1. **JSON descargado**: `datos/estacionesValencia_YYYYMMDD-HHMMSS.json`
2. **Informe TXT**: `informes/informe_YYYYMMDD-HHMMSS.txt`
3. **Informe HTML**: `informes/informe_YYYYMMDD-HHMMSS.html`
4. **Registro en log.txt**: Traza completa de la ejecución

### Ver Último Informe

```bash
# Ver informe TXT
cat informes/informe_*.txt | tail -50

# Abrir informe HTML en navegador
xdg-open informes/informe_*.html  # Linux
open informes/informe_*.html      # macOS
```

### Ver Logs

```bash
# Ver últimas 50 líneas del log funcional
tail -50 log.txt

# Ver log de cron
tail -50 cron.log

# Buscar errores
grep "ERROR" log.txt
```

## ⏰ Automatización con Cron

### Configuración

El proyecto incluye una configuración de cron que ejecuta el análisis **cada hora**.

#### 1. Editar Crontab

```bash
crontab -e
```

#### 2. Agregar Entrada

Copia el contenido de `planificacion/crontab.txt` o agrega manualmente:

```bash
# Análisis de precios de gasolineras cada hora
0 * * * * /usr/bin/env bash /ruta/absoluta/shell-proyect/analisis_json.sh >> /ruta/absoluta/shell-proyect/cron.log 2>&1
```

**⚠️ Importante**: Reemplaza `/ruta/absoluta/` con la ruta real del proyecto.

#### 3. Verificar Configuración

```bash
crontab -l
```

### Personalizar Frecuencia

Puedes modificar la frecuencia de ejecución:

```bash
# Cada 30 minutos
*/30 * * * * /ruta/al/script...

# Cada día a las 8:00 AM
0 8 * * * /ruta/al/script...

# Cada lunes a las 9:00 AM
0 9 * * 1 /ruta/al/script...
```

## 📊 Salidas Generadas

### 1. Informe TXT (Consola)

Formato optimizado para lectura en terminal:

```
==============================================
      INFORME DE GASOLINERAS DE VALENCIA
==============================================

🕒 Fecha del cron:        30/10/2025 14:30:00
📅 Fechas de la API:      2025-10-30 12:00:00

----------------------------------------------
🚗 GASOLINA 95
----------------------------------------------
Precio mínimo:         1.279 EUR/L
Precio máximo:         1.659 EUR/L
Precio medio:          1.468 EUR/L

Top 5 más baratas:
1. Estación XXX - Municipio - 1.279 EUR/L
   Dirección: Calle Ejemplo 123, Valencia
...
```

### 2. Informe HTML (Navegador)

Interfaz web con:
- ✅ Diseño responsive moderno
- ✅ Código de colores (verde/rojo para mejor/peor precio)
- ✅ Tablas interactivas con hover effects
- ✅ Iconos emoji para mejor UX
- ✅ Estadísticas generales al final

### 3. Logs de Auditoría

#### log.txt - Registro Funcional
```
[2025-10-30 14:30:00] (Inicio) INFO Identificador=20251030-143000
[2025-10-30 14:30:01] (Descarga) OK Petición Válida: HTTP=200
[2025-10-30 14:30:02] (Procesamiento) OK JSON válido
[2025-10-30 14:30:03] (Informe) OK Top 5 Gasolina 95 generado
[2025-10-30 14:30:04] (Finalizacion) INFO Programa ejecutado correctamente
```

#### cron.log - Registro del Planificador
Captura salidas de error y advertencias del sistema cron.

## 🏗️ Arquitectura

### Flujo de Procesamiento

```
┌─────────────────┐
│   API Pública   │ ← Ministerio de Industria
└────────┬────────┘
         │ HTTP GET (curl)
         ▼
┌─────────────────┐
│  Descarga JSON  │ → datos/estacionesValencia_*.json
└────────┬────────┘
         │ Validación (jq)
         ▼
┌─────────────────┐
│ Procesamiento   │ → Normalización, tipado, filtrado
└────────┬────────┘
         │ Cálculos
         ▼
┌─────────────────┐
│  Generación de  │ → informes/*.txt + *.html
│    Informes     │
└────────┬────────┘
         │ Registro
         ▼
┌─────────────────┐
│   log.txt +     │ → Auditoría completa
│   cron.log      │
└─────────────────┘
```

### Fases del Script

1. **Inicio**: Creación de directorios, inicialización de variables
2. **Descarga**: Petición HTTP con validación de código de estado
3. **Procesamiento**: 
   - Validación de JSON
   - Normalización de decimales (coma → punto)
   - Conversión de tipos (string → number)
   - Filtrado de datos inválidos
4. **Indicadores**:
   - Cálculo de estadísticos (min, max, avg)
   - Generación de rankings Top-5
   - Métricas de calidad
5. **Informes**: Generación de TXT y HTML con formato
6. **Finalización**: Registro de código de salida y cleanup

### Validaciones Implementadas

- ✅ Código HTTP 2xx en descarga
- ✅ JSON bien formado (sintaxis)
- ✅ Presencia de campos críticos (ListaEESSPrecio, Fecha)
- ✅ Tipos de datos correctos (array, string, number)
- ✅ Valores numéricos en rango válido
- ✅ Coordenadas geográficas válidas o null

## 📚 Documentación

### Memoria Técnica

El directorio `memoria/` contiene documentación técnica completa en LaTeX:

- **Introducción**: Contexto y objetivos
- **Fuente de Datos**: API utilizada y formato
- **Arquitectura**: Diseño del sistema y automatización
- **Validación**: Proceso de verificación de datos
- **Generación de Informes**: Formato y contenido
- **Registro y Auditoría**: Sistema de logging

#### Compilar la Memoria

```bash
cd memoria/
pdflatex main.tex
# Resultado: main.pdf
```

### Fuente de Datos

**API**: [Ministerio de Industria - Precios de Carburantes](https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/help)

**Endpoint**:
```
https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroProvincia/46
```

**Provincia**: Valencia (código 46)

**Formato**: JSON con estructura:
```json
{
  "Fecha": "2025-10-30 12:00:00",
  "ListaEESSPrecio": [
    {
      "IDEESS": "12345",
      "Rótulo": "Nombre Estación",
      "Dirección": "Calle Ejemplo 123",
      "Localidad": "Valencia",
      "Provincia": "VALENCIA",
      "Latitud": "39,470239",
      "Longitud (WGS84)": "-0,376481",
      "Precio Gasolina 95 E5": "1,459",
      "Precio Gasoleo A": "1,389"
    }
  ]
}
```

## 📝 Ejemplos

### Ejemplo 1: Ejecución Manual y Revisión

```bash
# Ejecutar script
./analisis_json.sh

# Ver último informe TXT
tail -100 informes/informe_*.txt | tail -100

# Ver estadísticas del log
grep -E "(OK|ERROR)" log.txt | tail -20

# Verificar errores
if grep -q "ERROR" log.txt; then
    echo "⚠️  Se encontraron errores"
    grep "ERROR" log.txt | tail -5
else
    echo "✅ Ejecución exitosa"
fi
```

### Ejemplo 2: Análisis de Evolución de Precios

```bash
# Comparar precios de Gasolina 95 de últimas 5 ejecuciones
grep "G95 min=" log.txt | tail -5

# Buscar fecha específica
grep "20251030" log.txt | grep "Precio medio"
```

### Ejemplo 3: Monitorización Automatizada

```bash
#!/bin/bash
# Script de monitorización (monitor.sh)

LOG_FILE="/ruta/shell-proyect/log.txt"
LAST_LINE=$(tail -1 "$LOG_FILE")

if echo "$LAST_LINE" | grep -q "correctamente"; then
    echo "✅ Sistema OK"
    exit 0
else
    echo "⚠️  Problema detectado"
    tail -10 "$LOG_FILE"
    exit 1
fi
```

### Ejemplo 4: Extraer Top-5 para Análisis

```bash
# Extraer Top-5 Gasolina 95 del último informe HTML
grep -A 10 "GASOLINA 95" informes/informe_*.html | tail -1 | \
  grep -o '<tr>.*</tr>' | head -5
```

## 🔧 Solución de Problemas

### Error: "curl: command not found"

**Solución**:
```bash
sudo apt-get install curl
# o
sudo yum install curl
```

### Error: "jq: command not found"

**Solución**:
```bash
sudo apt-get install jq
# o
sudo yum install jq
```

### Error: HTTP 403 o 500

**Causa**: API no disponible o problemas de conectividad

**Solución**:
1. Verificar conexión a internet: `ping google.com`
2. Probar acceso manual: `curl -I https://sedeaplicaciones.minetur.gob.es`
3. Revisar `log.txt` para detalles del error
4. Esperar y reintentar más tarde (API puede estar en mantenimiento)

### Error: "JSON inválido"

**Causa**: Descarga incompleta o corrupta

**Solución**:
1. Verificar archivo JSON: `cat datos/estacionesValencia_*.json | jq empty`
2. Revisar tamaño del archivo: `ls -lh datos/`
3. Eliminar archivo corrupto y reejecutar

### Cron no ejecuta el script

**Diagnóstico**:
```bash
# Verificar cron está activo
systemctl status cron

# Ver logs de cron del sistema
grep CRON /var/log/syslog | tail -20

# Verificar permisos
ls -l analisis_json.sh
```

**Soluciones**:
1. Verificar que la ruta en crontab sea absoluta
2. Asegurar que el script tiene permisos de ejecución: `chmod +x analisis_json.sh`
3. Verificar que cron.log tiene permisos de escritura
4. Probar manualmente con el mismo comando de cron

### Valores null en coordenadas

**Causa**: Algunas estaciones no proporcionan coordenadas

**Solución**: Es normal, el script maneja estos casos:
```bash
# Ver cuántas estaciones carecen de coordenadas
grep "sin_Coords" log.txt | tail -1
```

### Permisos denegados

**Solución**:
```bash
# Dar permisos al usuario actual
chmod -R u+w datos/ informes/
chmod u+w log.txt cron.log
```

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 👤 Autores

**Juan Fran**
- GitHub: [@juanfrantomas](https://github.com/juanfrantomas)

**Nacho Galiano**
- GitHub: [@nachogalianolopez](https://github.com/nachogalianolopez)

---

**Nota**: Este proyecto fue desarrollado como trabajo académico para la asignatura de Shell Scripting en el Máster en en Inteligencia Artificial y Big Data Analytics.

⭐ Si este proyecto te resulta útil, considera darle una estrella en GitHub
