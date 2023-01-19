
`timescale 1ns/1ns

module qam_cordic (
    input   logic                   axi_clk,      // Clock
    input   logic                   axi_rstn,      // synchronous reset active low
    input   logic                   cor_en,
    output  logic                   cor_valid,
    output  logic                   cor_zero,
    output  logic   signed  [7:0]   sin,
    output  logic   signed  [7:0]   cos    
);

/*------------------------------------------------------------------------------
 --  CORDIC SIN & COS
 input  data format : 2QN
 output data format : 1QN
 ------------------------------------------------------------------------------*/ 
    logic   signed  [5:0]   tdata   =   '0;
    logic                   tvalid  =   '0;

    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn || !cor_en) begin
            tdata   <= '0;
            tvalid  <= '0;
        end else begin
            tdata   <= tdata + 1;
            tvalid  <= 1;
        end
    end

/*------------------------------------------------------------------------------
--  cor_zero
------------------------------------------------------------------------------*/
    localparam  COR_ODELAY  =   12;

    always_ff @(posedge axi_clk) begin 
        if(~axi_rstn) begin
            cor_zero   <= '0;

        end else begin
            cor_zero   <= (tdata == COR_ODELAY-1);
        end
    end    

cordic_0 cordic (
  .aclk                 (axi_clk),      // input wire aclk
  .aresetn              (axi_rstn),     // input wire aresetn
  .s_axis_phase_tvalid  (tvalid),       // input wire s_axis_phase_tvalid
  .s_axis_phase_tdata   (8'(tdata)),        // input wire [7 : 0] s_axis_phase_tdata
  .m_axis_dout_tvalid   (cor_valid),    // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata    ({sin,cos})     // output wire [15 : 0] m_axis_dout_tdata
);

endmodule : qam_cordic