`timescale 1ns/1ns

module qam_filter (
    input   logic                   axi_clk,        // Clock
    input   logic                   axi_rstn,       // reset
    input   logic                   demult_valid,
    input   logic   signed  [17:0]  demult_q,       // data format : 5Q12
    input   logic   signed  [17:0]  demult_i,       // data format : 5Q12 
    output  logic                   filter_qvalid,
    output  logic   signed  [31:0]  filter_q,       // data format : 18Q12 
    output  logic                   filter_ivalid,
    output  logic   signed  [31:0]  filter_i        // data format : 18Q12 
);

/*------------------------------------------------------------------------------
--  Lowpass FIR 
    sample frequncy : 100M
    pass frequncy : 3.15M
    stop frequncy : 10M

    s_axis_data_tdata : 5Q12  REAL[17:0]
    m_axis_data_tdata : 18Q12 REAL[30:0]
------------------------------------------------------------------------------*/

fir_compiler fir_q (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(demult_valid),        // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(demult_q),             // input wire [23 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(filter_qvalid),       // output wire m_axis_data_tvalid
  .m_axis_data_tdata(filter_q)              // output wire [31 : 0] m_axis_data_tdata
);

fir_compiler fir_i (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(demult_valid),        // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(demult_i),             // input wire [23 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(filter_ivalid),       // output wire m_axis_data_tvalid
  .m_axis_data_tdata(filter_i)              // output wire [31 : 0] m_axis_data_tdata
);
endmodule : qam_filter


