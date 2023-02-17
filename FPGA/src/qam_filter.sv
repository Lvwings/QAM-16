`timescale 1ns/1ns

module qam_filter (
    input   logic                   axi_clk,        // Clock
    input   logic                   axi_rstn,       // reset
    qam_internal_port.pin           mod,  
    qam_internal_port.pout          filter      // data format : 14Q0 
);

/*------------------------------------------------------------------------------
--  SR FIR 
    data rate       : 0.3125M
    sample frequncy : 31.25M
    cutoff frequncy : 0.15625M

    s_axis_data_tdata : 2Q0   REAL[2:0]
    m_axis_data_tdata : 14Q0 REAL[14:0]

    start-up latency  : 20
------------------------------------------------------------------------------*/

fir_compiler fir_q (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(mod.valid),           // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(mod.q),                 // input wire [7 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(filter.valid),        // output wire m_axis_data_tvalid
  .m_axis_data_tdata(filter.q)              // output wire [15 : 0] m_axis_data_tdata
);

fir_compiler fir_i (
  .aresetn(axi_rstn),                        // input wire aresetn
  .aclk(axi_clk),                           // input wire aclk
  .s_axis_data_tvalid(mod.valid),           // input wire s_axis_data_tvalid
  .s_axis_data_tready(),                    // output wire s_axis_data_tready
  .s_axis_data_tdata(mod.i),                 // input wire [7 : 0] s_axis_data_tdata
  .m_axis_data_tvalid(),                    // output wire m_axis_data_tvalid
  .m_axis_data_tdata(filter.i)              // output wire [15 : 0] m_axis_data_tdata
);
endmodule : qam_filter


