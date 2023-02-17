`timescale 1ns/1ns

module qam_mod_top 
    import parameter_def ::*; 
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   din_valid,
    input   logic           [3:0]   din,        // data in : 16-QAM carry 4-bit
    output  logic                   din_ready,
    qam_port.pout                   qam
);

    qam_internal_port #(.WIDTH(MOD_WIDTH))      mod();
    qam_internal_port #(.WIDTH(FILTER_WIDTH))   filter();
    qam_carrier #(.WIDTH(CARRIER_WIDTH))        cor();

    qam_mod inst_qam_mod
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .cor_zero  (cor.zero),
            .din_valid (din_valid),
            .din_ready (din_ready),
            .din       (din),
            .mod       (mod)
        );

    qam_cordic inst_qam_cordic (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .cor_en(cor_en), .cor(cor));

    qam_filter inst_qam_filter (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .mod(mod), .filter(filter));

    qam_mult_dsp inst_qam_mult_dsp (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .filter(filter), .cor(cor), .qam(qam));




/*
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
*/



endmodule : qam_mod_top