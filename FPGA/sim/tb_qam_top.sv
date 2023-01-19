
`timescale 1ns/1ps

module tb_qam_top (); /* this is automatically generated */

    // clock
    logic axi_clk;
    initial begin
        axi_clk = '0;
        forever #(2.5) axi_clk = ~axi_clk;
    end

    // asynchronous reset
    logic axi_rstn;
    initial begin
        axi_rstn <= '0;
        #100
        axi_rstn <= '1;
    end

    // synchronous reset
    logic axi_rst;
    initial begin
        axi_rst <= '0;
        repeat(10)@(posedge axi_clk);
        axi_rst <= '1;
    end

    // (*NOTE*) replace reset, clock, others

    logic               din_valid;
    logic         [3:0] din;
    logic               din_ready;
    logic               demult_valid;
    logic signed [17:0] demult_q;
    logic signed [17:0] demult_i;

    qam_top inst_qam_top
        (
            .axi_clk      (axi_clk),
            .axi_rstn     (axi_rstn),
            .din_valid    (din_valid),
            .din          (din),
            .din_ready    (din_ready),
            .demult_valid (demult_valid),
            .demult_q     (demult_q),
            .demult_i     (demult_i)
        );

    task init();
        din_valid <= '0;
        din       <= '0;
    endtask


    logic [9:0] cnt = '0;

    initial begin
        // do something
        init();
        repeat(128) @(posedge axi_clk);
        wait(din_ready);
        din_valid   <=  1;
        do begin                      
            cnt <= cnt + 1;
            if (&cnt)
                din_valid   <=  0;
            else
                din <= $random()%16;
            @(posedge din_ready);
        end while (din_valid);

    end
    integer fd;
    initial begin
        fd = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/din.txt", "w");
        wait(din_valid);
        $display("demult_valid assert");

        while (din_valid) begin
            @(posedge din_ready);
                $fwrite(fd,"%d\t", din);            
        end

        $fclose(fd);
    end    

    integer fi,fq;

    initial begin
        fi = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/idata.txt", "w");
        fq = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/qdata.txt", "w");
        wait(demult_valid);
        $display("demult_valid assert");

        while (demult_valid) begin
            @(posedge axi_clk);
                $fwrite(fi,"%d\t", demult_i);
                $fwrite(fq,"%d\t", demult_q);            
        end

        $fclose(fi);
        $fclose(fq); 
    end
endmodule
