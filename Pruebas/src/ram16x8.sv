// ram16x8.sv
// Memoria RAM 16x8 (4 bits de dirección, 8 bits por palabra)
// - Lectura/escritura síncronas al flanco positivo de clk
// - Inicializada con valores de ejemplo 0x41..0x50 ("A"..)

module ram16x8 (
    input  logic        clk,
    input  logic        we,
    input  logic [3:0]  addr,
    input  logic [7:0]  data_in,
    output logic [7:0]  data_out
);
    logic [7:0] mem [0:15];

    // Inicialización con valores ASCII: 0x41 ('A') + índice
    initial begin : init_mem
        integer i;
        for (i = 0; i < 16; i++) begin
            mem[i] = 8'h41 + i; // A, B, C, ...
        end
    end

    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
        data_out <= mem[addr];
    end
endmodule

// =============================================================
// Testbench: RAM 16x8 con acceso mediante el PC de 4 bits
// Requisitos verificados:
//  - Lectura secuencial pc->addr con datos de ejemplo
//  - Efecto de escritura (we=1) en un ciclo
//  - Comportamiento al llegar pc=1111 (wrap a 0000)
//  - Tabla de resultados por ciclo (pc, addr, data_out)
// =============================================================
module tb_ram16x8;
    // Señales PC
    logic clk;
    logic rst;
    logic load;
    logic [3:0] next_pc;
    logic [3:0] pc;

    // Señales RAM
    logic        we;
    logic [3:0]  addr;
    logic [7:0]  data_in;
    logic [7:0]  data_out;

    // Instancias
    program_counter u_pc (
        .clk(clk), .rst(rst), .load(load), .next_pc(next_pc), .pc(pc)
    );
    ram16x8 u_ram (
        .clk(clk), .we(we), .addr(addr), .data_in(data_in), .data_out(data_out)
    );

    // Reloj 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // VCD opcional
    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("tb_ram16x8.vcd");
            $dumpvars(0, tb_ram16x8);
        end
    end

    // Estímulos, tabla y CSV
    initial begin : stim
        integer cycle;
        integer csv;
        byte ascii;
        // CSV: abrir archivo
        csv = $fopen("tb_ram16x8.csv", "w");
        if (csv == 0) $fatal(1, "No se pudo abrir tb_ram16x8.csv para escritura");
        $fdisplay(csv, "cycle,pc,addr,data_out_hex,data_out_dec,data_out_ascii");

        $display("Ciclo | PC  | ADDR | DATA_OUT (hex) | ASCII");
        $display("------|-----|------|----------------|------");

        // Reset y arranque del PC
        rst = 1; load = 0; next_pc = 4'd0; we = 0; data_in = 8'h00; addr = 4'd0;
        repeat (2) @(posedge clk);
        @(negedge clk) rst = 0; #1;

        // Leer 20 ciclos, con una escritura en un ciclo específico
        for (cycle = 1; cycle <= 20; cycle = cycle + 1) begin
            // Dirección conectada al PC
            addr = pc;

            // Inyectar una escritura en el ciclo 2 (visible nuevamente tras wrap)
            if (cycle == 2) begin
                we = 1; data_in = 8'h5A; // 'Z'
            end else begin
                we = 0; data_in = 8'h00;
            end

            @(posedge clk); #1; // esperar NBAs

            // Mostrar fila de tabla y volcar a CSV
            ascii = (data_out>=8'h20 && data_out<=8'h7E) ? data_out : 8'h2E; // '.' si no imprimible
            $display("%5d | %04b | %04b |      0x%02h       |  %c",
                     cycle, pc, addr, data_out, ascii);
            $fdisplay(csv, "%0d,%04b,%04b,0x%02h,%0d,%c", cycle, pc, addr, data_out, data_out, ascii);
        end

        $display("\nNota: En el ciclo 2 se escribió 'Z' (0x5A) en la dirección indicada por PC (addr=0001).");
    $display("Al retornar el PC a esa dirección tras el wrap (ciclo 18), se observa el nuevo dato.");
        $display("Cuando el PC llega a 1111, al siguiente ciclo vuelve a 0000 (lectura circular).\n");
        $display("CSV generado: tb_ram16x8.csv");
        $fclose(csv);
        $finish;
    end
endmodule
