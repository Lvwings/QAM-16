`timescale 1ns/1ns

module qam_demult 
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // reset
    qam_port.pin                    qam,        // data format : 4Q8   
    qam_carrier.pin                 cor,
    qam_internal_port.pout          demult      // data format : 5Q8
);
    import parameter_def ::*; 
/*------------------------------------------------------------------------------
--  Time synchronization : wait for CORDIC ZERO phase
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Enables sync.valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
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
// |   Setting USE_ADV_FEATURES[12] to 1 enables sync.valid flag; Default value of this bit is 0                         |
// +---------------------------------------------------------------------------------------------------------------------+
------------------------------------------------------------------------------*/

qam_port #(.WIDTH(QAM_WIDTH))   sync();

// Wait for carrier zero flag to make the qam data sync carrier. 
logic   demodulate_en =   '0;
always_ff @(posedge axi_clk) begin 
    if(qam.valid && cor.valid && cor.zero) begin
        demodulate_en <= 1;
    end else if (!qam.valid || !cor.valid) begin
        demodulate_en <= 0;
    end
    else
        demodulate_en <= demodulate_en;
end

// Attention to FIFO_WRITE_DEPTH : FIFO_WRITE_DEPTH * wr_clk >= carrier period . Otherwise the fifo may overflow in some cases.
xpm_fifo_sync #(
   .FIFO_READ_LATENCY(1),     // DECIMAL
   .FIFO_WRITE_DEPTH(64),     // DECIMAL
   .READ_DATA_WIDTH(QAM_WIDTH),      // DECIMAL
   .READ_MODE("std"),        // String
   .USE_ADV_FEATURES("1010"), // String
   .WRITE_DATA_WIDTH(QAM_WIDTH)      // DECIMAL
)
xpm_fifo_sync_inst (
   .wr_clk(axi_clk),
   .rst(!axi_rstn),    

   .wr_en(qam.valid),
   .wr_ack(), 
   .din(qam.data),  

   .rd_en(demodulate_en), 
   .data_valid(sync.valid),                                         
   .dout(sync.data),  

   .empty(),                                                                                        
   .full()                                                         
);

/*------------------------------------------------------------------------------
--  dumult data & valid sync, considering the lentency of DSP
------------------------------------------------------------------------------*/
localparam  DSP_LENTENCY  = 4;
logic [DSP_LENTENCY : 0]  demult_valid_shift  = '0;

always_ff @(posedge axi_clk) begin 
      demult_valid_shift  <=  {demult_valid_shift[DSP_LENTENCY-1 : 0],sync.valid};    
end
assign  demult.valid      =  demult_valid_shift[DSP_LENTENCY];
/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
logic   signed  [(QAM_WIDTH+CARRIER_WIDTH-1):0]  demult_q;
dsp dsp_q (
  .CLK(axi_clk),    // input wire CLK
  .A(sync.data),       // input wire [12 : 0] A
  .B(-cor.sin),         // input wire [7 : 0] B
  .P(demult_q)      // output wire [20 : 0] P
);
assign  demult.q = demult_q[(QAM_WIDTH+CARRIER_WIDTH-1):(QAM_WIDTH+CARRIER_WIDTH-1-DEMULT_WIDTH)];
/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
logic   signed  [(QAM_WIDTH+CARRIER_WIDTH-1):0]  demult_i;
dsp dsp_i (
  .CLK(axi_clk),    // input wire CLK
  .A(sync.data),       // input wire [12 : 0] A
  .B(cor.cos),          // input wire [7 : 0] B
  .P(demult_i)      // output wire [20 : 0] P
);
assign  demult.i = demult_i[(QAM_WIDTH+CARRIER_WIDTH-1):(QAM_WIDTH+CARRIER_WIDTH-1-DEMULT_WIDTH)];

endmodule : qam_demult