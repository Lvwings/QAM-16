`timescale 1ns/1ns

module qam_top (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   din_valid,
    input   logic           [3:0]   din,        // data in : 16-QAM carry 4-bit
    output  logic                   din_ready,
    output  logic                   demult_valid,
    output  logic   signed  [17:0]  demult_q,   // data format : 5Q12
    output  logic   signed  [17:0]  demult_i    // data format : 5Q12    
    
);

    logic   signed  [9:0]   qam_out,qam_in;

    assign qam_in = qam_out;

    qam_mod_top inst_qam_mod_top
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .din_valid (din_valid),
            .din       (din),
            .din_ready (din_ready),
            .qam_valid (qam_valid),
            .qam_out   (qam_out)
        );

    qam_demod_top inst_qam_demod_top
        (
            .axi_clk      (axi_clk),
            .axi_rstn     (axi_rstn),
            .qam_valid    (qam_valid),
            .qam_in       (qam_in),
            .dout_valid   (dout_valid),
            .dout         (dout),
            .demult_valid (demult_valid),
            .demult_q     (demult_q),
            .demult_i     (demult_i)
        );




endmodule : qam_top