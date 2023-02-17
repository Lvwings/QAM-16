`timescale 1ns/1ns

module qam_defilter (
    input   logic                   axi_clk,        // Clock
    input   logic                   axi_rstn,       // reset
    qam_internal_port.pin           demult,         // data format : 5Q8
    qam_internal_port.pout          defilter        // data format : 4Q8 
);

/*------------------------------------------------------------------------------
--  SR FIR 
    data rate       : 0.3125M
    sample frequncy : 31.25M
    cutoff frequncy : 0.15625M

    s_axis_data_tdata : 19Q0  REAL[19:0]
    m_axis_data_tdata : 31Q0  REAL[31:0]

    start-up latency  : 20
------------------------------------------------------------------------------*/

defir_compiler fir_q (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(demult.valid),        // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(demult.q),             // input wire [23 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(defilter.valid),       // output wire m_axis_data_tvalid
  .m_axis_data_tdata(defilter.q)              // output wire [31 : 0] m_axis_data_tdata
);

defir_compiler fir_i (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(demult.valid),        // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(demult.i),             // input wire [23 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(defilter.valid),       // output wire m_axis_data_tvalid
  .m_axis_data_tdata(defilter.i)              // output wire [31 : 0] m_axis_data_tdata
);
endmodule : qam_defilter


