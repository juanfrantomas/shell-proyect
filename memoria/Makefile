# Makefile para compilar la memoria del proyecto

# Configuración
MAIN = main
LATEX = pdflatex
BIBTEX = bibtex
VIEWER = xdg-open

# Directorios
BUILD_DIR = build
OUTPUT_DIR = .

# Archivos
PDF = $(OUTPUT_DIR)/$(MAIN).pdf
TEX = $(MAIN).tex

# Regla por defecto
all: $(PDF)

# Compilación completa (con bibliografía)
$(PDF): $(TEX) bibliografia.bib
	@echo "==> Compilando LaTeX (primera pasada)..."
	$(LATEX) -output-directory=$(OUTPUT_DIR) $(TEX)
	@echo "==> Generando bibliografía..."
	$(BIBTEX) $(OUTPUT_DIR)/$(MAIN)
	@echo "==> Compilando LaTeX (segunda pasada)..."
	$(LATEX) -output-directory=$(OUTPUT_DIR) $(TEX)
	@echo "==> Compilando LaTeX (tercera pasada)..."
	$(LATEX) -output-directory=$(OUTPUT_DIR) $(TEX)
	@echo "==> ✓ Compilación completada: $(PDF)"

# Compilación rápida (sin bibliografía)
quick: $(TEX)
	@echo "==> Compilación rápida..."
	$(LATEX) -output-directory=$(OUTPUT_DIR) $(TEX)
	@echo "==> ✓ Compilación rápida completada"

# Ver el PDF
view: $(PDF)
	@echo "==> Abriendo PDF..."
	$(VIEWER) $(PDF) &

# Limpiar archivos auxiliares
clean:
	@echo "==> Limpiando archivos auxiliares..."
	rm -f $(OUTPUT_DIR)/*.aux
	rm -f $(OUTPUT_DIR)/*.log
	rm -f $(OUTPUT_DIR)/*.out
	rm -f $(OUTPUT_DIR)/*.toc
	rm -f $(OUTPUT_DIR)/*.lof
	rm -f $(OUTPUT_DIR)/*.lot
	rm -f $(OUTPUT_DIR)/*.bbl
	rm -f $(OUTPUT_DIR)/*.blg
	rm -f $(OUTPUT_DIR)/*.synctex.gz
	@echo "==> ✓ Limpieza completada"

# Limpiar todo (incluyendo PDF)
distclean: clean
	@echo "==> Eliminando PDF generado..."
	rm -f $(PDF)
	@echo "==> ✓ Limpieza completa"

# Compilación continua (recompila al detectar cambios)
watch:
	@echo "==> Modo watch activado (Ctrl+C para salir)..."
	@while true; do \
		make quick; \
		inotifywait -qre close_write .; \
	done

# Contador de palabras
wordcount:
	@echo "==> Contando palabras..."
	@texcount -inc -total $(TEX)

# Ayuda
help:
	@echo "Makefile para compilar la memoria"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make           - Compilación completa con bibliografía"
	@echo "  make quick     - Compilación rápida sin bibliografía"
	@echo "  make view      - Abrir el PDF generado"
	@echo "  make clean     - Limpiar archivos auxiliares"
	@echo "  make distclean - Limpiar todo (incluido PDF)"
	@echo "  make watch     - Recompilar automáticamente al guardar"
	@echo "  make wordcount - Contar palabras del documento"
	@echo "  make help      - Mostrar esta ayuda"

.PHONY: all quick view clean distclean watch wordcount help
