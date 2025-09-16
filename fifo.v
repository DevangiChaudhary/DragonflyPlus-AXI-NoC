`timescale 1ns/1ps

module sync_fifo #(parameter DEPTH=8, DWIDTH=16)(
    input                rstn,   // Active low reset
    input                clk,
    input                wr_en,
    input                rd_en,
    input  [DWIDTH-1:0]  din,
    output reg [DWIDTH-1:0] dout,
    output               empty,
    output               full
);

  reg [$clog2(DEPTH):0] wptr;
  reg [$clog2(DEPTH):0] rptr;
  reg [DWIDTH-1:0] fifo [0:DEPTH-1];

  // Write
  always @(posedge clk) begin
    if (!rstn) begin
      wptr <= 0;
    end else if (wr_en && !full) begin
      fifo[wptr[$clog2(DEPTH)-1:0]] <= din;
      wptr <= wptr + 1;
    end
  end

  // Read
  always @(posedge clk) begin
    if (!rstn) begin
      rptr <= 0;
      dout <= 0;
    end else if (rd_en && !empty) begin
      dout <= fifo[rptr[$clog2(DEPTH)-1:0]];
      rptr <= rptr + 1;
    end
  end

  assign full  = ((wptr+1) == rptr);
  assign empty = (wptr == rptr);

endmodule