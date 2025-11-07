# PC de 4 bits — Verificación y entrega

Este proyecto implementa un Contador de Programa (PC) de 4 bits con:
- Incremento por defecto en cada flanco de subida de `clk`.
- Carga síncrona con `load` del valor `next_pc`.
- Reset asíncrono activo en alto (`rst`).

Incluye un testbench auto-verificable (`tb_program_counter`) que ejecuta ≥ 10 ciclos y chequea:
- Reset → `pc = 0`.
- 5 incrementos → `pc = 5`.
- `load` a 10 → `pc = 10`.
- 3 incrementos → `pc = 13`.
- Forzar 15 y overflow → `pc = 0`.

## Ejecutar simulación con Vivado (xsim)

Opción GUI (Vivado):
1. Abrir Vivado.
2. Tools → Run Tcl Script…
3. Seleccionar: `scripts/sim_program_counter.tcl`

Opción PowerShell (si sabes la ruta a Vivado):
```powershell
$env:VIVADO_BIN = 'C:\Xilinx\Vivado\2024.1\bin\vivado.bat'  # ajusta versión
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_sim.ps1 -Headless
# o sin -Headless para abrir la GUI de ondas
```

El archivo de ondas queda en `build/sim/tb_program_counter.wdb`.

## Alternativa open‑source (opcional)
Con Icarus Verilog (si está instalado):
```powershell
iverilog -g2012 -o build\tb_program_counter.vvp src\program_counter.sv
vvp build\tb_program_counter.vvp +dump   # genera tb_program_counter.vcd
```

## Breve explicación (para la parte escrita)
El PC es un registro que apunta a la siguiente instrucción a ejecutar en una arquitectura secuencial. En cada `clk`:
- Si `rst=1`, se reinicia a 0 (reset asíncrono).
- Si `load=1`, adopta `next_pc` (soporta saltos/branches).
- En otro caso, incrementa en 1. Al ser de 4 bits, el rango es 0–15 y el incremento desde 15 produce overflow a 0, lo que permite direccionar 16 posiciones de memoria.
