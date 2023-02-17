
`timescale 1ns/1ps

module qam_mod (
    input   logic                   axi_clk,    // Clock
    input   logic                   axi_rstn,    // reser
    input   logic                   cor_zero,
    input   logic                   din_valid,
    output  logic                   din_ready,
    input   logic           [3:0]   din,        // data in : 16-QAM carry 4-bit
    qam_internal_port.pout          mod
);
    assign  din_ready   =   cor_zero;

    always_ff @(posedge axi_clk) begin
        if(!axi_rstn || !din_valid) begin
            mod.q       <= '0;
            mod.i       <= '0;
            mod.valid   <= '0;
        end else begin
            mod.valid   <= '1;
            // I-out 
            unique0 case (din[3:2]) 
                2'b00   : mod.i <=  -3;
                2'b01   : mod.i <=  -1;
                2'b11   : mod.i <=   1;
                2'b10   : mod.i <=   3;                
                default : $display("TIME %d ns, Error : wrong input data type in I channel din[3:2]: %b",$time, din[3:2]);
            endcase

            // Q-out 
            unique0 case (din[1:0]) 
                2'b00   : mod.q <=   3;
                2'b01   : mod.q <=   1;
                2'b11   : mod.q <=  -1;
                2'b10   : mod.q <=  -3;                
                default : $display("TIME %d ns, Error : wrong input data type in Q channel din[1:0] : %b",$time, din[1:0]);
            endcase            
        end
    end

endmodule : qam_mod