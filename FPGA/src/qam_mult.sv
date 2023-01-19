`timescale 1ns/1ns

module qam_mult (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,   // synchronous reset active low
    input   logic                   mod_valid,
    input   logic   signed  [2:0]   mod_q,      // Q channel
    input   logic   signed  [2:0]   mod_i,      // I channel    
    input   logic                   cor_valid,
    input   logic   signed  [7:0]   sin,
    input   logic   signed  [7:0]   cos,
    output  logic                   qam_valid,
    output  logic   signed  [9:0]   qam_out         
);

/*------------------------------------------------------------------------------
--  I channel
    cos : 1Q6   I*cos
------------------------------------------------------------------------------*/
    logic   signed  [8:0]   i_out   =   '0;
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn || !cor_valid || !mod_valid) begin
            i_out <= '0;
        end else begin
            unique case (mod_i)
                 3'sd3  : i_out <=  8'(cos) + (8'(cos) << 1);
                 3'sd1  : i_out <=  8'(cos);
                -3'sd1  : i_out <=  -(8'(cos));
                -3'sd3  : i_out <=  -(8'(cos) + (8'(cos) << 1));
                default : $display("TIME %d ns, Error : wrong input data in I channel mod_i : %b",$time, mod_i);
            endcase
        end
    end
/*------------------------------------------------------------------------------
--  Q channel   
    sin : 1Q6   -Q*sin
------------------------------------------------------------------------------*/
    logic   signed  [8:0]   q_out   =   '0;
    always_ff @(posedge axi_clk) begin 
        if(!axi_rstn || !cor_valid || !mod_valid) begin
            q_out <= '0;
        end else begin
            unique case (mod_q)
                -3'sd3   : q_out <=  8'(sin) + (8'(sin) << 1);
                -3'sd1   : q_out <=  8'(sin);
                 3'sd1   : q_out <=  -(8'(sin));
                 3'sd3   : q_out <=  -(8'(sin) + (8'(sin) << 1));
                default : $display("TIME %d ns, Error : wrong input data in Q channel mod_q : %b",$time, mod_q);
            endcase
        end
    end
/*------------------------------------------------------------------------------
--  qam_out = I*cos - Q*sin
------------------------------------------------------------------------------*/
    always_ff @(posedge axi_clk) begin 
        if (!axi_rstn || !cor_valid || !mod_valid) begin
            qam_valid   <=  '0;
            qam_out     <=  '0;
        end
        else begin
            qam_valid   <=  1;
            qam_out     <=  i_out + q_out;            
        end
    end
    

endmodule : qam_mult