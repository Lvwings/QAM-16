`timescale 1ns/1ns

module qam_demult (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    input   logic                   qam_valid,
    input   logic   signed  [9:0]   qam_in,     // data format : 3Q6
    input   logic                   cor_valid,
    input   logic   signed  [7:0]   sin,        // data format : 1Q6
    input   logic   signed  [7:0]   cos,
    output  logic                   demult_valid,
    output  logic   signed  [17:0]  demult_q,   // data format : 5Q12
    output  logic   signed  [17:0]  demult_i    // data format : 5Q12
    
);
/*------------------------------------------------------------------------------
--  wait for CORDIC ZERO phase
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Enables data_valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
// | prog_full, overflow features.                                                                                       |
// |                                                                                                                     |
// |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag; Default value of this bit is 1                            |
// |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[2] to 1 enables wr_data_count; Default value of this bit is 1                            |
// |   Setting USE_ADV_FEATURES[3] to 1 enables almost_full flag; Default value of this bit is 0                         |
// |   Setting USE_ADV_FEATURES[4] to 1 enables wr_ack flag; Default value of this bit is 0                              |
// |   Setting USE_ADV_FEATURES[8] to 1 enables underflow flag; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[9] to 1 enables prog_empty flag; Default value of this bit is 1                          |
// |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag; Default value of this bit is 0                         |
// +---------------------------------------------------------------------------------------------------------------------+
------------------------------------------------------------------------------*/
logic signed  [9:0]   qam_sync; 
logic                 data_valid; 

xpm_fifo_sync #(
   .FIFO_READ_LATENCY(1),     // DECIMAL
   .FIFO_WRITE_DEPTH(32),     // DECIMAL
   .READ_DATA_WIDTH(10),      // DECIMAL
   .READ_MODE("std"),        // String
   .USE_ADV_FEATURES("1010"), // String
   .WRITE_DATA_WIDTH(10)      // DECIMAL
)
xpm_fifo_sync_inst (
   .wr_clk(axi_clk),
   .rst(!axi_rstn),    

   .wr_en(qam_valid),
   .wr_ack(), 
   .din(qam_in),  

   .rd_en(cor_valid), 
   .data_valid(data_valid),                                         
   .dout(qam_sync),  

   .empty(),                                                                                        
   .full()                                                         
);

/*------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------*/
localparam  DSP_LENTENCY  = 4;
logic [DSP_LENTENCY : 0]  demult_valid_shift  = '0;

always_ff @(posedge axi_clk) begin 
      demult_valid_shift  <=  {demult_valid_shift[DSP_LENTENCY-1 : 0],data_valid};    
end
assign  demult_valid      =  demult_valid_shift[DSP_LENTENCY];
/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
dsp dsp_q (
  .CLK(axi_clk),    // input wire CLK
  .A(qam_sync),       // input wire [9 : 0] A
  .B(-sin),         // input wire [7 : 0] B
  .P(demult_q)      // output wire [17 : 0] P
);

/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
dsp dsp_i (
  .CLK(axi_clk),    // input wire CLK
  .A(qam_sync),       // input wire [9 : 0] A
  .B(cos),          // input wire [7 : 0] B
  .P(demult_i)      // output wire [17 : 0] P
);


endmodule : qam_demult