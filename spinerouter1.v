`timescale 1ns/1ps

module spine_router1 #(
    parameter GROUP_ID = 4'b0001, //group 1
    parameter SPINE_ROUTER_ID = 1,
    parameter DWIDTH = 16,
    parameter FIFO_DEPTH = 8
)(
    input  wire clk,
    input  wire reset,
    input dir_local,
    
    // Port 1-4 (leaf ports)
    input [DWIDTH-1:0] spine11_in_data, spine12_in_data, spine13_in_data, spine14_in_data,
    input spine11_in_valid, spine12_in_valid, spine13_in_valid, spine14_in_valid,
    output reg [DWIDTH-1:0] spine11_out_data, spine12_out_data, spine13_out_data, spine14_out_data,
    output reg spine11_out_valid, spine12_out_valid, spine13_out_valid, spine14_out_valid,
    
    // Port 5-11 (group ports)
    input [DWIDTH-1:0] group211_out_data, group311_out_data, group411_out_data, group511_out_data,
    input [DWIDTH-1:0] group611_out_data, group711_out_data, group811_out_data,
    input group211_out_valid, group311_out_valid, group411_out_valid, group511_out_valid,
    input group611_out_valid, group711_out_valid, group811_out_valid,
    output reg [DWIDTH-1:0] group211_in_data, group311_in_data, group411_in_data, group511_in_data,
    output reg [DWIDTH-1:0] group611_in_data, group711_in_data, group811_in_data,
    output reg group211_in_valid, group311_in_valid, group411_in_valid, group511_in_valid,
    output reg group611_in_valid, group711_in_valid, group811_in_valid
);

    // Internal port connections
    wire [DWIDTH-1:0] P_in_data [1:11];
    wire [1:11] P_in_valid;
    wire [DWIDTH-1:0] P_out_data [1:11];
    reg [1:11] P_out_valid;
    wire [1:11] P_in_fifo_full;
    wire [1:11] P_out_fifo_full;

    // FSM signals
    wire [5:0] rt_dest_addr;

    // ==========================
    // Port Instantiations - USING FIXED PORTS
    // ==========================
    
    // Port 1 (leaf1)
    spine_router_port #(.PORT_ID(1), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port1 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(spine11_in_data), .in_incoming_valid(spine11_in_valid),
        .in_outgoing_data(P_in_data[1]), .in_outgoing_valid(P_in_valid[1]),
        .out_incoming_data(P_out_data[1]), .out_incoming_valid(P_out_valid[1]),
        .out_outgoing_data(spine11_out_data), .out_outgoing_valid(spine11_out_valid),
        .in_fifo_full(P_in_fifo_full[1]), .out_fifo_full(P_out_fifo_full[1])
    );

    // Port 2 (leaf2)
    spine_router_port #(.PORT_ID(2), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port2 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(spine12_in_data), .in_incoming_valid(spine12_in_valid),
        .in_outgoing_data(P_in_data[2]), .in_outgoing_valid(P_in_valid[2]),
        .out_incoming_data(P_out_data[2]), .out_incoming_valid(P_out_valid[2]),
        .out_outgoing_data(spine12_out_data), .out_outgoing_valid(spine12_out_valid),
        .in_fifo_full(P_in_fifo_full[2]), .out_fifo_full(P_out_fifo_full[2])
    );

    // Port 3 (leaf3)
    spine_router_port #(.PORT_ID(3), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port3 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(spine13_in_data), .in_incoming_valid(spine13_in_valid),
        .in_outgoing_data(P_in_data[3]), .in_outgoing_valid(P_in_valid[3]),
        .out_incoming_data(P_out_data[3]), .out_incoming_valid(P_out_valid[3]),
        .out_outgoing_data(spine13_out_data), .out_outgoing_valid(spine13_out_valid),
        .in_fifo_full(P_in_fifo_full[3]), .out_fifo_full(P_out_fifo_full[3])
    );

    // Port 4 (leaf4)
    spine_router_port #(.PORT_ID(4), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port4 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(spine14_in_data), .in_incoming_valid(spine14_in_valid),
        .in_outgoing_data(P_in_data[4]), .in_outgoing_valid(P_in_valid[4]),
        .out_incoming_data(P_out_data[4]), .out_incoming_valid(P_out_valid[4]),
        .out_outgoing_data(spine14_out_data), .out_outgoing_valid(spine14_out_valid),
        .in_fifo_full(P_in_fifo_full[4]), .out_fifo_full(P_out_fifo_full[4])
    );

    // Port 5 (group1)
    spine_router_port #(.PORT_ID(5), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port5 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[5]), .in_incoming_valid(P_out_valid[5]),
        .in_outgoing_data(group211_in_data), .in_outgoing_valid(group211_in_valid),
        .out_incoming_data(group211_out_data), .out_incoming_valid(group211_out_valid),
        .out_outgoing_data(P_in_data[5]), .out_outgoing_valid(P_in_valid[5]),
        .in_fifo_full(P_in_fifo_full[5]), .out_fifo_full(P_out_fifo_full[5])
    );

    // Port 6 (group2)
    spine_router_port #(.PORT_ID(6), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port6 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[6]), .in_incoming_valid(P_out_valid[6]),
        .in_outgoing_data(group311_in_data), .in_outgoing_valid(group311_in_valid),
        .out_incoming_data(group311_out_data), .out_incoming_valid(group311_out_valid),
        .out_outgoing_data(P_in_data[6]), .out_outgoing_valid(P_in_valid[6]),
        .in_fifo_full(P_in_fifo_full[6]), .out_fifo_full(P_out_fifo_full[6])
    );

    // Port 7 (group3)
    spine_router_port #(.PORT_ID(7), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port7 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[7]), .in_incoming_valid(P_out_valid[7]),
        .in_outgoing_data(group411_in_data), .in_outgoing_valid(group411_in_valid),
        .out_incoming_data(group411_out_data), .out_incoming_valid(group411_out_valid),
        .out_outgoing_data(P_in_data[7]), .out_outgoing_valid(P_in_valid[7]),
        .in_fifo_full(P_in_fifo_full[7]), .out_fifo_full(P_out_fifo_full[7])
    );

    // Port 8 (group4)
    spine_router_port #(.PORT_ID(8), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port8 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[8]), .in_incoming_valid(P_out_valid[8]),
        .in_outgoing_data(group511_in_data), .in_outgoing_valid(group511_in_valid),
        .out_incoming_data(group511_out_data), .out_incoming_valid(group511_out_valid),
        .out_outgoing_data(P_in_data[8]), .out_outgoing_valid(P_in_valid[8]),
        .in_fifo_full(P_in_fifo_full[8]), .out_fifo_full(P_out_fifo_full[8])
    );

    // Port 9 (group5)
    spine_router_port #(.PORT_ID(9), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port9 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[9]), .in_incoming_valid(P_out_valid[9]),
        .in_outgoing_data(group611_in_data), .in_outgoing_valid(group611_in_valid),
        .out_incoming_data(group611_out_data), .out_incoming_valid(group611_out_valid),
        .out_outgoing_data(P_in_data[9]), .out_outgoing_valid(P_in_valid[9]),
        .in_fifo_full(P_in_fifo_full[9]), .out_fifo_full(P_out_fifo_full[9])
    );

    // Port 10 (group6)
    spine_router_port #(.PORT_ID(10), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port10 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[10]), .in_incoming_valid(P_out_valid[10]),
        .in_outgoing_data(group711_in_data), .in_outgoing_valid(group711_in_valid),
        .out_incoming_data(group711_out_data), .out_incoming_valid(group711_out_valid),
        .out_outgoing_data(P_in_data[10]), .out_outgoing_valid(P_in_valid[10]),
        .in_fifo_full(P_in_fifo_full[10]), .out_fifo_full(P_out_fifo_full[10])
    );

    // Port 11 (group7)
    spine_router_port #(.PORT_ID(11), .DWIDTH(DWIDTH), .FIFO_DEPTH(FIFO_DEPTH)) port11 (
        .clk(clk), .reset(reset), .dir_incoming(dir_local),
        .in_incoming_data(P_out_data[11]), .in_incoming_valid(P_out_valid[11]),
        .in_outgoing_data(group811_in_data), .in_outgoing_valid(group811_in_valid),
        .out_incoming_data(group811_out_data), .out_incoming_valid(group811_out_valid),
        .out_outgoing_data(P_in_data[11]), .out_outgoing_valid(P_in_valid[11]),
        .in_fifo_full(P_in_fifo_full[11]), .out_fifo_full(P_out_fifo_full[11])
    );

    // ==========================
    // FSM Instantiation
    // ==========================
    spine_router_fsm1 #(
        .GROUP_ID(4'b0001),
        .DWIDTH(DWIDTH),
        .NUM_PORTS(11)
    ) router_fsm (
        .clk(clk),
        .reset(reset),
        .port_in_data(P_in_data),
        .port_in_valid(P_in_valid),
        .port_out_data(P_out_data),
        .port_out_valid(P_out_valid),
        .port_in_fifo_full(P_in_fifo_full),
        .port_out_fifo_full(P_out_fifo_full),
        .rt_dest_addr(rt_dest_addr)
    );

endmodule