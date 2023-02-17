`timescale 1ns/1ns

module qam_mod_top_for_data_export        
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   din_valid,
    input   logic           [3:0]   din,        // data in : 16-QAM carry 4-bit
    output  logic                   din_ready,
    output  logic                   qam_valid,
    output  logic   signed  [17:0]  qam_data,     
    output  logic                   mod_valid,
    output  logic   signed  [2:0]   mod_q,      // Q channel
    output  logic   signed  [2:0]   mod_i,      // I channel
    output  logic                   cor_valid,
    output  logic   signed  [7:0]   sin,
    output  logic   signed  [7:0]   cos,
    output  logic                   filter_valid,
    output  logic   signed  [14:0]  filter_q,      // Q channel
    output  logic   signed  [14:0]  filter_i       // I channel

);
    import parameter_def ::*; 
    
    qam_internal_port #(.WIDTH(MOD_WIDTH))      mod();
    qam_internal_port #(.WIDTH(FILTER_WIDTH))   filter();
    qam_carrier #(.WIDTH(CARRIER_WIDTH))        cor();
    qam_port #(.WIDTH(QAM_WIDTH))               qam();

    assign filter_valid = filter.valid;     
    assign filter_q     = filter.q;
    assign filter_i     = filter.i;

    assign qam_valid = qam.valid;     
    assign qam_data  = qam.data;

    assign mod_valid = mod.valid;            
    assign mod_q     = mod.q;    
    assign mod_i     = mod.i;           

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



endmodule : qam_mod_top_for_data_export