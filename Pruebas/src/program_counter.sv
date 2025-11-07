// program_counter.sv
// PC de 4 bits con incremento, carga y reset asíncrono

module program_counter (
    input  logic        clk,
    input  logic        rst,      // reset asíncrono activo en alto
    input  logic        load,
    input  logic [3:0]  next_pc,
    output logic [3:0]  pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'd0;
        else if (load)
            pc <= next_pc;
        else
            pc <= pc + 4'd1;
    end

endmodule

`ifndef NO_PC_TB
// =============================================================
// Testbench auto-verificable (>=10 ciclos) para program_counter
// =============================================================
module tb_program_counter;
    logic clk;
    logic rst;
    logic load;
    logic [3:0] next_pc;
    logic [3:0] pc;

    program_counter dut (.*);

    // Reloj: periodo 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // VCD opcional: ejecutar con "+dump"
    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("tb_program_counter.vcd");
            $dumpvars(0, tb_program_counter);
        end
    end

    // Estímulos y comprobaciones
    initial begin : stimulus
        integer i;
        $display("Ciclo | RST | LOAD | NEXT_PC |  PC ");
        $display("------|-----|------|---------|-----");

        // 1) Reset asíncrono
    rst = 1; load = 0; next_pc = 4'd0;
    repeat (2) @(posedge clk);
    @(negedge clk); rst = 0; #1; // desactivar lejos del posedge para evitar carreras
    if (pc !== 4'd0) $fatal(1, "Fallo: pc tras reset != 0 (pc=%0d)", pc);

        // 2) 5 incrementos (>= 5 ciclos)
    for (i = 0; i < 5; i = i + 1) @(posedge clk);
    #1; // esperar a que se apliquen las NBAs
    if (pc !== 4'd5) $fatal(1, "Fallo: pc tras 5 incrementos != 5 (pc=%0d)", pc);

        // 3) load = 1 -> cargar 10
    load = 1; next_pc = 4'd10; @(posedge clk); #1;
    if (pc !== 4'd10) $fatal(1, "Fallo: load no cargó 10 (pc=%0d)", pc);
        load = 0;

        // 4) 3 incrementos desde 10 -> 13
    repeat (3) @(posedge clk);
    #1;
    if (pc !== 4'd13) $fatal(1, "Fallo: pc tras 3 incrementos desde 10 != 13 (pc=%0d)", pc);

        // 5) Forzar 15 y verificar overflow 15->0
    load = 1; next_pc = 4'd15; @(posedge clk); #1;
    if (pc !== 4'd15) $fatal(1, "Fallo: load no cargó 15 (pc=%0d)", pc);
    load = 0; @(posedge clk); #1;
    if (pc !== 4'd0) $fatal(1, "Fallo: overflow 15->0 no ocurrió (pc=%0d)", pc);

        $display("OK: Simulación completada (>=10 ciclos, reset, incremento, load y overflow verificados).");
        $finish;
    end
endmodule
`endif
