
`timescale 1ns/1ns

module tb_qam_mod (); /* this is automatically generated */

    // clock
    logic axi_clk;
    initial begin
        axi_clk = '0;
        forever #(0.5) axi_clk = ~axi_clk;
    end

    // asynchronous reset
    logic axi_rstn;
    initial begin
        axi_rstn <= '0;
        #10
        axi_rstn <= '1;
    end

    // synchronous reset
    logic axi_rst;
    initial begin
        axi_rst <= '1;
        repeat(10)@(posedge axi_clk);
        axi_rst <= '0;
    end

    // (*NOTE*) replace reset, clock, others

    logic signed [3:0] data_in;
    logic signed [2:0] qam_q;
    logic signed [2:0] qam_i;

    qam_mod inst_qam_mod
        (
            .axi_clk (axi_clk),
            .axi_rstn (axi_rstn),
            .data_in (data_in),
            .qam_q   (qam_q),
            .qam_i   (qam_i)
        );

    task init();
        data_in <= '0;
    endtask


    logic [7:0] cnt = '0;
    initial begin
        // do something
        init();

        repeat(100) @(posedge axi_clk);

        do begin
            @(posedge axi_clk);
            cnt <= cnt + 1;
            if (&cnt)
                data_in <= 4'b01zx;
            else
                data_in <= $random()%16;
        end while (1);

    end



endmodule
