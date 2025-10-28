# Logo de la universidad

Coloca aquí el logo de tu universidad con el nombre `logo_universidad.png`

Formato recomendado:
- PNG con fondo transparente
- Resolución: 300 DPI mínimo
- Tamaño aproximado: 800x800 px

Si no tienes el logo, puedes:
1. Comentar la línea en `config/portada.tex` que incluye el logo:
   ```latex
   % \includegraphics[width=0.3\textwidth]{logo_universidad.png}
   ```

2. O crear un placeholder temporal con ImageMagick:
   ```bash
   convert -size 800x800 xc:white -pointsize 48 -draw "text 200,400 'LOGO'" logo_universidad.png
   ```
