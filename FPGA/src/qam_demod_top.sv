`timescale 1ns/1ns

module qam_demod_top (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // synchronous reset active low
    input   logic                   qam_valid,
    input   logic   signed  [9:0]   qam_in,     // data format : 3Q6    
    output  logic                   dout_valid,   
    output  logic           [3:0]   dout,
    output  logic                   demult_valid,
    output  logic   signed  [17:0]  demult_q,   // data format : 5Q12
    output  logic   signed  [17:0]  demult_i    // data format : 5Q12
);

    logic   signed  [7:0]   sin,cos;
    logic   signed  [17:0]  demult_q,demult_i;
    logic   signed  [31:0]  filter_q,filter_i;
    assign  cor_en = qam_valid;

    qam_cordic inst_qam_cordic
        (
            .axi_clk   (axi_clk),
            .axi_rstn  (axi_rstn),
            .cor_en    (cor_en),
            .cor_valid (cor_valid),
            .cor_zero  (cor_zero),
            .sin       (sin),
            .cos       (cos)
        );

    qam_demult inst_qam_demult
        (
            .axi_clk      (axi_clk),
            .axi_rstn     (axi_rstn),
            .qam_valid    (qam_valid),
            .qam_in       (qam_in),
            .cor_valid    (cor_valid),
            .sin          (sin),
            .cos          (cos),
            .demult_valid (demult_valid),
            .demult_q     (demult_q),
            .demult_i     (demult_i)
        );

    qam_filter inst_qam_filter
        (
            .axi_clk       (axi_clk),
            .axi_rstn      (axi_rstn),
            .demult_valid  (demult_valid),
            .demult_q      (demult_q),
            .demult_i      (demult_i),
            .filter_qvalid (filter_qvalid),
            .filter_q      (filter_q),
            .filter_ivalid (filter_ivalid),
            .filter_i      (filter_i)
        );

    qam_demod inst_qam_demod
        (
            .axi_clk       (axi_clk),
            .axi_rstn      (axi_rstn),
            .filter_qvalid (filter_qvalid),
            .filter_q      (filter_q),
            .filter_ivalid (filter_ivalid),
            .filter_i      (filter_i),
            .dout_valid    (dout_valid),
            .dout          (dout)
        );
endmodule : qam_demod_top