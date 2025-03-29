# Variables
CC = gcc
CFLAGS = -g -O0
SOURCES = shell.c sim.c decode.c execute.c
TARGET = sim

# Regla principal
$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) $(SOURCES) -o $@

# Regla para pruebas
test: $(TARGET)
	cd .. && ./test.sh

# Limpiar archivos generados
.PHONY: clean
clean:
	rm -rf *.o *~ $(TARGET)