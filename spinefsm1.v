`timescale 1ns/1ps

module spine_router_fsm1 #(
    parameter GROUP_ID = 4'b0001, //group 1
    parameter DWIDTH = 16,
    parameter NUM_PORTS = 11
)(
    input wire clk,
    input wire reset,
    
    // Input data from ports
    input [DWIDTH-1:0] port_in_data [1:11],
    input [1:11] port_in_valid,
    
    // Output data to ports
    output reg [DWIDTH-1:0] port_out_data [1:11],
    output reg [1:11] port_out_valid,
    
    // Buffer status from ports
    input [1:11] port_in_fifo_full,
    input [1:11] port_out_fifo_full,
    
    // Routing table interface
    output reg [5:0] rt_dest_addr
);

    // FSM States
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        DECODE = 3'b001,
        FORWARD = 3'b010,
        WAIT = 3'b011,
        DONE = 3'b100
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal Registers
    reg [3:0] current_input_port;
    reg [DWIDTH-1:0] current_packet;
    reg [5:0] dest_addr;
    reg [3:0] target_port;
    reg found_valid_input;
    
    // Routing table output
    wire [3:0] rt_out_port;
    
    // Input Port Scanning
    always @(*) begin
        found_valid_input = 1'b0;
        current_input_port = 4'b0;
        
        // Scan ports 1-11 for valid data
        for (int i = 1; i <= 11; i = i + 1) begin
            if (port_in_valid[i] && !found_valid_input) begin
                found_valid_input = 1'b1;
                current_input_port = i;
            end
        end
    end
    
    // FSM State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // FSM Next State Logic
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (found_valid_input) begin
                    next_state = DECODE;
                end
            end
            
            DECODE: begin
                next_state = FORWARD;
            end
            
            FORWARD: begin
                if (port_out_fifo_full[target_port]) begin
                    next_state = WAIT;
                end else begin
                    next_state = DONE;
                end
            end
            
            WAIT: begin
                if (!port_out_fifo_full[target_port]) begin
                    next_state = FORWARD;
                end
            end
            
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // FSM Output Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 1; i <= 11; i = i + 1) begin
                port_out_data[i] <= 0;
                port_out_valid[i] <= 0;
            end
            current_packet <= 0;
            dest_addr <= 0;
            target_port <= 0;
            rt_dest_addr <= 0;
        end else begin
            // Default outputs
            for (int i = 1; i <= 11; i = i + 1) begin
                port_out_valid[i] <= 0;
            end
            
            case (current_state)
                IDLE: begin
                    if (found_valid_input) begin
                        current_packet <= port_in_data[current_input_port];
                        $display("[FSM] IDLE: Captured packet %h from port %d", 
                                 port_in_data[current_input_port], current_input_port);
                    end
                end
                
                DECODE: begin
                    // Extract destination address from header (bits [15:10])
                    dest_addr <= current_packet[15:10];
                    rt_dest_addr <= current_packet[15:10];
                    $display("[FSM] DECODE: Packet=%h, Dest addr %b, target port %d", 
                             current_packet, current_packet[15:10], rt_out_port);
                end
                
                FORWARD: begin
                    if (!port_out_fifo_full[target_port]) begin
                        port_out_data[target_port] <= current_packet;
                        port_out_valid[target_port] <= 1'b1;
                        $display("[FSM] FORWARD: Sending packet %h to port %d", 
                                 current_packet, target_port);
                    end
                end
                
                WAIT: begin
                    $display("[FSM] WAIT: Port %d buffer full", target_port);
                end
                
                DONE: begin
                    $display("[FSM] DONE: Transfer complete to port %d", target_port);
                end
            endcase
            
            // Continuous assignment from routing table
            target_port <= rt_out_port;
        end
    end
    
    // Routing Table Instantiation
    spine_routing_table_grp1 #(
        .GROUP_ID(GROUP_ID)
    ) routing_table (
        .dest_addr(rt_dest_addr),
        .out_port(rt_out_port)
    );

endmodule