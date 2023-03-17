`timescale 1ns/1ns

module qam_mult_dsp 
    (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // synchronous reset active low
    qam_internal_port.pin           filter, 
    qam_carrier.pin                 cor,
    qam_port.pout                   qam        
);
    import parameter_def ::*;
/*------------------------------------------------------------------------------
--  Time synchronization
------------------------------------------------------------------------------*/
localparam FILTER_SHIFT_WIDTH = 2;  //  This parameter is associate with 【system frequency / filter sample frequency】
logic   [FILTER_SHIFT_WIDTH-1 : 0] filter_valid_shift = '0;

always_ff @(posedge axi_clk) begin
    if(!axi_rstn) begin
        filter_valid_shift <= '0; 
    end else begin
        filter_valid_shift <= {filter_valid_shift[FILTER_SHIFT_WIDTH-2 : 0], filter.valid};
    end
end

// filter data sync with valid 
logic   [FILTER_WIDTH-1 : 0]    filter_q = '0;
logic   [FILTER_WIDTH-1 : 0]    filter_i = '0;

always_ff @(posedge axi_clk) begin 
    filter_q <= filter.q;
    filter_i <= filter.i;
end

// wait for carrier zero flag to start modulation
logic   modulate_en =   '0;
always_ff @(posedge axi_clk) begin 
    if(|filter_valid_shift && cor.zero) begin
        modulate_en <= 1;
    end else if (filter_valid_shift == 0) begin
        modulate_en <= 0;
    end
    else
        modulate_en <= modulate_en;
end

qam_internal_port #(.WIDTH(FILTER_WIDTH)) sync();

xpm_fifo_sync #(
   .FIFO_READ_LATENCY(1),     // DECIMAL
   .FIFO_WRITE_DEPTH(64),     // DECIMAL
   .READ_DATA_WIDTH(FILTER_WIDTH),      // DECIMAL
   .READ_MODE("std"),        // String
   .USE_ADV_FEATURES("1010"), // String
   .WRITE_DATA_WIDTH(FILTER_WIDTH)      // DECIMAL
)
q_sync_inst (
   .wr_clk(axi_clk),
   .rst(!axi_rstn),    

   .wr_en(|filter_valid_shift),
   .wr_ack(), 
   .din(filter_q),  

   .rd_en(modulate_en), 
   .data_valid(sync.valid),                                         
   .dout(sync.q),  

   .empty(),                                                                                        
   .full()                                                         
);

xpm_fifo_sync #(
   .FIFO_READ_LATENCY(1),     // DECIMAL
   .FIFO_WRITE_DEPTH(64),     // DECIMAL
   .READ_DATA_WIDTH(FILTER_WIDTH),      // DECIMAL
   .READ_MODE("std"),        // String
   .USE_ADV_FEATURES("1010"), // String
   .WRITE_DATA_WIDTH(FILTER_WIDTH)      // DECIMAL
)
i_sync_inst (
   .wr_clk(axi_clk),
   .rst(!axi_rstn),    

   .wr_en(|filter_valid_shift),
   .wr_ack(), 
   .din(filter_i),  

   .rd_en(modulate_en), 
   .data_valid(),                                         
   .dout(sync.i),  

   .empty(),                                                                                        
   .full()                                                         
);
/*------------------------------------------------------------------------------
--  Q channel   
    sin : 1Q6   -Q*sin
------------------------------------------------------------------------------*/
logic   signed  [(CARRIER_WIDTH+FILTER_WIDTH-1):0]  q_mult,i_mult;

dsp_t dsp_q (
  .CLK(axi_clk),  // input wire CLK
  .A(sync.q),   // input wire [9 : 0] A
  .B(-cor.sin),       // input wire [7 : 0] B
  .P(q_mult)      // output wire [17 : 0] P
);

/*------------------------------------------------------------------------------
--  I channel
    cos : 1Q6   I*cos
------------------------------------------------------------------------------*/
dsp_t dsp_i (
  .CLK(axi_clk),  // input wire CLK
  .A(sync.i),   // input wire [9 : 0] A
  .B(cor.cos),       // input wire [7 : 0] B
  .P(i_mult)      // output wire [17 : 0] P
);

/*------------------------------------------------------------------------------
--  qam.data = I*cos - Q*sin
------------------------------------------------------------------------------*/
    logic   signed  [QAM_WIDTH-1:0]  qam_sum;
    always_ff @(posedge axi_clk) begin
        if(!axi_rstn) begin
            qam.valid <= '0;
            qam_sum   <= '0;
        end else begin
            qam.valid <= sync.valid;
            qam_sum   <= q_mult[(CARRIER_WIDTH+FILTER_WIDTH-1) : (CARRIER_WIDTH+FILTER_WIDTH-1-MULT_WIDTH)] 
                       + i_mult[(CARRIER_WIDTH+FILTER_WIDTH-1) : (CARRIER_WIDTH+FILTER_WIDTH-1-MULT_WIDTH)];
        end
    end
    assign  qam.data  = qam_sum;
endmodule : qam_mult_dsp