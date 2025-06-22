`timescale 1ns / 1ps

module omem #(
    parameter NUM_AXONS = 256,
    parameter OMEM_BASE_0 = 32'h80040000,
    parameter OMEM_BASE_1 = 32'h80050000
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

    input [1:0] enable_calc_i,
    input [1:0] core_en_i,
    input [255:0] spike_neuron_0_i,
    input [255:0] spike_neuron_1_i
);

    reg [31:0] address0, address1;

    reg [31:0] sram_0 [7:0];
    reg [31:0] sram_1 [7:0];

    always @(wbs_adr_i) begin
        address0 = (wbs_adr_i - OMEM_BASE_0)>>2;
        address1 = (wbs_adr_i - OMEM_BASE_1)>>2;
    end


    integer i;
    always @( posedge wb_clk_i or posedge wb_rst_i) begin : omem_ff
        if(wb_rst_i) begin
            wbs_ack_o <= 1'b0;
            wbs_dat_o <= 32'h00000000;
            for (i = 0; i < 8; i=i+1) begin
                sram_0[i] <= 32'h00000000;
                sram_1[i] <= 32'h00000000;
            end
        end else begin
            if(wbs_cyc_i && wbs_stb_i) begin
                if(~wbs_we_i) begin            
                    wbs_ack_o <= 1'b1;
                    if(core_en_i[0])begin
                        wbs_dat_o <= sram_0[address0];
                    end else if (core_en_i[1]) begin
                        wbs_dat_o <= sram_1[address1];
                    end
                end
            end //else begin
                //wbs_ack_o <= 1'b0;
            if(enable_calc_i[0]==1'b1)begin
                sram_0[0]<=spike_neuron_0_i[255-:32];
                sram_0[1]<=spike_neuron_0_i[223-:32];
                sram_0[2]<=spike_neuron_0_i[191-:32];
                sram_0[3]<=spike_neuron_0_i[159-:32];
                sram_0[4]<=spike_neuron_0_i[127-:32];
                sram_0[5]<=spike_neuron_0_i[95-:32];
                sram_0[6]<=spike_neuron_0_i[63-:32];
                sram_0[7]<=spike_neuron_0_i[31-:32];
            end
            if (enable_calc_i[1]==1'b1) begin
                sram_1[0]<=spike_neuron_1_i[255-:32];
                sram_1[1]<=spike_neuron_1_i[223-:32];
                sram_1[2]<=spike_neuron_1_i[191-:32];
                sram_1[3]<=spike_neuron_1_i[159-:32];
                sram_1[4]<=spike_neuron_1_i[127-:32];
                sram_1[5]<=spike_neuron_1_i[95-:32];
                sram_1[6]<=spike_neuron_1_i[63-:32];
                sram_1[7]<=spike_neuron_1_i[31-:32];
            end
        end
    end
endmodule