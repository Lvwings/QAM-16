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

    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_P3    =   70;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_P1    =   30;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_N1    =   -50;
    localparam  signed [DEFILTER_WIDTH-1:0] LIMIT_N3    =   -500;

/*------------------------------------------------------------------------------
--  valid
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin
        demod.valid <= defilter.valid;
    end
    
/*------------------------------------------------------------------------------
--  Q channel Hard solution
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
--  I channel Hard solution
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
--  Soft solution : {d3yi,d2yi,d1yq,d0yq}

    d = 46 from QAM constellation map

            
    d0yq =  2d - |yq|
             
            -yq - d     yq <= -2d
    d1yq =  -yq         yq = (-2d,2d)
            -yq + d     yq >=  2d
            
    d2yi =  2d - |yi| 
            
            yi + d      yi <= -2d       0
    d3yi =  yi          yi = (-2d,2d)
            yi - d      yi >=  2d       1
------------------------------------------------------------------------------*/
    logic       signed  [DEFILTER_WIDTH+1 : 0]  dout_soft[3:0]  = '{default: '0};
    localparam  signed  [DEFILTER_WIDTH-1 : 0]  D               = 30;

    always_ff @(posedge axi_clk) begin 
        if (defilter.valid) begin
                priority if (signed'(defilter.i) <= -2*D)   dout_soft[3] <= (defilter.i + D);
                    else if (signed'(defilter.i) <= 2*D)    dout_soft[3] <= defilter.i;
                    else                                    dout_soft[3] <= (defilter.i - D);

                priority if (signed'(defilter.i) <= 0)      dout_soft[2] <= 2*D + defilter.i;
                    else                                    dout_soft[2] <= 2*D - defilter.i; 

                priority if (signed'(defilter.q) <= -2*D)   dout_soft[1] <=  -(defilter.q + D);
                    else if (signed'(defilter.q) <= 2*D)    dout_soft[1] <=  -defilter.q;
                    else                                    dout_soft[1] <=  -(defilter.q - D);

                priority if (signed'(defilter.q) <= 0)      dout_soft[0] <= 2*D + defilter.q;
                    else                                    dout_soft[0] <= 2*D - defilter.q;                  
        end
    end
    
    logic   [3:0]   dout_s;
    assign          dout_s  =   {dout_soft[3][DEFILTER_WIDTH+1],dout_soft[2][DEFILTER_WIDTH+1],dout_soft[1][DEFILTER_WIDTH+1],dout_soft[0][DEFILTER_WIDTH+1]};
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