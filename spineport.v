`timescale 1ns/1ps

module spine_router_port #(
    parameter PORT_ID    = 0,
    parameter DWIDTH     = 8,
    parameter FIFO_DEPTH = 8
)(
    input                    clk,
    input                    reset,
    input                    dir_incoming,
    
    // FIFO IN (local → bus)
    input      [DWIDTH-1:0]  in_incoming_data,
    input                    in_incoming_valid,
    output reg [DWIDTH-1:0]  in_outgoing_data,
    output reg               in_outgoing_valid,

    // FIFO OUT (bus → local)
    input      [DWIDTH-1:0]  out_incoming_data,
    input                    out_incoming_valid,
    output reg [DWIDTH-1:0]  out_outgoing_data,
    output reg               out_outgoing_valid,

    // Backpressure flags
    output wire              in_fifo_full,
    output wire              out_fifo_full
);

    // FIFO signals
    reg  fifo_in_wr, fifo_in_rd;
    reg  fifo_out_wr, fifo_out_rd;
    reg  [DWIDTH-1:0] fifo_in_din, fifo_out_din;
    wire [DWIDTH-1:0] fifo_in_dout, fifo_out_dout;
    wire fifo_in_empty, fifo_out_empty;

    // FIFO Instantiations (same as before)
    sync_fifo #(.DEPTH(FIFO_DEPTH), .DWIDTH(DWIDTH)) fifo_in (
        .rstn(!reset),
        .clk(clk),
        .wr_en(fifo_in_wr),
        .rd_en(fifo_in_rd),
        .din(fifo_in_din),
        .dout(fifo_in_dout),
        .empty(fifo_in_empty),
        .full(in_fifo_full)
    );

    sync_fifo #(.DEPTH(FIFO_DEPTH), .DWIDTH(DWIDTH)) fifo_out (
        .rstn(!reset),
        .clk(clk),
        .wr_en(fifo_out_wr),
        .rd_en(fifo_out_rd),
        .din(fifo_out_din),
        .dout(fifo_out_dout),
        .empty(fifo_out_empty),
        .full(out_fifo_full)
    );

    // FIXED FIFO Control Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_in_wr  <= 0; fifo_in_rd  <= 0; fifo_in_din  <= 0;
            fifo_out_wr <= 0; fifo_out_rd <= 0; fifo_out_din <= 0;
            in_outgoing_data  <= 0; in_outgoing_valid  <= 0;
            out_outgoing_data <= 0; out_outgoing_valid <= 0;
        end else begin
            // --- FIFO write enables ---
            fifo_in_wr  <= dir_incoming && in_incoming_valid && !in_fifo_full;
            fifo_in_din <= in_incoming_data;
            
            fifo_out_wr  <= !dir_incoming && out_incoming_valid && !out_fifo_full;
            fifo_out_din <= out_incoming_data;
            
            // --- FIFO read enables - FIXED ---
            // Read from FIFO if not empty, or if we're writing to empty FIFO (bypass)
            fifo_in_rd  <= dir_incoming && (!fifo_in_empty || (in_incoming_valid && fifo_in_empty));
            fifo_out_rd <= !dir_incoming && (!fifo_out_empty || (out_incoming_valid && fifo_out_empty));
            
            // --- Outputs ---
            if (fifo_in_rd) begin
                in_outgoing_data  <= fifo_in_empty ? in_incoming_data : fifo_in_dout;
                in_outgoing_valid <= 1'b1;
            end else begin
                in_outgoing_valid <= 1'b0;
            end
            
            if (fifo_out_rd) begin
                out_outgoing_data  <= fifo_out_empty ? out_incoming_data : fifo_out_dout;
                out_outgoing_valid <= 1'b1;
            end else begin
                out_outgoing_valid <= 1'b0;
            end
        end
    end
endmodule