`timescale 1ns/1ps

module enhanced_router1 #(
    parameter ROUTER_ID = 1,
    parameter DWIDTH = 16,
    parameter FIFO_DEPTH = 8,
    parameter GROUP_ID = 4'b0001 //group 1
)(
    input  wire clk,
    input  wire reset,
    input  wire arb_enable,

    // GPU
    input  wire [DWIDTH-1:0] gpu_in_data,
    input  wire              gpu_in_valid,
    input  wire [5:0]        gpu_dest_addr,
    output wire [DWIDTH-1:0] gpu_out_data,
    output wire              gpu_out_valid,

    // Spines in (to router)
    input  wire [DWIDTH-1:0] spine11_in_data,
    input  wire              spine11_in_valid,
    input  wire [5:0]        spine11_dest_addr,
    output wire [DWIDTH-1:0] spine11_out_data,
    output wire              spine11_out_valid,

    input  wire [DWIDTH-1:0] spine21_in_data,
    input  wire              spine21_in_valid,
    input  wire [5:0]        spine21_dest_addr,
    output wire [DWIDTH-1:0] spine21_out_data,
    output wire              spine21_out_valid,

    input  wire [DWIDTH-1:0] spine31_in_data,
    input  wire              spine31_in_valid,
    input  wire [5:0]        spine31_dest_addr,
    output wire [DWIDTH-1:0] spine31_out_data,
    output wire              spine31_out_valid,

    input  wire [DWIDTH-1:0] spine41_in_data,
    input  wire              spine41_in_valid,
    input  wire [5:0]        spine41_dest_addr,
    output wire [DWIDTH-1:0] spine41_out_data,
    output wire              spine41_out_valid,

    // Status buses (tie-offs here)
    output wire [3:0] spine_fifo_in_full,
    output wire [3:0] spine_fifo_in_empty,
    output wire [3:0] spine_fifo_out_full,
    output wire [3:0] spine_fifo_out_empty,
    output wire       gpu_fifo_in_full,
    output wire       gpu_fifo_in_empty,
    output wire       gpu_fifo_out_full,
    output wire       gpu_fifo_out_empty,

    // Crossbar status
    output wire       crossbar_busy,
    output wire [2:0] current_grant,
    output wire [1:0] routing_direction
);

    // Tie off FIFO status (no FIFOs at this top level)
    assign spine_fifo_in_full   = 4'b0000;
    assign spine_fifo_in_empty  = 4'b0000;
    assign spine_fifo_out_full  = 4'b0000;
    assign spine_fifo_out_empty = 4'b0000;
    assign gpu_fifo_in_full     = 1'b0;
    assign gpu_fifo_in_empty    = 1'b0;
    assign gpu_fifo_out_full    = 1'b0;
    assign gpu_fifo_out_empty   = 1'b0;

    // Crossbar instance
    bidirectional_fsm_crossbar1 #(
        .DWIDTH(DWIDTH),
        .GROUP_ID(GROUP_ID)
    ) crossbar (
        .clk(clk),
        .reset(reset),
        .arb_enable(arb_enable),

        .gpu_incoming_data(gpu_in_data),
        .gpu_incoming_valid(gpu_in_valid),
        .gpu_ready(1'b1),
        .gpu_dest_addr(gpu_dest_addr),
        .gpu_outgoing_data(gpu_out_data),
        .gpu_outgoing_valid(gpu_out_valid),

        .spine1_out_data(spine11_in_data),
        .spine1_out_valid(spine11_in_valid),
        .spine1_ready(1'b1),
        .spine1_dest_addr(spine11_dest_addr),
        .spine1_in_data(spine11_out_data),
        .spine1_in_valid(spine11_out_valid),

        .spine2_out_data(spine21_in_data),
        .spine2_out_valid(spine21_in_valid),
        .spine2_ready(1'b1),
        .spine2_dest_addr(spine21_dest_addr),
        .spine2_in_data(spine21_out_data),
        .spine2_in_valid(spine21_out_valid),

        .spine3_out_data(spine31_in_data),
        .spine3_out_valid(spine31_in_valid),
        .spine3_ready(1'b1),
        .spine3_dest_addr(spine31_dest_addr),
        .spine3_in_data(spine31_out_data),
        .spine3_in_valid(spine31_out_valid),

        .spine4_out_data(spine41_in_data),
        .spine4_out_valid(spine41_in_valid),
        .spine4_ready(1'b1),
        .spine4_dest_addr(spine41_dest_addr),
        .spine4_in_data(spine41_out_data),
        .spine4_in_valid(spine41_out_valid),

        .busy(crossbar_busy),
        .current_grant(current_grant),
        .direction(routing_direction)
    );

endmodule
