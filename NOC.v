`timescale 1ns/1ps
module noc_wrapper(
  // Clock and Reset
  input wire ACLK,
  input wire ARESETn
);

  // Internal wiring - SEPARATE wires for each direction between groups
  // Group 1 connections
  wire [15:0] g1_to_g2_data, g2_to_g1_data;
  wire g1_to_g2_valid, g2_to_g1_valid;
  wire [15:0] g1_to_g3_data, g3_to_g1_data;
  wire g1_to_g3_valid, g3_to_g1_valid;
  wire [15:0] g1_to_g4_data, g4_to_g1_data;
  wire g1_to_g4_valid, g4_to_g1_valid;
  wire [15:0] g1_to_g5_data, g5_to_g1_data;
  wire g1_to_g5_valid, g5_to_g1_valid;
  wire [15:0] g1_to_g6_data, g6_to_g1_data;
  wire g1_to_g6_valid, g6_to_g1_valid;
  wire [15:0] g1_to_g7_data, g7_to_g1_data;
  wire g1_to_g7_valid, g7_to_g1_valid;
  wire [15:0] g1_to_g8_data, g8_to_g1_data;
  wire g1_to_g8_valid, g8_to_g1_valid;

  // Group 2 connections
  wire [15:0] g2_to_g3_data, g3_to_g2_data;
  wire g2_to_g3_valid, g3_to_g2_valid;
  wire [15:0] g2_to_g4_data, g4_to_g2_data;
  wire g2_to_g4_valid, g4_to_g2_valid;
  wire [15:0] g2_to_g5_data, g5_to_g2_data;
  wire g2_to_g5_valid, g5_to_g2_valid;
  wire [15:0] g2_to_g6_data, g6_to_g2_data;
  wire g2_to_g6_valid, g6_to_g2_valid;
  wire [15:0] g2_to_g7_data, g7_to_g2_data;
  wire g2_to_g7_valid, g7_to_g2_valid;
  wire [15:0] g2_to_g8_data, g8_to_g2_data;
  wire g2_to_g8_valid, g8_to_g2_valid;

  // Group 3 connections
  wire [15:0] g3_to_g4_data, g4_to_g3_data;
  wire g3_to_g4_valid, g4_to_g3_valid;
  wire [15:0] g3_to_g5_data, g5_to_g3_data;
  wire g3_to_g5_valid, g5_to_g3_valid;
  wire [15:0] g3_to_g6_data, g6_to_g3_data;
  wire g3_to_g6_valid, g6_to_g3_valid;
  wire [15:0] g3_to_g7_data, g7_to_g3_data;
  wire g3_to_g7_valid, g7_to_g3_valid;
  wire [15:0] g3_to_g8_data, g8_to_g3_data;
  wire g3_to_g8_valid, g8_to_g3_valid;

  // Group 4 connections
  wire [15:0] g4_to_g5_data, g5_to_g4_data;
  wire g4_to_g5_valid, g5_to_g4_valid;
  wire [15:0] g4_to_g6_data, g6_to_g4_data;
  wire g4_to_g6_valid, g6_to_g4_valid;
  wire [15:0] g4_to_g7_data, g7_to_g4_data;
  wire g4_to_g7_valid, g7_to_g4_valid;
  wire [15:0] g4_to_g8_data, g8_to_g4_data;
  wire g4_to_g8_valid, g8_to_g4_valid;

  // Group 5 connections
  wire [15:0] g5_to_g6_data, g6_to_g5_data;
  wire g5_to_g6_valid, g6_to_g5_valid;
  wire [15:0] g5_to_g7_data, g7_to_g5_data;
  wire g5_to_g7_valid, g7_to_g5_valid;
  wire [15:0] g5_to_g8_data, g8_to_g5_data;
  wire g5_to_g8_valid, g8_to_g5_valid;

  // Group 6 connections
  wire [15:0] g6_to_g7_data, g7_to_g6_data;
  wire g6_to_g7_valid, g7_to_g6_valid;
  wire [15:0] g6_to_g8_data, g8_to_g6_data;
  wire g6_to_g8_valid, g8_to_g6_valid;

  // Group 7 connections
  wire [15:0] g7_to_g8_data, g8_to_g7_data;
  wire g7_to_g8_valid, g8_to_g7_valid;

  // Instantiate all 8 groups with proper bidirectional connections
  group1 g1 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 2
    .group2_out_data(g1_to_g2_data),
    .group2_out_valid(g1_to_g2_valid),
    .group2_in_data(g2_to_g1_data),
    .group2_in_valid(g2_to_g1_valid),
    // Connection to Group 3
    .group3_out_data(g1_to_g3_data),
    .group3_out_valid(g1_to_g3_valid),
    .group3_in_data(g3_to_g1_data),
    .group3_in_valid(g3_to_g1_valid),
    // Connection to Group 4
    .group4_out_data(g1_to_g4_data),
    .group4_out_valid(g1_to_g4_valid),
    .group4_in_data(g4_to_g1_data),
    .group4_in_valid(g4_to_g1_valid),
    // Connection to Group 5
    .group5_out_data(g1_to_g5_data),
    .group5_out_valid(g1_to_g5_valid),
    .group5_in_data(g5_to_g1_data),
    .group5_in_valid(g5_to_g1_valid),
    // Connection to Group 6
    .group6_out_data(g1_to_g6_data),
    .group6_out_valid(g1_to_g6_valid),
    .group6_in_data(g6_to_g1_data),
    .group6_in_valid(g6_to_g1_valid),
    // Connection to Group 7
    .group7_out_data(g1_to_g7_data),
    .group7_out_valid(g1_to_g7_valid),
    .group7_in_data(g7_to_g1_data),
    .group7_in_valid(g7_to_g1_valid),
    // Connection to Group 8
    .group8_out_data(g1_to_g8_data),
    .group8_out_valid(g1_to_g8_valid),
    .group8_in_data(g8_to_g1_data),
    .group8_in_valid(g8_to_g1_valid)
  );

  group2 g2 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g2_to_g1_data),
    .group1_out_valid(g2_to_g1_valid),
    .group1_in_data(g1_to_g2_data),
    .group1_in_valid(g1_to_g2_valid),
    // Connection to Group 3
    .group3_out_data(g2_to_g3_data),
    .group3_out_valid(g2_to_g3_valid),
    .group3_in_data(g3_to_g2_data),
    .group3_in_valid(g3_to_g2_valid),
    // Connection to Group 4
    .group4_out_data(g2_to_g4_data),
    .group4_out_valid(g2_to_g4_valid),
    .group4_in_data(g4_to_g2_data),
    .group4_in_valid(g4_to_g2_valid),
    // Connection to Group 5
    .group5_out_data(g2_to_g5_data),
    .group5_out_valid(g2_to_g5_valid),
    .group5_in_data(g5_to_g2_data),
    .group5_in_valid(g5_to_g2_valid),
    // Connection to Group 6
    .group6_out_data(g2_to_g6_data),
    .group6_out_valid(g2_to_g6_valid),
    .group6_in_data(g6_to_g2_data),
    .group6_in_valid(g6_to_g2_valid),
    // Connection to Group 7
    .group7_out_data(g2_to_g7_data),
    .group7_out_valid(g2_to_g7_valid),
    .group7_in_data(g7_to_g2_data),
    .group7_in_valid(g7_to_g2_valid),
    // Connection to Group 8
    .group8_out_data(g2_to_g8_data),
    .group8_out_valid(g2_to_g8_valid),
    .group8_in_data(g8_to_g2_data),
    .group8_in_valid(g8_to_g2_valid)
  );

  group3 g3 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g3_to_g1_data),
    .group1_out_valid(g3_to_g1_valid),
    .group1_in_data(g1_to_g3_data),
    .group1_in_valid(g1_to_g3_valid),
    // Connection to Group 2
    .group2_out_data(g3_to_g2_data),
    .group2_out_valid(g3_to_g2_valid),
    .group2_in_data(g2_to_g3_data),
    .group2_in_valid(g2_to_g3_valid),
    // Connection to Group 4
    .group4_out_data(g3_to_g4_data),
    .group4_out_valid(g3_to_g4_valid),
    .group4_in_data(g4_to_g3_data),
    .group4_in_valid(g4_to_g3_valid),
    // Connection to Group 5
    .group5_out_data(g3_to_g5_data),
    .group5_out_valid(g3_to_g5_valid),
    .group5_in_data(g5_to_g3_data),
    .group5_in_valid(g5_to_g3_valid),
    // Connection to Group 6
    .group6_out_data(g3_to_g6_data),
    .group6_out_valid(g3_to_g6_valid),
    .group6_in_data(g6_to_g3_data),
    .group6_in_valid(g6_to_g3_valid),
    // Connection to Group 7
    .group7_out_data(g3_to_g7_data),
    .group7_out_valid(g3_to_g7_valid),
    .group7_in_data(g7_to_g3_data),
    .group7_in_valid(g7_to_g3_valid),
    // Connection to Group 8
    .group8_out_data(g3_to_g8_data),
    .group8_out_valid(g3_to_g8_valid),
    .group8_in_data(g8_to_g3_data),
    .group8_in_valid(g8_to_g3_valid)
  );

  group4 g4 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g4_to_g1_data),
    .group1_out_valid(g4_to_g1_valid),
    .group1_in_data(g1_to_g4_data),
    .group1_in_valid(g1_to_g4_valid),
    // Connection to Group 2
    .group2_out_data(g4_to_g2_data),
    .group2_out_valid(g4_to_g2_valid),
    .group2_in_data(g2_to_g4_data),
    .group2_in_valid(g2_to_g4_valid),
    // Connection to Group 3
    .group3_out_data(g4_to_g3_data),
    .group3_out_valid(g4_to_g3_valid),
    .group3_in_data(g3_to_g4_data),
    .group3_in_valid(g3_to_g4_valid),
    // Connection to Group 5
    .group5_out_data(g4_to_g5_data),
    .group5_out_valid(g4_to_g5_valid),
    .group5_in_data(g5_to_g4_data),
    .group5_in_valid(g5_to_g4_valid),
    // Connection to Group 6
    .group6_out_data(g4_to_g6_data),
    .group6_out_valid(g4_to_g6_valid),
    .group6_in_data(g6_to_g4_data),
    .group6_in_valid(g6_to_g4_valid),
    // Connection to Group 7
    .group7_out_data(g4_to_g7_data),
    .group7_out_valid(g4_to_g7_valid),
    .group7_in_data(g7_to_g4_data),
    .group7_in_valid(g7_to_g4_valid),
    // Connection to Group 8
    .group8_out_data(g4_to_g8_data),
    .group8_out_valid(g4_to_g8_valid),
    .group8_in_data(g8_to_g4_data),
    .group8_in_valid(g8_to_g4_valid)
  );

  group5 g5 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g5_to_g1_data),
    .group1_out_valid(g5_to_g1_valid),
    .group1_in_data(g1_to_g5_data),
    .group1_in_valid(g1_to_g5_valid),
    // Connection to Group 2
    .group2_out_data(g5_to_g2_data),
    .group2_out_valid(g5_to_g2_valid),
    .group2_in_data(g2_to_g5_data),
    .group2_in_valid(g2_to_g5_valid),
    // Connection to Group 3
    .group3_out_data(g5_to_g3_data),
    .group3_out_valid(g5_to_g3_valid),
    .group3_in_data(g3_to_g5_data),
    .group3_in_valid(g3_to_g5_valid),
    // Connection to Group 4
    .group4_out_data(g5_to_g4_data),
    .group4_out_valid(g5_to_g4_valid),
    .group4_in_data(g4_to_g5_data),
    .group4_in_valid(g4_to_g5_valid),
    // Connection to Group 6
    .group6_out_data(g5_to_g6_data),
    .group6_out_valid(g5_to_g6_valid),
    .group6_in_data(g6_to_g5_data),
    .group6_in_valid(g6_to_g5_valid),
    // Connection to Group 7
    .group7_out_data(g5_to_g7_data),
    .group7_out_valid(g5_to_g7_valid),
    .group7_in_data(g7_to_g5_data),
    .group7_in_valid(g7_to_g5_valid),
    // Connection to Group 8
    .group8_out_data(g5_to_g8_data),
    .group8_out_valid(g5_to_g8_valid),
    .group8_in_data(g8_to_g5_data),
    .group8_in_valid(g8_to_g5_valid)
  );

  group6 g6 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g6_to_g1_data),
    .group1_out_valid(g6_to_g1_valid),
    .group1_in_data(g1_to_g6_data),
    .group1_in_valid(g1_to_g6_valid),
    // Connection to Group 2
    .group2_out_data(g6_to_g2_data),
    .group2_out_valid(g6_to_g2_valid),
    .group2_in_data(g2_to_g6_data),
    .group2_in_valid(g2_to_g6_valid),
    // Connection to Group 3
    .group3_out_data(g6_to_g3_data),
    .group3_out_valid(g6_to_g3_valid),
    .group3_in_data(g3_to_g6_data),
    .group3_in_valid(g3_to_g6_valid),
    // Connection to Group 4
    .group4_out_data(g6_to_g4_data),
    .group4_out_valid(g6_to_g4_valid),
    .group4_in_data(g4_to_g6_data),
    .group4_in_valid(g4_to_g6_valid),
    // Connection to Group 5
    .group5_out_data(g6_to_g5_data),
    .group5_out_valid(g6_to_g5_valid),
    .group5_in_data(g5_to_g6_data),
    .group5_in_valid(g5_to_g6_valid),
    // Connection to Group 7
    .group7_out_data(g6_to_g7_data),
    .group7_out_valid(g6_to_g7_valid),
    .group7_in_data(g7_to_g6_data),
    .group7_in_valid(g7_to_g6_valid),
    // Connection to Group 8
    .group8_out_data(g6_to_g8_data),
    .group8_out_valid(g6_to_g8_valid),
    .group8_in_data(g8_to_g6_data),
    .group8_in_valid(g8_to_g6_valid)
  );

  group7 g7 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g7_to_g1_data),
    .group1_out_valid(g7_to_g1_valid),
    .group1_in_data(g1_to_g7_data),
    .group1_in_valid(g1_to_g7_valid),
    // Connection to Group 2
    .group2_out_data(g7_to_g2_data),
    .group2_out_valid(g7_to_g2_valid),
    .group2_in_data(g2_to_g7_data),
    .group2_in_valid(g2_to_g7_valid),
    // Connection to Group 3
    .group3_out_data(g7_to_g3_data),
    .group3_out_valid(g7_to_g3_valid),
    .group3_in_data(g3_to_g7_data),
    .group3_in_valid(g3_to_g7_valid),
    // Connection to Group 4
    .group4_out_data(g7_to_g4_data),
    .group4_out_valid(g7_to_g4_valid),
    .group4_in_data(g4_to_g7_data),
    .group4_in_valid(g4_to_g7_valid),
    // Connection to Group 5
    .group5_out_data(g7_to_g5_data),
    .group5_out_valid(g7_to_g5_valid),
    .group5_in_data(g5_to_g7_data),
    .group5_in_valid(g5_to_g7_valid),
    // Connection to Group 6
    .group6_out_data(g7_to_g6_data),
    .group6_out_valid(g7_to_g6_valid),
    .group6_in_data(g6_to_g7_data),
    .group6_in_valid(g6_to_g7_valid),
    // Connection to Group 8
    .group8_out_data(g7_to_g8_data),
    .group8_out_valid(g7_to_g8_valid),
    .group8_in_data(g8_to_g7_data),
    .group8_in_valid(g8_to_g7_valid)
  );

  group8 g8 (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    // Connection to Group 1
    .group1_out_data(g8_to_g1_data),
    .group1_out_valid(g8_to_g1_valid),
    .group1_in_data(g1_to_g8_data),
    .group1_in_valid(g1_to_g8_valid),
    // Connection to Group 2
    .group2_out_data(g8_to_g2_data),
    .group2_out_valid(g8_to_g2_valid),
    .group2_in_data(g2_to_g8_data),
    .group2_in_valid(g2_to_g8_valid),
    // Connection to Group 3
    .group3_out_data(g8_to_g3_data),
    .group3_out_valid(g8_to_g3_valid),
    .group3_in_data(g3_to_g8_data),
    .group3_in_valid(g3_to_g8_valid),
    // Connection to Group 4
    .group4_out_data(g8_to_g4_data),
    .group4_out_valid(g8_to_g4_valid),
    .group4_in_data(g4_to_g8_data),
    .group4_in_valid(g4_to_g8_valid),
    // Connection to Group 5
    .group5_out_data(g8_to_g5_data),
    .group5_out_valid(g8_to_g5_valid),
    .group5_in_data(g5_to_g8_data),
    .group5_in_valid(g5_to_g8_valid),
    // Connection to Group 6
    .group6_out_data(g8_to_g6_data),
    .group6_out_valid(g8_to_g6_valid),
    .group6_in_data(g6_to_g8_data),
    .group6_in_valid(g6_to_g8_valid),
    // Connection to Group 7
    .group7_out_data(g8_to_g7_data),
    .group7_out_valid(g8_to_g7_valid),
    .group7_in_data(g7_to_g8_data),
    .group7_in_valid(g7_to_g8_valid)
  );

endmodule