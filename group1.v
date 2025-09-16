`timescale 1ns/1ps
module group1(
  // Clock and Reset
  input wire ACLK,
  input wire ARESETn,
  input wire dir_local,
  
  // Exposed group ports for inter-group connections
  // Spine 1 group ports
  output wire [15:0] group211_out_data, group311_out_data, group411_out_data, group511_out_data,
  output wire [15:0] group611_out_data, group711_out_data, group811_out_data,
  output wire group211_out_valid, group311_out_valid, group411_out_valid, group511_out_valid,
  output wire group611_out_valid, group711_out_valid, group811_out_valid,
  input wire [15:0] group211_in_data, group311_in_data, group411_in_data, group511_in_data,
  input wire [15:0] group611_in_data, group711_in_data, group811_in_data,
  input wire group211_in_valid, group311_in_valid, group411_in_valid, group511_in_valid,
  input wire group611_in_valid, group711_in_valid, group811_in_valid,
  
  // Spine 2 group ports
  output wire [15:0] group212_out_data, group312_out_data, group412_out_data, group512_out_data,
  output wire [15:0] group612_out_data, group712_out_data, group812_out_data,
  output wire group212_out_valid, group312_out_valid, group412_out_valid, group512_out_valid,
  output wire group612_out_valid, group712_out_valid, group812_out_valid,
  input wire [15:0] group212_in_data, group312_in_data, group412_in_data, group512_in_data,
  input wire [15:0] group612_in_data, group712_in_data, group812_in_data,
  input wire group212_in_valid, group312_in_valid, group412_in_valid, group512_in_valid,
  input wire group612_in_valid, group712_in_valid, group812_in_valid,
  
  // Spine 3 group ports
  output wire [15:0] group213_out_data, group313_out_data, group413_out_data, group513_out_data,
  output wire [15:0] group613_out_data, group713_out_data, group813_out_data,
  output wire group213_out_valid, group313_out_valid, group413_out_valid, group513_out_valid,
  output wire group613_out_valid, group713_out_valid, group813_out_valid,
  input wire [15:0] group213_in_data, group313_in_data, group413_in_data, group513_in_data,
  input wire [15:0] group613_in_data, group713_in_data, group813_in_data,
  input wire group213_in_valid, group313_in_valid, group413_in_valid, group513_in_valid,
  input wire group613_in_valid, group713_in_valid, group813_in_valid,
  
  // Spine 4 group ports
  output wire [15:0] group214_out_data, group314_out_data, group414_out_data, group514_out_data,
  output wire [15:0] group614_out_data, group714_out_data, group814_out_data,
  output wire group214_out_valid, group314_out_valid, group414_out_valid, group514_out_valid,
  output wire group614_out_valid, group714_out_valid, group814_out_valid,
  input wire [15:0] group214_in_data, group314_in_data, group414_in_data, group514_in_data,
  input wire [15:0] group614_in_data, group714_in_data, group814_in_data,
  input wire group214_in_valid, group314_in_valid, group414_in_valid, group514_in_valid,
  input wire group614_in_valid, group714_in_valid, group814_in_valid
);

  // Internal connections between GPU modules and spine routers
  wire [15:0] spine11_out_data, spine12_out_data, spine13_out_data, spine14_out_data;
  wire spine11_out_valid, spine12_out_valid, spine13_out_valid, spine14_out_valid;
  wire [15:0] spine11_in_data, spine12_in_data, spine13_in_data, spine14_in_data;
  wire spine11_in_valid, spine12_in_valid, spine13_in_valid, spine14_in_valid;
  wire [5:0] spine11_dest_addr, spine12_dest_addr, spine13_dest_addr, spine14_dest_addr;
  
  wire [15:0] spine21_out_data, spine22_out_data, spine23_out_data, spine24_out_data;
  wire spine21_out_valid, spine22_out_valid, spine23_out_valid, spine24_out_valid;
  wire [15:0] spine21_in_data, spine22_in_data, spine23_in_data, spine24_in_data;
  wire spine21_in_valid, spine22_in_valid, spine23_in_valid, spine24_in_valid;
  wire [5:0] spine21_dest_addr, spine22_dest_addr, spine23_dest_addr, spine24_dest_addr;
  
  wire [15:0] spine31_out_data, spine32_out_data, spine33_out_data, spine34_out_data;
  wire spine31_out_valid, spine32_out_valid, spine33_out_valid, spine34_out_valid;
  wire [15:0] spine31_in_data, spine32_in_data, spine33_in_data, spine34_in_data;
  wire spine31_in_valid, spine32_in_valid, spine33_in_valid, spine34_in_valid;
  wire [5:0] spine31_dest_addr, spine32_dest_addr, spine33_dest_addr, spine34_dest_addr;
  
  wire [15:0] spine41_out_data, spine42_out_data, spine43_out_data, spine44_out_data;
  wire spine41_out_valid, spine42_out_valid, spine43_out_valid, spine44_out_valid;
  wire [15:0] spine41_in_data, spine42_in_data, spine43_in_data, spine44_in_data;
  wire spine41_in_valid, spine42_in_valid, spine43_in_valid, spine44_in_valid;
  wire [5:0] spine41_dest_addr, spine42_dest_addr, spine43_dest_addr, spine44_dest_addr;

  // Instantiate GPU modules (GPUs 1-4)
  top1 gpu1 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .spine11_out_data(spine11_out_data),
    .spine11_out_valid(spine11_out_valid),
    .spine11_in_data(spine11_in_data),
    .spine11_in_valid(spine11_in_valid),
    .spine11_dest_addr(spine11_dest_addr),
    .spine21_out_data(spine21_out_data),
    .spine21_out_valid(spine21_out_valid),
    .spine21_in_data(spine21_in_data),
    .spine21_in_valid(spine21_in_valid),
    .spine21_dest_addr(spine21_dest_addr),
    .spine31_out_data(spine31_out_data),
    .spine31_out_valid(spine31_out_valid),
    .spine31_in_data(spine31_in_data),
    .spine31_in_valid(spine31_in_valid),
    .spine31_dest_addr(spine31_dest_addr),
    .spine41_out_data(spine41_out_data),
    .spine41_out_valid(spine41_out_valid),
    .spine41_in_data(spine41_in_data),
    .spine41_in_valid(spine41_in_valid),
    .spine41_dest_addr(spine41_dest_addr)
  );

  top2 gpu2 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .spine12_out_data(spine12_out_data),
    .spine12_out_valid(spine12_out_valid),
    .spine12_in_data(spine12_in_data),
    .spine12_in_valid(spine12_in_valid),
    .spine12_dest_addr(spine12_dest_addr),
    .spine22_out_data(spine22_out_data),
    .spine22_out_valid(spine22_out_valid),
    .spine22_in_data(spine22_in_data),
    .spine22_in_valid(spine22_in_valid),
    .spine22_dest_addr(spine22_dest_addr),
    .spine32_out_data(spine32_out_data),
    .spine32_out_valid(spine32_out_valid),
    .spine32_in_data(spine32_in_data),
    .spine32_in_valid(spine32_in_valid),
    .spine32_dest_addr(spine32_dest_addr),
    .spine42_out_data(spine42_out_data),
    .spine42_out_valid(spine42_out_valid),
    .spine42_in_data(spine42_in_data),
    .spine42_in_valid(spine42_in_valid),
    .spine42_dest_addr(spine42_dest_addr)
  );

  top3 gpu3 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .spine13_out_data(spine13_out_data),
    .spine13_out_valid(spine13_out_valid),
    .spine13_in_data(spine13_in_data),
    .spine13_in_valid(spine13_in_valid),
    .spine13_dest_addr(spine13_dest_addr),
    .spine23_out_data(spine23_out_data),
    .spine23_out_valid(spine23_out_valid),
    .spine23_in_data(spine23_in_data),
    .spine23_in_valid(spine23_in_valid),
    .spine23_dest_addr(spine23_dest_addr),
    .spine33_out_data(spine33_out_data),
    .spine33_out_valid(spine33_out_valid),
    .spine33_in_data(spine33_in_data),
    .spine33_in_valid(spine33_in_valid),
    .spine33_dest_addr(spine33_dest_addr),
    .spine43_out_data(spine43_out_data),
    .spine43_out_valid(spine43_out_valid),
    .spine43_in_data(spine43_in_data),
    .spine43_in_valid(spine43_in_valid),
    .spine43_dest_addr(spine43_dest_addr)
  );

  top4 gpu4 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .spine14_out_data(spine14_out_data),
    .spine14_out_valid(spine14_out_valid),
    .spine14_in_data(spine14_in_data),
    .spine14_in_valid(spine14_in_valid),
    .spine14_dest_addr(spine14_dest_addr),
    .spine24_out_data(spine24_out_data),
    .spine24_out_valid(spine24_out_valid),
    .spine24_in_data(spine24_in_data),
    .spine24_in_valid(spine24_in_valid),
    .spine24_dest_addr(spine24_dest_addr),
    .spine34_out_data(spine34_out_data),
    .spine34_out_valid(spine34_out_valid),
    .spine34_in_data(spine34_in_data),
    .spine34_in_valid(spine34_in_valid),
    .spine34_dest_addr(spine34_dest_addr),
    .spine44_out_data(spine44_out_data),
    .spine44_out_valid(spine44_out_valid),
    .spine44_in_data(spine44_in_data),
    .spine44_in_valid(spine44_in_valid),
    .spine44_dest_addr(spine44_dest_addr)
  );

  // Instantiate Spine Routers
  spine_router1 #(
    .GROUP_ID(4'b0001),
    .SPINE_ROUTER_ID(1),
    .DWIDTH(16),
    .FIFO_DEPTH(8)
  ) spine1 (
    .clk(ACLK),
    .reset(~ARESETn),
    .dir_local(dir_local),
    
    // Leaf connections
    .spine11_in_data(spine11_out_data),
    .spine11_in_valid(spine11_out_valid),
    .spine11_out_data(spine11_in_data),
    .spine11_out_valid(spine11_in_valid),
    
    .spine12_in_data(spine12_out_data),
    .spine12_in_valid(spine12_out_valid),
    .spine12_out_data(spine12_in_data),
    .spine12_out_valid(spine12_in_valid),
    
    .spine13_in_data(spine13_out_data),
    .spine13_in_valid(spine13_out_valid),
    .spine13_out_data(spine13_in_data),
    .spine13_out_valid(spine13_in_valid),
    
    .spine14_in_data(spine14_out_data),
    .spine14_in_valid(spine14_out_valid),
    .spine14_out_data(spine14_in_data),
    .spine14_out_valid(spine14_in_valid),
    
    // Group connections (exposed)
    .group211_out_data(group211_out_data),
    .group211_out_valid(group211_out_valid),
    .group211_in_data(group211_in_data),
    .group211_in_valid(group211_in_valid),
    
    .group311_out_data(group311_out_data),
    .group311_out_valid(group311_out_valid),
    .group311_in_data(group311_in_data),
    .group311_in_valid(group311_in_valid),
    
    .group411_out_data(group411_out_data),
    .group411_out_valid(group411_out_valid),
    .group411_in_data(group411_in_data),
    .group411_in_valid(group411_in_valid),
    
    .group511_out_data(group511_out_data),
    .group511_out_valid(group511_out_valid),
    .group511_in_data(group511_in_data),
    .group511_in_valid(group511_in_valid),
    
    .group611_out_data(group611_out_data),
    .group611_out_valid(group611_out_valid),
    .group611_in_data(group611_in_data),
    .group611_in_valid(group611_in_valid),
    
    .group711_out_data(group711_out_data),
    .group711_out_valid(group711_out_valid),
    .group711_in_data(group711_in_data),
    .group711_in_valid(group711_in_valid),
    
    .group811_out_data(group811_out_data),
    .group811_out_valid(group811_out_valid),
    .group811_in_data(group811_in_data),
    .group811_in_valid(group811_in_valid)
  );

  spine_router2 #(
    .GROUP_ID(4'b0001),
    .SPINE_ROUTER_ID(2),
    .DWIDTH(16),
    .FIFO_DEPTH(8)
  ) spine2 (
    .clk(ACLK),
    .reset(~ARESETn),
    .dir_local(dir_local),
    
    // Leaf connections
    .spine21_in_data(spine21_out_data),
    .spine21_in_valid(spine21_out_valid),
    .spine21_out_data(spine21_in_data),
    .spine21_out_valid(spine21_in_valid),
    
    .spine22_in_data(spine22_out_data),
    .spine22_in_valid(spine22_out_valid),
    .spine22_out_data(spine22_in_data),
    .spine22_out_valid(spine22_in_valid),
    
    .spine23_in_data(spine23_out_data),
    .spine23_in_valid(spine23_out_valid),
    .spine23_out_data(spine23_in_data),
    .spine23_out_valid(spine23_in_valid),
    
    .spine24_in_data(spine24_out_data),
    .spine24_in_valid(spine24_out_valid),
    .spine24_out_data(spine24_in_data),
    .spine24_out_valid(spine24_in_valid),
    
    // Group connections (exposed)
    .group212_out_data(group212_out_data),
    .group212_out_valid(group212_out_valid),
    .group212_in_data(group212_in_data),
    .group212_in_valid(group212_in_valid),
    
    .group312_out_data(group312_out_data),
    .group312_out_valid(group312_out_valid),
    .group312_in_data(group312_in_data),
    .group312_in_valid(group312_in_valid),
    
    .group412_out_data(group412_out_data),
    .group412_out_valid(group412_out_valid),
    .group412_in_data(group412_in_data),
    .group412_in_valid(group412_in_valid),
    
    .group512_out_data(group512_out_data),
    .group512_out_valid(group512_out_valid),
    .group512_in_data(group512_in_data),
    .group512_in_valid(group512_in_valid),
    
    .group612_out_data(group612_out_data),
    .group612_out_valid(group612_out_valid),
    .group612_in_data(group612_in_data),
    .group612_in_valid(group612_in_valid),
    
    .group712_out_data(group712_out_data),
    .group712_out_valid(group712_out_valid),
    .group712_in_data(group712_in_data),
    .group712_in_valid(group712_in_valid),
    
    .group812_out_data(group812_out_data),
    .group812_out_valid(group812_out_valid),
    .group812_in_data(group812_in_data),
    .group812_in_valid(group812_in_valid)
  );

  // Instantiate Spine 3 and Spine 4 similarly...
  spine_router3 #(
    .GROUP_ID(4'b0001),
    .SPINE_ROUTER_ID(3),
    .DWIDTH(16),
    .FIFO_DEPTH(8)
  ) spine3 (
    .clk(ACLK),
    .reset(~ARESETn),
    .dir_local(dir_local),
    
    // Leaf connections
    .spine31_in_data(spine31_out_data),
    .spine31_in_valid(spine31_out_valid),
    .spine31_out_data(spine31_in_data),
    .spine31_out_valid(spine31_in_valid),
    
    .spine32_in_data(spine32_out_data),
    .spine32_in_valid(spine32_out_valid),
    .spine32_out_data(spine32_in_data),
    .spine32_out_valid(spine32_in_valid),
    
    .spine33_in_data(spine33_out_data),
    .spine33_in_valid(spine33_out_valid),
    .spine33_out_data(spine33_in_data),
    .spine33_out_valid(spine33_in_valid),
    
    .spine34_in_data(spine34_out_data),
    .spine34_in_valid(spine34_out_valid),
    .spine34_out_data(spine34_in_data),
    .spine34_out_valid(spine34_in_valid),
    
    // Group connections (exposed)
    .group213_out_data(group213_out_data),
    .group213_out_valid(group213_out_valid),
    .group213_in_data(group213_in_data),
    .group213_in_valid(group213_in_valid),
    
    .group313_out_data(group313_out_data),
    .group313_out_valid(group313_out_valid),
    .group313_in_data(group313_in_data),
    .group313_in_valid(group313_in_valid),
    
    .group413_out_data(group413_out_data),
    .group413_out_valid(group413_out_valid),
    .group413_in_data(group413_in_data),
    .group413_in_valid(group413_in_valid),
    
    .group513_out_data(group513_out_data),
    .group513_out_valid(group513_out_valid),
    .group513_in_data(group513_in_data),
    .group513_in_valid(group513_in_valid),
    
    .group613_out_data(group613_out_data),
    .group613_out_valid(group613_out_valid),
    .group613_in_data(group613_in_data),
    .group613_in_valid(group613_in_valid),
    
    .group713_out_data(group713_out_data),
    .group713_out_valid(group713_out_valid),
    .group713_in_data(group713_in_data),
    .group713_in_valid(group713_in_valid),
    
    .group813_out_data(group813_out_data),
    .group813_out_valid(group813_out_valid),
    .group813_in_data(group813_in_data),
    .group813_in_valid(group813_in_valid)
  );

  spine_router4 #(
    .GROUP_ID(4'b0001),
    .SPINE_ROUTER_ID(4),
    .DWIDTH(16),
    .FIFO_DEPTH(8)
  ) spine4 (
    .clk(ACLK),
    .reset(~ARESETn),
    .dir_local(dir_local),
    
    // Leaf connections
    .spine41_in_data(spine41_out_data),
    .spine41_in_valid(spine41_out_valid),
    .spine41_out_data(spine41_in_data),
    .spine41_out_valid(spine41_in_valid),
    
    .spine42_in_data(spine42_out_data),
    .spine42_in_valid(spine42_out_valid),
    .spine42_out_data(spine42_in_data),
    .spine42_out_valid(spine42_in_valid),
    
    .spine43_in_data(spine43_out_data),
    .spine43_in_valid(spine43_out_valid),
    .spine43_out_data(spine43_in_data),
    .spine43_out_valid(spine43_in_valid),
    
    .spine44_in_data(spine44_out_data),
    .spine44_in_valid(spine44_out_valid),
    .spine44_out_data(spine44_in_data),
    .spine44_out_valid(spine44_in_valid),
    
    // Group connections (exposed)
    .group214_out_data(group214_out_data),
    .group214_out_valid(group214_out_valid),
    .group214_in_data(group214_in_data),
    .group214_in_valid(group214_in_valid),
    
    .group314_out_data(group314_out_data),
    .group314_out_valid(group314_out_valid),
    .group314_in_data(group314_in_data),
    .group314_in_valid(group314_in_valid),
    
    .group414_out_data(group414_out_data),
    .group414_out_valid(group414_out_valid),
    .group414_in_data(group414_in_data),
    .group414_in_valid(group414_in_valid),
    
    .group514_out_data(group514_out_data),
    .group514_out_valid(group514_out_valid),
    .group514_in_data(group514_in_data),
    .group514_in_valid(group514_in_valid),
    
    .group614_out_data(group614_out_data),
    .group614_out_valid(group614_out_valid),
    .group614_in_data(group614_in_data),
    .group614_in_valid(group614_in_valid),
    
    .group714_out_data(group714_out_data),
    .group714_out_valid(group714_out_valid),
    .group714_in_data(group714_in_data),
    .group714_in_valid(group714_in_valid),
    
    .group814_out_data(group814_out_data),
    .group814_out_valid(group814_out_valid),
    .group814_in_data(group814_in_data),
    .group814_in_valid(group814_in_valid)
  );

endmodule