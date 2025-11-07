# Makefile: Simulación del PC de 4 bits con Icarus Verilog
# Uso principal:
#   make run      -> compila y ejecuta PC (genera tb_program_counter.vcd)
#   make compile  -> solo compila PC
#   make waves    -> abre GTKWave del PC (si está instalado)
#   make run_asr  -> compila y ejecuta registro aritmético (genera tb_arithmetic_shift_reg.vcd)
#   make waves_asr-> abre GTKWave del registro aritmético
#   make run_ram  -> compila y ejecuta RAM 16x8 con PC (genera tb_ram16x8.vcd)
#   make waves_ram-> abre GTKWave de la RAM
#   make clean    -> limpia artefactos

# Herramientas (puedes sobreescribir con variables de entorno o en la línea de comandos)
IVERILOG ?= iverilog
VVP      ?= vvp
GTK      ?= gtkwave
STD      ?= 2012

# Si Icarus está en C:/iverilog/bin (instalador típico de Windows), usa esa ruta
ifneq ("$(wildcard C:/iverilog/bin/iverilog.exe)","")
	IVERILOG := C:/iverilog/bin/iverilog.exe
	VVP      := C:/iverilog/bin/vvp.exe
endif

# Detectar GTKWave en ubicaciones comunes (ajusta si usas otra ruta)
ifneq ("$(wildcard C:/iverilog/gtkwave/bin/gtkwave.exe)","")
	GTK := C:/iverilog/gtkwave/bin/gtkwave.exe
else ifneq ("$(wildcard C:/oss-cad-suite/bin/gtkwave.exe)","")
	GTK := C:/oss-cad-suite/bin/gtkwave.exe
else ifneq ("$(wildcard C:/Program Files/GTKWave/bin/gtkwave.exe)","")
	GTK := C:/Program Files/GTKWave/bin/gtkwave.exe
else ifneq ("$(wildcard C:/Program Files (x86)/GTKWave/bin/gtkwave.exe)","")
	GTK := C:/Program Files (x86)/GTKWave/bin/gtkwave.exe
endif

# Estructura del proyecto
BUILD := build
SRC_PC   := src/program_counter.sv
OUT_PC   := $(BUILD)/tb_program_counter.vvp
VCD_PC   := tb_program_counter.vcd

SRC_ASR  := src/arithmetic_shift_reg.sv
OUT_ASR  := $(BUILD)/tb_arithmetic_shift_reg.vvp
VCD_ASR  := tb_arithmetic_shift_reg.vcd

SRC_RAM  := src/ram16x8.sv src/program_counter.sv
OUT_RAM  := $(BUILD)/tb_ram16x8.vvp
VCD_RAM  := tb_ram16x8.vcd

.PHONY: all compile run waves clean re

all: run

$(BUILD):
	@powershell -NoProfile -Command "if (-not (Test-Path '$(BUILD)')) { New-Item -ItemType Directory -Path '$(BUILD)' | Out-Null }"

compile: $(OUT_PC)

$(OUT_PC): $(SRC_PC) | $(BUILD)
	"$(IVERILOG)" -g$(STD) -o "$(OUT_PC)" $(SRC_PC)

run: compile
	"$(VVP)" "$(OUT_PC)" +dump
	@echo Simulacion finalizada. VCD: $(VCD_PC)

waves: $(VCD_PC)
	-"$(GTK)" "$(VCD_PC)"

# --- Registro de desplazamiento aritmético ---
compile_asr: $(OUT_ASR)

$(OUT_ASR): $(SRC_ASR) | $(BUILD)
	"$(IVERILOG)" -g$(STD) -o "$(OUT_ASR)" $(SRC_ASR)

run_asr: compile_asr
	"$(VVP)" "$(OUT_ASR)" +dump
	@echo Simulacion finalizada. VCD: $(VCD_ASR)

waves_asr: $(VCD_ASR)
	-"$(GTK)" "$(VCD_ASR)"

# --- RAM 16x8 con PC ---
compile_ram: $(OUT_RAM)

$(OUT_RAM): $(SRC_RAM) | $(BUILD)
	"$(IVERILOG)" -g$(STD) -DNO_PC_TB -s tb_ram16x8 -o "$(OUT_RAM)" $(SRC_RAM)

run_ram: compile_ram
	"$(VVP)" "$(OUT_RAM)" +dump
	@echo Simulacion finalizada. VCD: $(VCD_RAM)

waves_ram: $(VCD_RAM)
	-"$(GTK)" "$(VCD_RAM)"

clean:
	@powershell -NoProfile -Command "if (Test-Path '$(BUILD)') { Remove-Item -Recurse -Force '$(BUILD)' } ; if (Test-Path '$(VCD_PC)') { Remove-Item -Force '$(VCD_PC)' } ; if (Test-Path '$(VCD_ASR)') { Remove-Item -Force '$(VCD_ASR)' } ; if (Test-Path '$(VCD_RAM)') { Remove-Item -Force '$(VCD_RAM)' } ; if (Test-Path 'tb_ram16x8.csv') { Remove-Item -Force 'tb_ram16x8.csv' } ; if (Test-Path 'tb_arithmetic_shift_reg.csv') { Remove-Item -Force 'tb_arithmetic_shift_reg.csv' }"

re: clean all
