`timescale 1ns/1ps

module router_port #(
    parameter PORT_ID    = 0,
    parameter DWIDTH     = 8,
    parameter FIFO_DEPTH = 8
)(
    input                    clk,
    input                    reset,
    input                    dir_incoming,   // 1 = send (local→bus), 0 = receive (bus→local)

    // FIFO IN (local → bus)
    input      [DWIDTH-1:0]  in_incoming_data,   // data from local node
    input                    in_incoming_valid,  // valid from local node
    output reg [DWIDTH-1:0]  in_outgoing_data,   // data delivered to local node
    output reg               in_outgoing_valid,  // valid to local node

    // FIFO OUT (bus → local)
    input      [DWIDTH-1:0]  out_incoming_data,  // data driven onto bus
    input                    out_incoming_valid, // valid on bus
    output reg [DWIDTH-1:0]  out_outgoing_data,  // data arriving from bus
    output reg               out_outgoing_valid, // valid to bus

    // FIFO Status Outputs
    output wire              in_fifo_full,     // Input FIFO is full
    output wire              in_fifo_empty,    // Input FIFO is empty
    output wire              out_fifo_full,    // Output FIFO is full
    output wire              out_fifo_empty,   // Output FIFO is empty
    output wire              xbar_ready        // Ready signal to crossbar when data available
);

    // FIFO control signals
    reg  fifo_in_wr, fifo_in_rd;     // Input FIFO (local → bus)
    reg  fifo_out_wr, fifo_out_rd;   // Output FIFO (bus → local)

    reg  [DWIDTH-1:0] fifo_in_din, fifo_out_din;
    wire [DWIDTH-1:0] fifo_in_dout, fifo_out_dout;

    wire fifo_in_empty_int, fifo_in_full_int;
    wire fifo_out_empty_int, fifo_out_full_int;

    // ==========================
    // FIFO Instantiations
    // ==========================
    sync_fifo #(.DEPTH(FIFO_DEPTH), .DWIDTH(DWIDTH)) input_fifo (
        .rstn(!reset),
        .clk(clk),
        .wr_en(fifo_in_wr),
        .rd_en(fifo_in_rd),
        .din(fifo_in_din),
        .dout(fifo_in_dout),
        .empty(fifo_in_empty_int),
        .full(fifo_in_full_int)
    );

    sync_fifo #(.DEPTH(FIFO_DEPTH), .DWIDTH(DWIDTH)) output_fifo (
        .rstn(!reset),
        .clk(clk),
        .wr_en(fifo_out_wr),
        .rd_en(fifo_out_rd),
        .din(fifo_out_din),
        .dout(fifo_out_dout),
        .empty(fifo_out_empty_int),
        .full(fifo_out_full_int)
    );

    // Status outputs
    assign in_fifo_full  = fifo_in_full_int;
    assign in_fifo_empty = fifo_in_empty_int;
    assign out_fifo_full = fifo_out_full_int;
    assign out_fifo_empty= fifo_out_empty_int;
    // Expose readiness to crossbar for local→bus direction when data is available in input FIFO
    assign xbar_ready    = dir_incoming && !fifo_in_empty_int;

    // ==========================
    // Input Path (local → bus)
    // ==========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_in_wr        <= 1'b0;
            fifo_in_din       <= {DWIDTH{1'b0}};
            fifo_in_rd        <= 1'b0;
            in_outgoing_data  <= {DWIDTH{1'b0}};
            in_outgoing_valid <= 1'b0;
        end else begin
            // Write to input FIFO when external data is valid and FIFO not full
            fifo_in_wr  <= dir_incoming && in_incoming_valid && !fifo_in_full_int;
            fifo_in_din <= in_incoming_data;

            // Read from input FIFO when not empty
            fifo_in_rd <= dir_incoming && !fifo_in_empty_int;

            // Deliver to local node
            if (fifo_in_rd) begin
                in_outgoing_data  <= fifo_in_dout;
                in_outgoing_valid <= 1'b1;
            end else begin
                in_outgoing_valid <= 1'b0;
            end
        end
    end

    // ==========================
    // Output Path (bus → local)
    // ==========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_out_wr        <= 1'b0;
            fifo_out_din       <= {DWIDTH{1'b0}};
            fifo_out_rd        <= 1'b0;
            out_outgoing_data  <= {DWIDTH{1'b0}};
            out_outgoing_valid <= 1'b0;
        end else begin
            // Write to output FIFO when bus data is valid and FIFO not full
            fifo_out_wr  <= !dir_incoming && out_incoming_valid && !fifo_out_full_int;
            fifo_out_din <= out_incoming_data;

            // Read from output FIFO when not empty
            fifo_out_rd <= !dir_incoming && !fifo_out_empty_int;

            // Deliver to bus
            if (fifo_out_rd) begin
                out_outgoing_data  <= fifo_out_dout;
                out_outgoing_valid <= 1'b1;
            end else begin
                out_outgoing_valid <= 1'b0;
            end
        end
    end

    // ==========================
    // Debug Monitor (Optional)
    // ==========================
    `ifdef DEBUG_ROUTER_PORT
    always @(posedge clk) begin
        if (!reset) begin
            if (fifo_in_wr) begin
                $display("[%0t] Port%0d INPUT_FIFO WRITE: data=%h, full=%b",
                         $time, PORT_ID, fifo_in_din, fifo_in_full_int);
            end
            if (fifo_out_wr) begin
                $display("[%0t] Port%0d OUTPUT_FIFO WRITE: data=%h, full=%b",
                         $time, PORT_ID, fifo_out_din, fifo_out_full_int);
            end
            if (fifo_in_full_int || fifo_out_full_int) begin
                $display("[%0t] Port%0d BACKPRESSURE: in_full=%b, out_full=%b",
                         $time, PORT_ID, fifo_in_full_int, fifo_out_full_int);
            end
        end
    end
    `endif

endmodule
