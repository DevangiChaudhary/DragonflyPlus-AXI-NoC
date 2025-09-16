`timescale 1ns/1ps

module spine_routing_table_grp1 #(
    parameter GROUP_ID = 4'b0001   // Group1
)(
    input  [5:0] dest_addr,     // {GroupID[3:0], LeafID[1:0]}
    output reg [3:0] out_port   // port number (0001..1011)
);

    wire [3:0] dest_group = dest_addr[5:2]; // 4 bits for 8 groups
    wire [1:0] dest_leaf  = dest_addr[1:0]; // 2 bits for 4 leafs

    always @(*) begin
        out_port = 4'b0000; // default invalid
        if (dest_group == GROUP_ID) begin
            // ---- local delivery to leafs (ports 0001–0100) ----
            case (dest_leaf)
                2'b00: out_port = 4'b0001; // Leaf1 (of Group8)
                2'b01: out_port = 4'b0010; // Leaf2
                2'b10: out_port = 4'b0011; // Leaf3
                2'b11: out_port = 4'b0100; // Leaf4
            endcase
        end
        else begin
            // ---- inter-group delivery via spine links (ports 0101–1011) ----
            case (dest_group)
                4'b0010: out_port = 4'b0101; // to Group2
                4'b0011: out_port = 4'b0110; // to Group3
                4'b0100: out_port = 4'b0111; // to Group4
                4'b0101: out_port = 4'b1000; // to Group5
                4'b0110: out_port = 4'b1001; // to Group6
                4'b0111: out_port = 4'b1010; // to Group7
                4'b1000: out_port = 4'b1011; // to Group8
                4'b1000: out_port = 4'b0000; // (self group, already handled above)
                default: out_port = 4'b0000; // invalid
            endcase
        end
    end
endmodule