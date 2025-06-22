`timescale 1ns / 1ps
module imem #(
    parameter NUM_AXONS = 256,
    parameter IMEM_BASE_0 = 32'h80000000,
    parameter IMEM_BASE_1 = 32'h80010000
) (
    input wb_clk_i,             // Clock
    input wb_rst_i,             // Reset
    input wbs_cyc_i,            // Indicates an active Wishbone cycle
    input wbs_stb_i,            // Active during a valid address phase
    input wbs_we_i,             // Determines read or write operation
    input [3:0] wbs_sel_i,      // Byte lanes selector
    input [31:0] wbs_adr_i,     // Address input
    input [31:0] wbs_dat_i,     // Data input for writes
    output reg wbs_ack_o,       // Acknowledgment for data transfer
    output reg [31:0] wbs_dat_o, // Data output

    input [1:0] core_en_i,
    output [255:0] spike_axon_0_o,
    output [255:0] spike_axon_1_o
);

    reg [31:0] address0, address1;

    reg [31:0] sram_0 [7:0];
    reg [31:0] sram_1 [7:0];

    always @(wbs_dat_i) begin
        address0 = (wbs_adr_i - IMEM_BASE_0)>>2;
        address1 = (wbs_adr_i - IMEM_BASE_1)>>2;
    end

    integer i;
    always @( posedge wb_clk_i or posedge wb_rst_i) begin : imem_ff
        if(wb_rst_i) begin
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h00000000;
            for (i = 0; i < 8; i=i+1) begin
                sram_0[i] <= 32'h0000000;
                sram_1[i] <= 32'h0000000;
            end
        end else begin
            if(wbs_cyc_i & wbs_stb_i) begin
                if(wbs_we_i) begin
                    if(core_en_i[0])begin
                            if (wbs_sel_i[0]) sram_0[address0][7:0] <= wbs_dat_i[7:0];
                            if (wbs_sel_i[1]) sram_0[address0][15:8] <= wbs_dat_i[15:8];
                            if (wbs_sel_i[2]) sram_0[address0][23:16] <= wbs_dat_i[23:16];
                            if (wbs_sel_i[3]) sram_0[address0][31:24] <= wbs_dat_i[31:24];
                    end else if (core_en_i[1]) begin
                            if (wbs_sel_i[0]) sram_1[address1][7:0] <= wbs_dat_i[7:0];
                            if (wbs_sel_i[1]) sram_1[address1][15:8] <= wbs_dat_i[15:8];
                            if (wbs_sel_i[2]) sram_1[address1][23:16] <= wbs_dat_i[23:16];
                            if (wbs_sel_i[3]) sram_1[address1][31:24] <= wbs_dat_i[31:24];
                    end
                end
                wbs_ack_o <= 1'b1;
            end else begin
                wbs_ack_o <= 1'b0;
            end
        end
    end
    assign spike_axon_0_o = {sram_0[0], sram_0[1], sram_0[2], sram_0[3], sram_0[4], sram_0[5], sram_0[6], sram_0[7]};
    assign spike_axon_1_o = {sram_1[0], sram_1[1], sram_1[2], sram_1[3], sram_1[4], sram_1[5], sram_1[6], sram_1[7]};    
endmodule