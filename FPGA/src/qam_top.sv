`timescale 1ns/1ns

module qam_top 
    import parameter_def ::*;  
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   din_valid,
    input   logic           [3:0]   din,        // data in : 16-QAM carry 4-bit
    output  logic                   din_ready 
);

    qam_port    qam();

    qam_mod_top inst_qam_mod_top
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .din_valid (din_valid),
            .din       (din),
            .din_ready (din_ready),
            .qam       (qam)
        );


    qam_demod_top inst_qam_demod_top
        (
            .axi_clk    (axi_clk),
            .axi_rstn   (axi_rstn),
            .qam        (qam),
            .dout_valid (dout_valid),
            .dout       (dout),
            .demult_o     (demult_o)
        );






endmodule : qam_top