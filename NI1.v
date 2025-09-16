`timescale 1ns/1ps
module ni1 #(
    parameter GPU_ID = 1,
    parameter DATA_W = 16,
    parameter HEADER_W = 6,   // 4-bit Group + 2-bit Leaf
    parameter FIFO_DEPTH = 8
)(
    input  wire clk,
    input  wire reset,

    // GPU side
    input  wire [DATA_W-1:0] gpu_data_in,
    input  wire gpu_valid_in,
    output wire gpu_ready_out,
    output reg  [DATA_W-1:0] gpu_data_out,
    output reg  gpu_valid_out,
    input  wire gpu_ready_in, 

    // Router side
    output reg  [DATA_W-1:0] router_data_out,
    output reg  router_valid_out,
    input  wire router_ready_in,
    input  wire [DATA_W-1:0] router_data_in,
    input  wire router_valid_in
);

    // ---------------- Lookup Table ----------------
    function [HEADER_W-1:0] get_dest_addr;
        input [5:0] dest_gpu_id;
        begin
            case (dest_gpu_id)
                1:  get_dest_addr = 6'b000100;
                2:  get_dest_addr = 6'b000101;
                3:  get_dest_addr = 6'b000110;
                4:  get_dest_addr = 6'b000111;
                5:  get_dest_addr = 6'b001000;
                6:  get_dest_addr = 6'b001001;
                7:  get_dest_addr = 6'b001010;
                8:  get_dest_addr = 6'b001011;
                9:  get_dest_addr = 6'b001100;
                10: get_dest_addr = 6'b001101;
                11: get_dest_addr = 6'b001110;
                12: get_dest_addr = 6'b001111;
                13: get_dest_addr = 6'b010000;
                14: get_dest_addr = 6'b010001;
                15: get_dest_addr = 6'b010010;
                16: get_dest_addr = 6'b010011;
                17: get_dest_addr = 6'b010100;
                18: get_dest_addr = 6'b010101;
                19: get_dest_addr = 6'b010110;
                20: get_dest_addr = 6'b010111;
                21: get_dest_addr = 6'b011000;
                22: get_dest_addr = 6'b011001;
                23: get_dest_addr = 6'b011010;
                24: get_dest_addr = 6'b011011;
                25: get_dest_addr = 6'b011100;
                26: get_dest_addr = 6'b011101;
                27: get_dest_addr = 6'b011110;
                28: get_dest_addr = 6'b011111;
                29: get_dest_addr = 6'b100000;
                30: get_dest_addr = 6'b100001;
                31: get_dest_addr = 6'b100010;
                32: get_dest_addr = 6'b100011;
                default: get_dest_addr = 6'b000000;
            endcase
        end
    endfunction

    // ---------------- Reverse Lookup Table ----------------
    function [5:0] get_gpu_id_from_addr;
        input [HEADER_W-1:0] routing_addr;
        begin
            case (routing_addr)
                6'b000100: get_gpu_id_from_addr = 1;
                6'b000101: get_gpu_id_from_addr = 2;
                6'b000110: get_gpu_id_from_addr = 3;
                6'b000111: get_gpu_id_from_addr = 4;
                6'b001000: get_gpu_id_from_addr = 5;
                6'b001001: get_gpu_id_from_addr = 6;
                6'b001010: get_gpu_id_from_addr = 7;
                6'b001011: get_gpu_id_from_addr = 8;
                6'b001100: get_gpu_id_from_addr = 9;
                6'b001101: get_gpu_id_from_addr = 10;
                6'b001110: get_gpu_id_from_addr = 11;
                6'b001111: get_gpu_id_from_addr = 12;
                6'b010000: get_gpu_id_from_addr = 13;
                6'b010001: get_gpu_id_from_addr = 14;
                6'b010010: get_gpu_id_from_addr = 15;
                6'b010011: get_gpu_id_from_addr = 16;
                6'b010100: get_gpu_id_from_addr = 17;
                6'b010101: get_gpu_id_from_addr = 18;
                6'b010110: get_gpu_id_from_addr = 19;
                6'b010111: get_gpu_id_from_addr = 20;
                6'b011000: get_gpu_id_from_addr = 21;
                6'b011001: get_gpu_id_from_addr = 22;
                6'b011010: get_gpu_id_from_addr = 23;
                6'b011011: get_gpu_id_from_addr = 24;
                6'b011100: get_gpu_id_from_addr = 25;
                6'b011101: get_gpu_id_from_addr = 26;
                6'b011110: get_gpu_id_from_addr = 27;
                6'b011111: get_gpu_id_from_addr = 28;
                6'b100000: get_gpu_id_from_addr = 29;
                6'b100001: get_gpu_id_from_addr = 30;
                6'b100010: get_gpu_id_from_addr = 31;
                6'b100011: get_gpu_id_from_addr = 32;
                default:   get_gpu_id_from_addr = 0;
            endcase
        end
    endfunction

    // ---------------- GPU→Router FIFO ----------------
    reg [DATA_W-1:0] fifo_gpu_to_router [0:FIFO_DEPTH-1];
    reg [1:0] fifo_wr_ptr, fifo_rd_ptr;
    reg [2:0] fifo_count;

    wire fifo_full = (fifo_count == FIFO_DEPTH);
    wire fifo_empty = (fifo_count == 0);

    assign gpu_ready_out = !fifo_full;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_wr_ptr <= 0;
            fifo_rd_ptr <= 0;
            fifo_count <= 0;
            router_data_out <= 0;
            router_valid_out <= 0;
        end else begin
            // Write from GPU to FIFO
            if (gpu_valid_in && !fifo_full) begin
                // Extract destination GPU ID from incoming data (upper 6 bits)
                fifo_gpu_to_router[fifo_wr_ptr] <= {get_dest_addr(gpu_data_in[15:10]), gpu_data_in[9:0]};
                fifo_wr_ptr <= fifo_wr_ptr + 1;
                fifo_count <= fifo_count + 1;
            end

            // Read from FIFO to Router
            if (!fifo_empty && router_ready_in) begin
                router_data_out <= fifo_gpu_to_router[fifo_rd_ptr];
                router_valid_out <= 1;
                fifo_rd_ptr <= fifo_rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end else begin
                router_valid_out <= 0;
            end
        end
    end

    // ---------------- Router→GPU FIFO ----------------
    reg [DATA_W-1:0] fifo_router_to_gpu [0:FIFO_DEPTH-1];
    reg [1:0] fifo_wr_ptr_r2g, fifo_rd_ptr_r2g;
    reg [2:0] fifo_count_r2g;

    wire fifo_full_r2g = (fifo_count_r2g == FIFO_DEPTH);
    wire fifo_empty_r2g = (fifo_count_r2g == 0);

    // Pre-calculate this GPU's address for comparison
    wire [HEADER_W-1:0] this_gpu_addr = get_dest_addr(GPU_ID);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fifo_wr_ptr_r2g <= 0;
            fifo_rd_ptr_r2g <= 0;
            fifo_count_r2g <= 0;
            gpu_valid_out <= 0;
            gpu_data_out <= 0;
        end else begin
            // Write from Router to FIFO
            if (router_valid_in && !fifo_full_r2g) begin
                // Check if packet is for this GPU (compare header with our GPU's address)
                if (router_data_in[15:10] == this_gpu_addr) begin
                    // Convert routing header back to GPU ID for the GPU
                    fifo_router_to_gpu[fifo_wr_ptr_r2g] <= {get_gpu_id_from_addr(router_data_in[15:10]), router_data_in[9:0]};
                    fifo_wr_ptr_r2g <= fifo_wr_ptr_r2g + 1;
                    fifo_count_r2g <= fifo_count_r2g + 1;
                end
            end

            // Read FIFO to GPU
            if (!fifo_empty_r2g && gpu_ready_in) begin
                gpu_data_out <= fifo_router_to_gpu[fifo_rd_ptr_r2g];
                gpu_valid_out <= 1;
                fifo_rd_ptr_r2g <= fifo_rd_ptr_r2g + 1;
                fifo_count_r2g <= fifo_count_r2g - 1;
            end else begin
                gpu_valid_out <= 0;
            end
        end
    end

endmodule