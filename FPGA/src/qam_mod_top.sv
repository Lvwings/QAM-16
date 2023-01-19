`timescale 1ns/1ns

module qam_mod_top (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   din_valid,
    input   logic   signed [3:0]    din,        // data in : 16-QAM carry 4-bit
    output  logic                   din_ready,
    output  logic                   qam_valid,
    output  logic   signed  [9:0]   qam_out     // data format : 3Q6
);

    logic   signed  [2:0]   mod_q,mod_i;
    logic   signed  [7:0]   sin,cos;


    qam_mod inst_qam_mod
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .cor_zero  (cor_zero),
            .din_valid (din_valid),
            .din_ready (din_ready),
            .din       (din),
            .mod_valid (mod_valid),
            .mod_q     (mod_q),
            .mod_i     (mod_i)
        );

    qam_cordic inst_qam_cordic
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .cor_en    (1),
            .cor_valid (cor_valid),
            .cor_zero  (cor_zero),
            .sin       (sin),
            .cos       (cos)
        );



    qam_mult inst_qam_mult
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .mod_valid (mod_valid),
            .mod_q     (mod_q),
            .mod_i     (mod_i),
            .cor_valid (cor_valid),
            .sin       (sin),
            .cos       (cos),
            .qam_valid (qam_valid),
            .qam_out   (qam_out)
        );




endmodule : qam_mod_top