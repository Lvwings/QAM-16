`timescale 1ns/1ns

module qam_demod (
    input   logic                   axi_clk,        // Clock
    input   logic                   axi_rstn,       // synchronous reset active low
    input   logic                   filter_qvalid,
    input   logic   signed  [31:0]  filter_q,       // data format : 18Q12 
    input   logic                   filter_ivalid,
    input   logic   signed  [31:0]  filter_i,       // data format : 18Q12  
    output  logic                   dout_valid,   
    output  logic           [3:0]   dout
);

    localparam  signed [19:0] LIMIT_P3    =   2000;
    localparam  signed [19:0] LIMIT_P1    =   0;
    localparam  signed [19:0] LIMIT_N1    =   -4000;
    localparam  signed [19:0] LIMIT_N3    =   -8000;

/*------------------------------------------------------------------------------
--  valid
------------------------------------------------------------------------------*/
    logic   demod_valid     =   '0;
    always_ff @(posedge axi_clk) begin
        demod_valid <= filter_qvalid && filter_ivalid;
    end
    
/*------------------------------------------------------------------------------
--  Q channel
------------------------------------------------------------------------------*/
    logic signed [2:0]  demod_q =   '0;
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn) begin
            demod_q <= '0;
        end else begin
            if (demod_valid) begin
                priority if (signed'(filter_q[31:12]) < LIMIT_N1)    demod_q <= -3;
                    else if (signed'(filter_q[31:12]) < LIMIT_P1)    demod_q <= -1;
                    else if (signed'(filter_q[31:12]) < LIMIT_P3)    demod_q <= 1;
                    else                                    demod_q <= 3;  
            end
            else                                            demod_q <= demod_q;
        end
    end
/*------------------------------------------------------------------------------
--  I channel
------------------------------------------------------------------------------*/
    logic signed [2:0]  demod_i =   '0;
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn) begin
            demod_i <= '0;
        end else begin
            if (demod_valid) begin
                priority if (signed'(filter_i[31:12]) < LIMIT_N1)    demod_i <= -3;
                    else if (signed'(filter_i[31:12]) < LIMIT_P1)    demod_i <= -1;
                    else if (signed'(filter_i[31:12]) < LIMIT_P3)    demod_i <= 1;
                    else                                    demod_i <= 3;  
            end
            else                                            demod_i <= demod_i;
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
            dout_valid  <= demod_valid ? 1 : dout_valid;
            if (demod_valid) begin
                unique0 case (demod_q)
                    3'sd3   : dout[3:2] <=  2'b01;
                    3'sd1   : dout[3:2] <=  2'b11;
                    -3'sd1  : dout[3:2] <=  2'b10;
                    -3'sd3  : dout[3:2] <=  2'b00;
                    default : $display("TIME %d ns, Error : wrong data in q channel demod_q : %b",$time, demod_q);
                endcase

                 unique0 case (demod_i)
                    3'sd3   : dout[1:0] <=  2'b01;
                    3'sd1   : dout[1:0] <=  2'b11;
                    -3'sd1  : dout[1:0] <=  2'b10;
                    -3'sd3  : dout[1:0] <=  2'b00;
                    default : $display("TIME %d ns, Error : wrong data in i channel demod_i : %b",$time, demod_i);
                endcase
            end
            else              dout <= dout;

        end
    end
endmodule : qam_demod