// arithmetic_shift_reg.sv
// Registro de desplazamiento aritmético hacia la derecha para (Q, Qm1)
// - Mantiene el bit de signo de Q (Q[3])
// - Desplaza a la derecha el par {Q, Qm1}:
//     Qm1 <= Q[0]
//     Q   <= {Q[3], Q[3:1]}
// - load carga Q=data_in y limpia Qm1=0

module arithmetic_shift_reg (
    input  logic       clk,
    input  logic       rst,     // reset asíncrono activo en alto
    input  logic       load,
    input  logic [3:0] data_in,
    output logic [3:0] Q,
    output logic       Qm1
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            Q   <= 4'd0;
            Qm1 <= 1'b0;
        end else if (load) begin
            Q   <= data_in;
            Qm1 <= 1'b0;
        end else begin
            Qm1 <= Q[0];
            Q   <= {Q[3], Q[3:1]}; // desplazamiento aritmético (extiende signo)
        end
    end

endmodule

// =============================================================
// Testbench auto-verificable
// - Prueba valores positivos (0110) y negativos (1010)
// - Verifica conservación del bit de signo y propagación a Qm1
// =============================================================
module tb_arithmetic_shift_reg;
    logic clk;
    logic rst;
    logic load;
    logic [3:0] data_in;
    logic [3:0] Q;
    logic Qm1;

    arithmetic_shift_reg dut (.*);

    // Reloj 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // VCD opcional
    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("tb_arithmetic_shift_reg.vcd");
            $dumpvars(0, tb_arithmetic_shift_reg);
        end
    end

    // Estímulos, checks y CSV
    initial begin : stimulus
        integer csv;
        integer step;
        $display("=== Prueba Registro de Desplazamiento Aritmético ===");
        // Abrir CSV
        csv = $fopen("tb_arithmetic_shift_reg.csv", "w");
        if (csv == 0) $fatal(1, "No se pudo abrir tb_arithmetic_shift_reg.csv");
        $fdisplay(csv, "step,label,Q_bin,Q_signed,Qm1");
        // Reset
        rst = 1; load = 0; data_in = 4'd0;
        repeat (2) @(posedge clk);
        @(negedge clk) rst = 0; #1;
        if (Q !== 4'd0 || Qm1 !== 1'b0)
            $fatal(1, "Fallo reset: Q=%b Qm1=%b", Q, Qm1);

        // Caso positivo: 0110 (6)
        load = 1; data_in = 4'b0110; @(posedge clk); #1;
        if (Q !== 4'b0110 || Qm1 !== 1'b0)
            $fatal(1, "Fallo load +: Q=%b Qm1=%b", Q, Qm1);
        step = 1; $fdisplay(csv, "%0d,load_pos,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);
        load = 0;
        // shift 1 -> Q=0011, Qm1=0
        @(posedge clk); #1;
        if (Q !== 4'b0011 || Qm1 !== 1'b0)
            $fatal(1, "Fallo shift1 +: Q=%b Qm1=%b", Q, Qm1);
        step = step + 1; $fdisplay(csv, "%0d,shift1_pos,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);
        // shift 2 -> Q=0001, Qm1=1
        @(posedge clk); #1;
        if (Q !== 4'b0001 || Qm1 !== 1'b1)
            $fatal(1, "Fallo shift2 +: Q=%b Qm1=%b", Q, Qm1);
        step = step + 1; $fdisplay(csv, "%0d,shift2_pos,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);

        // Caso negativo: 1010 (-6)
        load = 1; data_in = 4'b1010; @(posedge clk); #1;
        if (Q !== 4'b1010 || Qm1 !== 1'b0)
            $fatal(1, "Fallo load -: Q=%b Qm1=%b", Q, Qm1);
        step = step + 1; $fdisplay(csv, "%0d,load_neg,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);
        load = 0;
        // shift 1 -> Q=1101, Qm1=0 (signo 1 conservado)
        @(posedge clk); #1;
        if (Q !== 4'b1101 || Qm1 !== 1'b0 || Q[3] !== 1'b1)
            $fatal(1, "Fallo shift1 -: Q=%b Qm1=%b", Q, Qm1);
        step = step + 1; $fdisplay(csv, "%0d,shift1_neg,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);
        // shift 2 -> Q=1110, Qm1=1
        @(posedge clk); #1;
        if (Q !== 4'b1110 || Qm1 !== 1'b1 || Q[3] !== 1'b1)
            $fatal(1, "Fallo shift2 -: Q=%b Qm1=%b", Q, Qm1);
        step = step + 1; $fdisplay(csv, "%0d,shift2_neg,%04b,%0d,%0d", step, Q, $signed(Q), Qm1);

        $display("OK: Registro de desplazamiento aritmético verificado.");
        $fclose(csv);
        $finish;
    end
endmodule
