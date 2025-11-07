#!/usr/bin/env tclsh
# Simulación de program_counter (SystemVerilog) con xsim

# Rutas basadas en la ubicación del script
set script_path [file normalize [info script]]
set script_dir  [file dirname $script_path]
set proj_root   [file normalize [file join $script_dir ..]]
set src_dir     [file join $proj_root src]
set build_dir   [file join $proj_root build sim]
file mkdir $build_dir
cd $build_dir

set src_file [file join $src_dir program_counter.sv]
if {![file exists $src_file]} { puts stderr "No se encontró $src_file"; exit 1 }

puts "Compilando: $src_file"
xvlog -sv $src_file || exit 1

puts "Elaborando tb_program_counter"
xelab tb_program_counter -s tb_program_counter_sim || exit 1

puts "Ejecutando simulación"
xsim tb_program_counter_sim -runall -wdb tb_program_counter.wdb || exit 1

if {[info exists ::env(HEADLESS)] && $::env(HEADLESS) eq "1"} {
  puts "HEADLESS=1: omitiendo GUI. WDB en $build_dir/tb_program_counter.wdb"
} else {
  puts "Abriendo ondas"
  open_wave_database tb_program_counter.wdb
  log_wave -recursive /
  start_gui
}
