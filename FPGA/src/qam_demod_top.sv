`timescale 1ns/1ns

module qam_demod_top     
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // synchronous reset active low
    qam_internal_port.pin           qam,        // data format : 4Q8    
    output  logic                   dout_valid,   
    output  logic           [3:0]   dout
);
    
    import parameter_def ::*;

    qam_internal_port #(.WIDTH(DEMULT_WIDTH))       demult();
    qam_internal_port #(.WIDTH(DEFILTER_WIDTH))     defilter();
    qam_carrier #(.WIDTH(CARRIER_WIDTH))            cor();

    assign  cor_en = qam.valid;


    qam_cordic inst_qam_cordic (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .cor_en(cor_en), .cor(cor));

    qam_demult inst_qam_demult (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .qam(qam), .cor(cor), .demult(demult));

    qam_defilter inst_qam_defilter (.axi_clk(axi_clk), .axi_rstn(axi_rstn), .demult(demult), .defilter(defilter));

    qam_demod inst_qam_demod
        (
            .axi_clk    (axi_clk),
            .axi_rstn   (axi_rstn),
            .defilter   (defilter),
            .dout_valid (dout_valid),
            .dout       (dout)
        );

endmodule : qam_demod_top