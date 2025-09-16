module leaf_routing_table #(
    parameter GROUP_ID = 4'b1000   // Leaf router's group ID
)(
    input  [5:0] dest_addr,        // {GroupID[3:0], LeafID[1:0]}
    input  [2:0] src_port,         // 001 = GPU, 010..101 = Spine ports
    output reg [2:0] out_port      // 001 = GPU, 010..101 = Spine ports
);

    wire [3:0] dest_group = dest_addr[5:2];

    always @(*) begin
        out_port = 3'b000; // default invalid

        if (src_port == 3'b001) begin
            // Case 1: packet from GPU → forward to spine based on dest_group
            case (dest_group)
                4'b0001: out_port = 3'b010; // Spine1
                4'b0010: out_port = 3'b011; // Spine2
                4'b0011: out_port = 3'b100; // Spine3
                4'b0100: out_port = 3'b101; // Spine4
                4'b0101: out_port = 3'b010; // wrap-around or custom mapping
                4'b0110: out_port = 3'b011;
                4'b0111: out_port = 3'b100;
                4'b1000: out_port = 3'b101; // own group still uses spine for routing
                default: out_port = 3'b010; // default spine
            endcase
        end
        else begin
            // Case 2: packet from any spine → forward to GPU
            out_port = 3'b001; // GPU
        end
    end
endmodule