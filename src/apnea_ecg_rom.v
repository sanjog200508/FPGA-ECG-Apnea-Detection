module apnea_ecg_rom(
    input clk,
    input [12:0] addr,
    output signed [15:0] ecg_out
);

wire [15:0] rom_data;

blk_mem_gen_1 apnea_ecg_rom (
    .clka(clk),
    .addra(addr),
    .douta(rom_data)
);

// Convert to signed
assign ecg_out = rom_data;

endmodule
