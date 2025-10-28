# Memoria del Proyecto - Análisis de Precios de Gasolineras

Este directorio contiene la memoria completa del proyecto en formato LaTeX.

## Estructura

```
memoria/
├── main.tex                    # Documento principal
├── bibliografia.bib            # Referencias bibliográficas
├── Makefile                    # Automatización de compilación
├── README.md                   # Este archivo
├── config/                     # Configuración del documento
│   ├── paquetes.tex           # Paquetes LaTeX
│   ├── formato.tex            # Formato y estilo
│   ├── comandos.tex           # Comandos personalizados
│   └── portada.tex            # Portada y preliminares
├── capitulos/                  # Capítulos de la memoria
│   ├── 01_introduccion.tex
│   ├── 02_objetivos.tex
│   ├── 03_analisis.tex
│   ├── 04_diseno.tex
│   ├── 05_implementacion.tex
│   ├── 06_resultados.tex
│   └── 07_conclusiones.tex
├── apendices/                  # Apéndices
│   ├── A_codigo.tex           # Código fuente
│   └── B_manual.tex           # Manual de usuario
└── imagenes/                   # Imágenes y figuras
```

## Requisitos

### Ubuntu/Debian

```bash
sudo apt-get install texlive-full
sudo apt-get install texlive-lang-spanish
sudo apt-get install make
```

### Fedora/RHEL

```bash
sudo dnf install texlive-scheme-full
sudo dnf install make
```

### macOS

```bash
brew install --cask mactex
```

## Compilación

### Compilación completa (recomendado)

```bash
make
```

Esto ejecutará:
1. pdflatex (primera pasada)
2. bibtex (bibliografía)
3. pdflatex (segunda pasada)
4. pdflatex (tercera pasada)

### Compilación rápida

Para compilaciones rápidas durante la edición (sin procesar bibliografía):

```bash
make quick
```

### Ver el PDF

```bash
make view
```

### Limpiar archivos auxiliares

```bash
make clean
```

### Limpiar todo (incluyendo PDF)

```bash
make distclean
```

## Compilación manual

Si prefieres no usar el Makefile:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

## Modo watch (auto-recompilación)

Requiere `inotify-tools`:

```bash
sudo apt-get install inotify-tools  # Ubuntu/Debian
make watch
```

Esto recompilará automáticamente el documento cada vez que guardes cambios.

## Estructura del documento

El documento está organizado en:

1. **Portada y preliminares** (portada.tex)
   - Portada
   - Resumen
   - Agradecimientos

2. **Índices**
   - Tabla de contenidos
   - Lista de figuras
   - Lista de tablas

3. **Capítulos principales**
   - Introducción
   - Objetivos
   - Análisis del problema
   - Diseño de la solución
   - Implementación
   - Resultados
   - Conclusiones y trabajo futuro

4. **Material adicional**
   - Bibliografía
   - Apéndices (código y manual)

## Personalización

### Cambiar información de portada

Edita `config/portada.tex`:
- Universidad
- Grado/Máster
- Título del proyecto
- Autor
- Tutor
- Fecha

### Añadir tu logo universitario

Coloca el logo en `imagenes/logo_universidad.png`

### Modificar estilo

Edita `config/formato.tex` para cambiar:
- Interlineado
- Márgenes
- Colores
- Fuentes
- Estilo de código

## Incluir código fuente

### Código inline

```latex
El comando \code{jq} procesa JSON...
```

### Bloque de código

```latex
\begin{lstlisting}[style=bash,caption={Descripción}]
#!/bin/bash
echo "Hola mundo"
\end{lstlisting}
```

### Incluir archivo externo

```latex
\codigobash{analisis_json.sh}{Script principal}
```

## Incluir imágenes

```latex
\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{nombre_imagen.png}
  \caption{Descripción de la imagen}
  \label{fig:etiqueta}
\end{figure}
```

Referencia: `Como se ve en la Figura \ref{fig:etiqueta}...`

## Bibliografía

### Añadir referencias

Edita `bibliografia.bib` y añade entradas:

```bibtex
@article{clave,
  author = {Nombre Apellido},
  title = {Título del artículo},
  journal = {Revista},
  year = {2024}
}
```

### Citar en el texto

```latex
Según \cite{clave}, el análisis...
```

## Consejos

1. **Compila frecuentemente**: Usa `make quick` durante la edición
2. **Commit frecuente**: Haz commits de Git después de cada sección completada
3. **Versión PDF**: Genera un PDF final con `make` antes de entregar
4. **Revisa warnings**: Lee los mensajes de LaTeX en busca de advertencias
5. **Ortografía**: Usa un corrector ortográfico antes de finalizar

## Solución de problemas

### Error: "File not found"

Asegúrate de estar en el directorio `memoria/`:

```bash
cd memoria
make
```

### Error: "Undefined control sequence"

Revisa que todos los paquetes estén instalados:

```bash
sudo apt-get install texlive-latex-extra
```

### La bibliografía no aparece

Ejecuta la compilación completa:

```bash
make distclean
make
```

### Referencias cruzadas con "??"

Ejecuta pdflatex dos veces más después de los cambios.

## Recursos útiles

- [Overleaf LaTeX Documentation](https://www.overleaf.com/learn)
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [Detexify](http://detexify.kirelabs.org/classify.html) - Buscar símbolos LaTeX
- [Tables Generator](https://www.tablesgenerator.com/) - Generar tablas LaTeX

## Contacto

Para dudas sobre la memoria:
- Issues: https://github.com/juanfrantomas/shell-proyect/issues
- Email: tu-email@ejemplo.com
