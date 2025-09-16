`timescale 1ns/1ps

module bidirectional_fsm_crossbar1 #(
    parameter DWIDTH = 16,
    parameter GROUP_ID = 4'b0001  // Router's group ID for routing table
)(
    input  wire clk,
    input  wire reset,
    input  wire arb_enable,    // Enable arbitration mode
    
    // GPU Port Interface
    input  wire [DWIDTH-1:0] gpu_incoming_data,
    input  wire               gpu_incoming_valid,
    input  wire               gpu_ready,     
    input  wire [5:0]         gpu_dest_addr, // Destination address from GPU source
    output reg  [DWIDTH-1:0] gpu_outgoing_data,
    output reg                gpu_outgoing_valid,
    
    // Spine Port Interfaces
    input  wire [DWIDTH-1:0] spine1_out_data,
    input  wire               spine1_out_valid,
    input  wire               spine1_ready,
    input  wire [5:0]         spine1_dest_addr,
    output reg  [DWIDTH-1:0] spine1_in_data,
    output reg                spine1_in_valid,
    
    input  wire [DWIDTH-1:0] spine2_out_data,
    input  wire               spine2_out_valid,
    input  wire               spine2_ready,
    input  wire [5:0]         spine2_dest_addr,
    output reg  [DWIDTH-1:0] spine2_in_data,
    output reg                spine2_in_valid,
    
    input  wire [DWIDTH-1:0] spine3_out_data,
    input  wire               spine3_out_valid,
    input  wire               spine3_ready,
    input  wire [5:0]         spine3_dest_addr,
    output reg  [DWIDTH-1:0] spine3_in_data,
    output reg                spine3_in_valid,
    
    input  wire [DWIDTH-1:0] spine4_out_data,
    input  wire               spine4_out_valid,
    input  wire               spine4_ready,
    input  wire [5:0]         spine4_dest_addr,
    output reg  [DWIDTH-1:0] spine4_in_data,
    output reg                spine4_in_valid,
    
    // Status and Control
    output wire busy,
    output wire [2:0] current_grant,
    output wire [1:0] direction
);

    // FSM States
    localparam IDLE = 4'b0000;
    localparam GPU_TO_SPINE1 = 4'b0001;
    localparam GPU_TO_SPINE2 = 4'b0010;
    localparam GPU_TO_SPINE3 = 4'b0011;
    localparam GPU_TO_SPINE4 = 4'b0100;
    localparam SPINE1_TO_GPU = 4'b0101;
    localparam SPINE2_TO_GPU = 4'b0110;
    localparam SPINE3_TO_GPU = 4'b0111;
    localparam SPINE4_TO_GPU = 4'b1000;
    
    // State and control registers
    reg [3:0] current_state, next_state;
    reg [2:0] round_robin_ptr;      // For arbitration
    reg [DWIDTH-1:0] data_reg;      // Data register
    reg [5:0] addr_reg;             // Address register (for GPU sourced routing)
    reg [2:0] current_grant_reg;
    
    // Pending request latches and captured payloads
    reg pending_gpu, pending_spine1, pending_spine2, pending_spine3, pending_spine4;
    reg [DWIDTH-1:0] gpu_data_lat, spine1_data_lat, spine2_data_lat, spine3_data_lat, spine4_data_lat;
    reg [5:0]        gpu_addr_lat;
    
    // Status outputs
    assign busy = (current_state != IDLE);
    assign direction = (current_state >= SPINE1_TO_GPU) ? 2'b10 : 
                       (current_state >= GPU_TO_SPINE1 && current_state <= GPU_TO_SPINE4) ? 2'b01 : 
                       2'b00;
    assign current_grant = current_grant_reg;

    // ==========================
    // Request Detection (rising-edge qualify to avoid re-servicing held valids)
    // ==========================
    reg gpu_incoming_valid_d;
    reg spine1_out_valid_d;
    reg spine2_out_valid_d;
    reg spine3_out_valid_d;
    reg spine4_out_valid_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            gpu_incoming_valid_d  <= 1'b0;
            spine1_out_valid_d   <= 1'b0;
            spine2_out_valid_d   <= 1'b0;
            spine3_out_valid_d   <= 1'b0;
            spine4_out_valid_d   <= 1'b0;
        end else begin
            gpu_incoming_valid_d  <= gpu_incoming_valid;
            spine1_out_valid_d   <= spine1_out_valid;
            spine2_out_valid_d   <= spine2_out_valid;
            spine3_out_valid_d   <= spine3_out_valid;
            spine4_out_valid_d   <= spine4_out_valid;
        end
    end

    wire gpu_request    = gpu_incoming_valid  && !gpu_incoming_valid_d  && gpu_ready;
    wire spine1_request = spine1_out_valid   && !spine1_out_valid_d   && spine1_ready;
    wire spine2_request = spine2_out_valid   && !spine2_out_valid_d   && spine2_ready;
    wire spine3_request = spine3_out_valid   && !spine3_out_valid_d   && spine3_ready;
    wire spine4_request = spine4_out_valid   && !spine4_out_valid_d   && spine4_ready;
    
    wire [4:0] request_vector = {spine4_request, spine3_request, spine2_request, spine1_request, gpu_request};
    
    // ==========================
    // FSM State Machine
    // ==========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            round_robin_ptr <= 3'b000;
            current_grant_reg <= 3'b000;
            data_reg <= {DWIDTH{1'b0}};
            addr_reg <= 6'b000000;
            // Clear pendings
            pending_gpu <= 1'b0; pending_spine1 <= 1'b0; pending_spine2 <= 1'b0; pending_spine3 <= 1'b0; pending_spine4 <= 1'b0;
            gpu_data_lat <= {DWIDTH{1'b0}}; spine1_data_lat <= {DWIDTH{1'b0}}; spine2_data_lat <= {DWIDTH{1'b0}}; spine3_data_lat <= {DWIDTH{1'b0}}; spine4_data_lat <= {DWIDTH{1'b0}};
            gpu_addr_lat <= 6'b0;
        end else begin
            current_state <= next_state;
            // Capture new incoming requests (sticky until served)
            if (gpu_request) begin
                pending_gpu <= 1'b1;
                gpu_data_lat <= gpu_incoming_data;
                gpu_addr_lat <= gpu_dest_addr;
            end
            if (spine1_request) begin
                pending_spine1 <= 1'b1;
                spine1_data_lat <= spine1_out_data;
            end
            if (spine2_request) begin
                pending_spine2 <= 1'b1;
                spine2_data_lat <= spine2_out_data;
            end
            if (spine3_request) begin
                pending_spine3 <= 1'b1;
                spine3_data_lat <= spine3_out_data;
            end
            if (spine4_request) begin
                pending_spine4 <= 1'b1;
                spine4_data_lat <= spine4_out_data;
            end
            
            // Clear corresponding pending when we leave IDLE into a service state
            if (current_state == IDLE) begin
                case (next_state)
                    GPU_TO_SPINE1, GPU_TO_SPINE2, GPU_TO_SPINE3, GPU_TO_SPINE4: pending_gpu <= 1'b0;
                    SPINE1_TO_GPU: pending_spine1 <= 1'b0;
                    SPINE2_TO_GPU: pending_spine2 <= 1'b0;
                    SPINE3_TO_GPU: pending_spine3 <= 1'b0;
                    SPINE4_TO_GPU: pending_spine4 <= 1'b0;
                    default: ;
                endcase
            end
        end
    end
    
    // ==========================
    // FSM Next State Logic
    // ==========================
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (pending_gpu || pending_spine1 || pending_spine2 || pending_spine3 || pending_spine4) begin
                    if (arb_enable) begin
                        // Round-robin arbitration - Check each port in sequence
                        case (round_robin_ptr)
                            3'b000: begin // Check GPU first
                                if (pending_gpu) begin
                                    case (gpu_addr_lat[5:2])
                                        4'b0001: next_state = GPU_TO_SPINE1;
                                        4'b0010: next_state = GPU_TO_SPINE2;
                                        4'b0011: next_state = GPU_TO_SPINE3;
                                        4'b0100: next_state = GPU_TO_SPINE4;
                                        default: next_state = GPU_TO_SPINE1;
                                    endcase
                                end else if (pending_spine1) next_state = SPINE1_TO_GPU;
                                else if (pending_spine2) next_state = SPINE2_TO_GPU;
                                else if (pending_spine3) next_state = SPINE3_TO_GPU;
                                else if (pending_spine4) next_state = SPINE4_TO_GPU;
                            end
                            3'b001: begin
                                if (pending_spine1) next_state = SPINE1_TO_GPU;
                                else if (pending_spine2) next_state = SPINE2_TO_GPU;
                                else if (pending_spine3) next_state = SPINE3_TO_GPU;
                                else if (pending_spine4) next_state = SPINE4_TO_GPU;
                                else if (pending_gpu) begin
                                    case (gpu_addr_lat[5:2])
                                        4'b0001: next_state = GPU_TO_SPINE1;
                                        4'b0010: next_state = GPU_TO_SPINE2;
                                        4'b0011: next_state = GPU_TO_SPINE3;
                                        4'b0100: next_state = GPU_TO_SPINE4;
                                        default: next_state = GPU_TO_SPINE1;
                                    endcase
                                end
                            end
                            3'b010: begin
                                if (pending_spine2) next_state = SPINE2_TO_GPU;
                                else if (pending_spine3) next_state = SPINE3_TO_GPU;
                                else if (pending_spine4) next_state = SPINE4_TO_GPU;
                                else if (pending_gpu) begin
                                    case (gpu_addr_lat[5:2])
                                        4'b0001: next_state = GPU_TO_SPINE1;
                                        4'b0010: next_state = GPU_TO_SPINE2;
                                        4'b0011: next_state = GPU_TO_SPINE3;
                                        4'b0100: next_state = GPU_TO_SPINE4;
                                        default: next_state = GPU_TO_SPINE1;
                                    endcase
                                end else if (pending_spine1) next_state = SPINE1_TO_GPU;
                            end
                            3'b011: begin
                                if (pending_spine3) next_state = SPINE3_TO_GPU;
                                else if (pending_spine4) next_state = SPINE4_TO_GPU;
                                else if (pending_gpu) begin
                                    case (gpu_addr_lat[5:2])
                                        4'b0001: next_state = GPU_TO_SPINE1;
                                        4'b0010: next_state = GPU_TO_SPINE2;
                                        4'b0011: next_state = GPU_TO_SPINE3;
                                        4'b0100: next_state = GPU_TO_SPINE4;
                                        default: next_state = GPU_TO_SPINE1;
                                    endcase
                                end else if (pending_spine1) next_state = SPINE1_TO_GPU;
                                else if (pending_spine2) next_state = SPINE2_TO_GPU;
                            end
                            3'b100: begin
                                if (pending_spine4) next_state = SPINE4_TO_GPU;
                                else if (pending_gpu) begin
                                    case (gpu_addr_lat[5:2])
                                        4'b0001: next_state = GPU_TO_SPINE1;
                                        4'b0010: next_state = GPU_TO_SPINE2;
                                        4'b0011: next_state = GPU_TO_SPINE3;
                                        4'b0100: next_state = GPU_TO_SPINE4;
                                        default: next_state = GPU_TO_SPINE1;
                                    endcase
                                end else if (pending_spine1) next_state = SPINE1_TO_GPU;
                                else if (pending_spine2) next_state = SPINE2_TO_GPU;
                                else if (pending_spine3) next_state = SPINE3_TO_GPU;
                            end
                            default: next_state = IDLE;
                        endcase
                    end else begin
                        // Fixed priority: GPU > Spine1 > Spine2 > Spine3 > Spine4
                        if (pending_gpu) begin
                            case (gpu_addr_lat[5:2])
                                4'b0001: next_state = GPU_TO_SPINE1;
                                4'b0010: next_state = GPU_TO_SPINE2;
                                4'b0011: next_state = GPU_TO_SPINE3;
                                4'b0100: next_state = GPU_TO_SPINE4;
                                default: next_state = GPU_TO_SPINE1;
                            endcase
                        end else if (pending_spine1) next_state = SPINE1_TO_GPU;
                        else if (pending_spine2) next_state = SPINE2_TO_GPU;
                        else if (pending_spine3) next_state = SPINE3_TO_GPU;
                        else if (pending_spine4) next_state = SPINE4_TO_GPU;
                    end
                end
            end
            
            GPU_TO_SPINE1, GPU_TO_SPINE2, GPU_TO_SPINE3, GPU_TO_SPINE4,
            SPINE1_TO_GPU, SPINE2_TO_GPU, SPINE3_TO_GPU, SPINE4_TO_GPU: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // ==========================
    // FSM Output Logic  
    // ==========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            gpu_outgoing_data <= {DWIDTH{1'b0}};
            gpu_outgoing_valid <= 1'b0;
            spine1_in_data <= {DWIDTH{1'b0}};
            spine1_in_valid <= 1'b0;
            spine2_in_data <= {DWIDTH{1'b0}};
            spine2_in_valid <= 1'b0;
            spine3_in_data <= {DWIDTH{1'b0}};
            spine3_in_valid <= 1'b0;
            spine4_in_data <= {DWIDTH{1'b0}};
            spine4_in_valid <= 1'b0;
            data_reg <= {DWIDTH{1'b0}};
            addr_reg <= 6'b0;
            current_grant_reg <= 3'b0;
        end else begin
            // Default outputs
            gpu_outgoing_valid <= 1'b0;
            spine1_in_valid <= 1'b0;
            spine2_in_valid <= 1'b0;
            spine3_in_valid <= 1'b0;
            spine4_in_valid <= 1'b0;
            
            case (current_state)
                IDLE: begin
                    if (pending_gpu) begin
                        data_reg <= gpu_data_lat;
                        addr_reg <= gpu_addr_lat;
                        current_grant_reg <= 3'b001;
                    end else if (pending_spine1) begin
                        data_reg <= spine1_data_lat;
                        current_grant_reg <= 3'b010;
                    end else if (pending_spine2) begin
                        data_reg <= spine2_data_lat;
                        current_grant_reg <= 3'b011;
                    end else if (pending_spine3) begin
                        data_reg <= spine3_data_lat;
                        current_grant_reg <= 3'b100;
                    end else if (pending_spine4) begin
                        data_reg <= spine4_data_lat;
                        current_grant_reg <= 3'b101;
                    end
                end
                
                GPU_TO_SPINE1: begin
                    spine1_in_data <= data_reg;
                    spine1_in_valid <= 1'b1;
                end
                GPU_TO_SPINE2: begin
                    spine2_in_data <= data_reg;
                    spine2_in_valid <= 1'b1;
                end
                GPU_TO_SPINE3: begin
                    spine3_in_data <= data_reg;
                    spine3_in_valid <= 1'b1;
                end
                GPU_TO_SPINE4: begin
                    spine4_in_data <= data_reg;
                    spine4_in_valid <= 1'b1;
                end
                
                SPINE1_TO_GPU, SPINE2_TO_GPU, SPINE3_TO_GPU, SPINE4_TO_GPU: begin
                    gpu_outgoing_data <= data_reg;
                    gpu_outgoing_valid <= 1'b1;
                end
                
                default: ;
            endcase
        end
    end
    
    // ==========================
    // Round-robin Pointer Update
    // ==========================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            round_robin_ptr <= 3'b000;
        end else if (current_state != IDLE && next_state == IDLE && arb_enable) begin
            round_robin_ptr <= (round_robin_ptr == 3'b100) ? 3'b000 : round_robin_ptr + 1;
        end
    end

	// ==========================
// Debug Output (Optional)
// ==========================
always @(posedge clk) begin
    if (!reset && current_state != IDLE) begin
        case (current_state)
            GPU_TO_SPINE1: $display("Time: %0t | CROSSBAR: GPU->Spine1, Data=%h", $time, data_reg);
            GPU_TO_SPINE2: $display("Time: %0t | CROSSBAR: GPU->Spine2, Data=%h", $time, data_reg);
            GPU_TO_SPINE3: $display("Time: %0t | CROSSBAR: GPU->Spine3, Data=%h", $time, data_reg);
            GPU_TO_SPINE4: $display("Time: %0t | CROSSBAR: GPU->Spine4, Data=%h", $time, data_reg);
            SPINE1_TO_GPU: $display("Time: %0t | CROSSBAR: Spine1->GPU, Data=%h", $time, data_reg);
            SPINE2_TO_GPU: $display("Time: %0t | CROSSBAR: Spine2->GPU, Data=%h", $time, data_reg);
            SPINE3_TO_GPU: $display("Time: %0t | CROSSBAR: Spine3->GPU, Data=%h", $time, data_reg);
            SPINE4_TO_GPU: $display("Time: %0t | CROSSBAR: Spine4->GPU, Data=%h", $time, data_reg);
        endcase
    end
end
endmodule