`timescale 1ns/1ps
module axi_gpu1 #(
    parameter GPU_ID = 1,           // GPU identifier
    parameter ADDR_W = 32,
    parameter DATA_W = 64,
    parameter ID_W   = 4,
    parameter MEM_BYTES = 8192,     // 8192 bytes to handle 0x2000 addresses
    parameter INIT_WRITE_ADDR = 32'h00001000,
    parameter INIT_WRITE_DATA = 64'hFACE_CAFE_DEAD_BEEF,
    parameter INIT_READ_ADDR  = 32'h00001000
)(
    input  wire ACLK,
    input  wire ARESETn,

    // ******** Network Interface ********
    output reg  [15:0]           net_data_out,    // 16-bit for NI
    output reg                   net_valid_out,
    input  wire                  net_ready_in,
    input  wire [15:0]           net_data_in,
    input  wire                  net_valid_in,
    output reg                   net_ready_out,

    // ******** AXI Master Interface ********
    // Write Address Channel
    output reg  [ID_W-1:0]      M_AWID,
    output reg  [ADDR_W-1:0]    M_AWADDR,
    output reg  [7:0]           M_AWLEN,
    output reg  [2:0]           M_AWSIZE,
    output reg  [1:0]           M_AWBURST,
    output reg                  M_AWVALID,
    input  wire                 M_AWREADY,

    // Write Data Channel
    output reg  [DATA_W-1:0]    M_WDATA,
    output reg  [(DATA_W/8)-1:0] M_WSTRB,
    output reg                  M_WLAST,
    output reg                  M_WVALID,
    input  wire                 M_WREADY,

    // Write Response Channel
    input  wire [ID_W-1:0]      M_BID,
    input  wire [1:0]           M_BRESP,
    input  wire                 M_BVALID,
    output reg                  M_BREADY,

    // Read Address Channel
    output reg  [ID_W-1:0]      M_ARID,
    output reg  [ADDR_W-1:0]    M_ARADDR,
    output reg  [7:0]           M_ARLEN,
    output reg  [2:0]           M_ARSIZE,
    output reg  [1:0]           M_ARBURST,
    output reg                  M_ARVALID,
    input  wire                 M_ARREADY,

    // Read Data Channel
    input  wire [ID_W-1:0]      M_RID,
    input  wire [DATA_W-1:0]    M_RDATA,
    input  wire [1:0]           M_RRESP,
    input  wire                 M_RLAST,
    input  wire                 M_RVALID,
    output reg                  M_RREADY,

    // ******** AXI Slave Interface ********
    // Write Address Channel
    input  wire [ID_W-1:0]      S_AWID,
    input  wire [ADDR_W-1:0]    S_AWADDR,
    input  wire [7:0]           S_AWLEN,
    input  wire [2:0]           S_AWSIZE,
    input  wire [1:0]           S_AWBURST,
    input  wire                 S_AWVALID,
    output reg                  S_AWREADY,

    // Write Data Channel
    input  wire [DATA_W-1:0]    S_WDATA,
    input  wire [(DATA_W/8)-1:0] S_WSTRB,
    input  wire                 S_WLAST,
    input  wire                 S_WVALID,
    output reg                  S_WREADY,

    // Write Response Channel
    output reg [ID_W-1:0]       S_BID,
    output reg [1:0]            S_BRESP,
    output reg                  S_BVALID,
    input  wire                 S_BREADY,

    // Read Address Channel
    input  wire [ID_W-1:0]      S_ARID,
    input  wire [ADDR_W-1:0]    S_ARADDR,
    input  wire [7:0]           S_ARLEN,
    input  wire [2:0]           S_ARSIZE,
    input  wire [1:0]           S_ARBURST,
    input  wire                 S_ARVALID,
    output reg                  S_ARREADY,

    // Read Data Channel
    output reg [ID_W-1:0]       S_RID,
    output reg [DATA_W-1:0]     S_RDATA,
    output reg [1:0]            S_RRESP,
    output reg                  S_RLAST,
    output reg                  S_RVALID,
    input  wire                 S_RREADY
);

    // ------------------ Local Memory ------------------
    reg [DATA_W-1:0] mem [0:MEM_BYTES/8-1];

    // ******** Memory Initialization ********
    integer i;
    initial begin
        for (i = 0; i < MEM_BYTES/8; i = i + 1) begin
            mem[i] = {DATA_W{1'b0}};  // Initialize memory to zero
        end
    end

    // ------------------ Network Interface Logic ------------------
    reg [2:0] net_state;
    localparam NET_IDLE = 0, NET_SEND = 1, NET_RECV = 2;
    
    reg [15:0] tx_data;
    reg tx_valid;
    wire tx_ready = net_ready_in;
    
    // Network interface control registers
    reg [5:0] net_dest_gpu;
    reg [9:0] net_payload;
    reg net_send_req;
    
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            net_state <= NET_IDLE;
            net_data_out <= 0;
            net_valid_out <= 0;
            net_ready_out <= 1;
            tx_data <= 0;
            tx_valid <= 0;
            net_send_req <= 0;
        end else begin
            case (net_state)
                NET_IDLE: begin
                    net_valid_out <= 0;
                    
                    // Send data if requested
                    if (net_send_req) begin
                        tx_data <= {net_dest_gpu, net_payload};
                        tx_valid <= 1;
                        net_state <= NET_SEND;
                        net_send_req <= 0;
                    end
                    // Receive data if available
                    else if (net_valid_in) begin
                        // Check if data is for this GPU (destination ID in upper 6 bits)
                        if (net_data_in[15:10] == GPU_ID) begin
                            $display("[%0t] GPU %0d received data: %h", $time, GPU_ID, net_data_in[9:0]);
                            net_ready_out <= 0; // Acknowledge reception
                            net_state <= NET_RECV;
                        end
                    end
                end
                
                NET_SEND: begin
                    if (tx_ready && tx_valid) begin
                        net_data_out <= tx_data;
                        net_valid_out <= 1;
                        tx_valid <= 0;
                        net_state <= NET_IDLE;
                    end
                end
                
                NET_RECV: begin
                    net_ready_out <= 1;
                    net_state <= NET_IDLE;
                end
            endcase
        end
    end

    // ------------------ AXI Master State Machine ------------------
    reg [2:0] m_state;
    localparam M_IDLE        = 3'b000,
               M_WRITE_ADDR  = 3'b001,
               M_WRITE_DATA  = 3'b010,
               M_WRITE_RESP  = 3'b011,
               M_READ_ADDR   = 3'b100,
               M_READ_DATA   = 3'b101,
               M_DONE        = 3'b110;

    // Debug signals for GTKWave
    wire [2:0] debug_m_state = m_state;
    wire [ADDR_W-1:0] debug_m_awaddr = M_AWADDR;
    wire [ADDR_W-1:0] debug_m_araddr = M_ARADDR;
    wire [DATA_W-1:0] debug_m_wdata = M_WDATA;
    wire debug_m_awvalid = M_AWVALID;
    wire debug_m_awready = M_AWREADY;
    wire debug_m_wvalid = M_WVALID;
    wire debug_m_wready = M_WREADY;
    wire debug_m_arvalid = M_ARVALID;
    wire debug_m_arready = M_ARREADY;
    wire debug_m_rvalid = M_RVALID;
    wire debug_m_rready = M_RREADY;

    always @(*) begin
        M_AWID    = 0;
        M_AWADDR  = INIT_WRITE_ADDR;
        M_AWLEN   = 8'd0;
        M_AWSIZE  = 3'b011;  // 64-bit
        M_AWBURST = 2'b01;
        M_AWVALID = (m_state == M_WRITE_ADDR);

        M_WDATA   = INIT_WRITE_DATA;
        M_WSTRB   = 8'hFF;
        M_WLAST   = 1'b1;
        M_WVALID  = (m_state == M_WRITE_DATA);
        M_BREADY  = 1'b1;

        M_ARID    = 0;
        M_ARADDR  = INIT_READ_ADDR;
        M_ARLEN   = 8'd0;
        M_ARSIZE  = 3'b011;
        M_ARBURST = 2'b01;
        M_ARVALID = (m_state == M_READ_ADDR);
        M_RREADY  = 1'b1;
    end

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            m_state <= M_IDLE;
        else begin
            case (m_state)
                M_IDLE:        m_state <= M_WRITE_ADDR;
                M_WRITE_ADDR:  if (M_AWVALID && M_AWREADY) m_state <= M_WRITE_DATA;
                M_WRITE_DATA:  if (M_WVALID && M_WREADY)   m_state <= M_WRITE_RESP;
                M_WRITE_RESP:  if (M_BVALID && M_BREADY)   m_state <= M_READ_ADDR;
                M_READ_ADDR:   if (M_ARVALID && M_ARREADY) m_state <= M_READ_DATA;
                M_READ_DATA:   if (M_RVALID && M_RREADY && M_RLAST) m_state <= M_DONE;
                M_DONE:        m_state <= M_DONE;
            endcase
        end
    end

    // ------------------ AXI Slave Write Logic ------------------
    reg [ADDR_W-1:0] write_addr_captured;
    reg write_addr_valid;
    
    // Debug signals for GTKWave
    wire [ADDR_W-1:0] debug_s_awaddr = S_AWADDR;
    wire [DATA_W-1:0] debug_s_wdata = S_WDATA;
    wire debug_s_awvalid = S_AWVALID;
    wire debug_s_awready = S_AWREADY;
    wire debug_s_wvalid = S_WVALID;
    wire debug_s_wready = S_WREADY;
    wire debug_s_bvalid = S_BVALID;
    wire debug_s_bready = S_BREADY;
    
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_AWREADY <= 0;
            S_WREADY  <= 0;
            S_BVALID  <= 0;
            write_addr_captured <= 0;
            write_addr_valid <= 0;
        end else begin
            // Always ready to accept address and data
            S_AWREADY <= 1;
            S_WREADY  <= 1;
            
            // Capture write address when valid
            if (S_AWVALID && S_AWREADY) begin
                write_addr_captured <= S_AWADDR;
                write_addr_valid <= 1;
            end
            
            // Process write data
            if (S_WVALID && S_WREADY && write_addr_valid) begin
                // Calculate word address (divide by 8 since we have 64-bit words)
                mem[write_addr_captured[12:3]] <= S_WDATA;
                S_BID    <= S_AWID;
                S_BRESP  <= 2'b00;
                S_BVALID <= 1;
                write_addr_valid <= 0;
            end else if (S_BVALID && S_BREADY) begin
                S_BVALID <= 0;
            end
        end
    end

    // ------------------ AXI Slave Read Logic ------------------
    reg [ADDR_W-1:0] read_addr_reg;
    reg read_pending;

    // Debug signals for GTKWave
    wire [ADDR_W-1:0] debug_s_araddr = S_ARADDR;
    wire [DATA_W-1:0] debug_s_rdata = S_RDATA;
    wire debug_s_arvalid = S_ARVALID;
    wire debug_s_arready = S_ARREADY;
    wire debug_s_rvalid = S_RVALID;
    wire debug_s_rready = S_RREADY;
    
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_ARREADY <= 0;
            S_RVALID  <= 0;
            S_RDATA   <= 0;
            read_addr_reg <= 0;
            read_pending  <= 0;
        end else begin
            // Accept read address
            S_ARREADY <= 1;
            if (S_ARVALID && S_ARREADY) begin
                read_addr_reg <= S_ARADDR;  // Latch address
                read_pending  <= 1;         // Mark pending read
            end

            // Provide read data on the next cycle
            if (read_pending && !S_RVALID) begin
                // Calculate word address (divide by 8 since we have 64-bit words)
                S_RDATA  <= mem[read_addr_reg[12:3]];
                S_RID    <= S_ARID;
                S_RRESP  <= 2'b00;
                S_RLAST  <= 1;
                S_RVALID <= 1;
                read_pending <= 0;
            end else if (S_RVALID && S_RREADY) begin
                S_RVALID <= 0;  // Complete transaction
            end
        end
    end

    // ------------------ Test Network Communication ------------------
    // Example: Send test data periodically
    reg [31:0] test_counter;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            test_counter <= 0;
            net_dest_gpu <= 0;
            net_payload <= 0;
            net_send_req <= 0;
        end else begin
            test_counter <= test_counter + 1;
            
            // Send test packet every 1000 cycles
            if (test_counter == 1000) begin
                net_dest_gpu <= (GPU_ID % 32) + 1; // Send to next GPU
                net_payload <= 10'h123;
                net_send_req <= 1;
                test_counter <= 0;
            end
        end
    end

endmodule