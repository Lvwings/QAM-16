`timescale 1ns/1ns

module qam_demod_top_for_data_export  
    import parameter_def ::*;
    (
    input   logic                               axi_clk,    // Clock
    input   logic                               axi_rstn,   // synchronous reset active low 
    input   logic   signed  [QAM_WIDTH-1 : 0]   qam_data,
    input   logic                               qam_valid,           
    output  logic                               dout_valid,   
    output  logic           [3:0]               dout,
    output  logic                               demod_valid,
    output  logic   signed  [MOD_WIDTH-1:0]     demod_q,      // Q channel
    output  logic   signed  [MOD_WIDTH-1:0]     demod_i,      // I channel
    output  logic                               demult_valid,
    output  logic   signed  [DEMULT_WIDTH-1:0]  demult_q,      // Q channel
    output  logic   signed  [DEMULT_WIDTH-1:0]  demult_i,      // I channel    
    output  logic                               cor_valid,
    output  logic   signed  [CARRIER_WIDTH-1:0] sin,
    output  logic   signed  [CARRIER_WIDTH-1:0] cos,
    output  logic                               defilter_valid,
    output  logic   signed  [DEFILTER_WIDTH-1:0]defilter_q,      // Q channel
    output  logic   signed  [DEFILTER_WIDTH-1:0]defilter_i       // I channel    
);
    qam_internal_port #(.WIDTH(MOD_WIDTH))          demod();
    qam_internal_port #(.WIDTH(DEMULT_WIDTH))       demult();
    qam_internal_port #(.WIDTH(DEFILTER_WIDTH))     defilter();
    qam_carrier #(.WIDTH(CARRIER_WIDTH))            cor();
    qam_port #(.WIDTH(QAM_WIDTH))                   qam();

    assign cor_en         = 1;
    assign defilter_valid = defilter.valid;     
    assign defilter_q     = defilter.q;
    assign defilter_i     = defilter.i;

    assign demod_valid    = demod.valid;            
    assign demod_q        = demod.q;    
    assign demod_i        = demod.i; 

    assign demult_valid    = demult.valid;            
    assign demult_q        = demult.q;    
    assign demult_i        = demult.i; 

    assign  qam.valid     = qam_valid;
    assign  qam.data      = qam_data;

    qam_cordic inst_qam_cordic (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .cor_en(cor_en), .cor(cor));

    qam_demult inst_qam_demult (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .qam(qam), .cor(cor), .demult(demult));

    qam_defilter inst_qam_defilter (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .demult(demult), .defilter(defilter));

    qam_demod inst_qam_demod
        (
            .axi_clk    (axi_clk),
            .axi_rstn   (axi_rstn),
            .defilter   (defilter),
            .demod      (demod),
            .dout_valid (dout_valid),
            .dout       (dout)
        );


endmodule : qam_demod_top_for_data_export 