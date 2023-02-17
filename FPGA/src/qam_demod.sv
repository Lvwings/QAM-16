`timescale 1ns/1ns

module qam_demod 
    (
    input   logic                   axi_clk,        // Clock
    input   logic                   axi_rstn,       // synchronous reset active low
    qam_internal_port.pin           defilter,   
    qam_internal_port.pout          demod,
    output  logic                   dout_valid,   
    output  logic           [3:0]   dout
);
    import parameter_def ::*; 

    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_P3    =   230;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_P1    =   20;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_N1    =   -180;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_N3    =   -500;

/*------------------------------------------------------------------------------
--  valid
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin
        demod.valid <= defilter.valid;
    end
    
/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn) begin
            demod.q <= '0;
        end else begin
            if (defilter.valid) begin   // [DEFILTER_WIDTH-1:FRANCTIONAL_BIT]
                priority if (signed'(defilter.q) < LIMIT_N1)  demod.q <= -3;
                    else if (signed'(defilter.q) < LIMIT_P1)  demod.q <= -1;
                    else if (signed'(defilter.q) < LIMIT_P3)  demod.q <= 1;
                    else                                      demod.q <= 3;  
            end                                 
            else                                              demod.q <= demod.q;
        end
    end
/*------------------------------------------------------------------------------
--  I channel
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn) begin
            demod.i <= '0;
        end else begin
            if (defilter.valid) begin
                priority if (signed'(defilter.i) < LIMIT_N1)  demod.i <= -3;
                    else if (signed'(defilter.i) < LIMIT_P1)  demod.i <= -1;
                    else if (signed'(defilter.i) < LIMIT_P3)  demod.i <= 1;
                    else                                      demod.i <= 3;  
            end                                 
            else                                              demod.i <= demod.i;
        end
    end

/*------------------------------------------------------------------------------
--  dout
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn) begin
            dout        <= '0;
            dout_valid  <= '0;
        end else begin
            dout_valid  <= demod.valid ? 1 : dout_valid;
            if (demod.valid) begin
                 unique0 case (demod.i)
                    -3'sd3  : dout[3:2] <=  2'b00;
                    -3'sd1  : dout[3:2] <=  2'b01;
                    3'sd1   : dout[3:2] <=  2'b11;
                    3'sd3   : dout[3:2] <=  2'b10;
                    default : $display("TIME %d ns, Error : wrong data in i channel demod.i : %b",$time, demod.i);
                endcase
                                
                unique0 case (demod.q)
                    3'sd3   : dout[1:0] <=  2'b00;
                    3'sd1   : dout[1:0] <=  2'b01;
                    -3'sd1  : dout[1:0] <=  2'b11;
                    -3'sd3  : dout[1:0] <=  2'b10;
                    default : $display("TIME %d ns, Error : wrong data in q channel demod.q : %b",$time, demod.q);
                endcase
            end
            else              dout <= dout;
        end
    end
endmodule : qam_demod