
`timescale 1ns/1ps


module tb_qam_mod_top_for_data_export (); /* this is automatically generated */

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
        #10
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
    logic               qam_valid;
    logic signed [17:0] qam_data;
    logic               mod_valid;
    logic  signed [2:0] mod_q;
    logic  signed [2:0] mod_i;
    logic               cor_valid;
    logic  signed [7:0] sin;
    logic  signed [7:0] cos;
    logic               filter_valid;
    logic signed [14:0] filter_q;
    logic signed [14:0] filter_i;

    qam_mod_top_for_data_export inst_qam_mod_top_for_data_export
        (
            .axi_clk      (axi_clk),
            .axi_rstn     (axi_rstn),
            .din_valid    (din_valid),
            .din          (din),
            .din_ready    (din_ready),
            .qam_valid    (qam_valid),
            .qam_data     (qam_data),
            .mod_valid    (mod_valid),
            .mod_q        (mod_q),
            .mod_i        (mod_i),
            .cor_valid    (cor_valid),
            .sin          (sin),
            .cos          (cos),
            .filter_valid (filter_valid),
            .filter_q     (filter_q),
            .filter_i     (filter_i)
        );

    task init();
        din_valid <= '0;
        din       <= '0;
    endtask


    logic [6:0] cnt = 0;

    initial begin
        // do something
        init();
        repeat(128) @(posedge axi_clk);
        wait(din_ready);
        din_valid   <=  1;
        do begin                                  
            if (cnt == 64)
                din_valid   <=  0;
            else
                din <= $random()%16;
            repeat(16) @(posedge din_ready);
            cnt <= cnt + 1;
        end while (din_valid);

    end

    integer fd;
    initial begin
        fd = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/din.txt", "w");
        wait(din_valid);
        $display("din_valid assert");

        while (din_valid) begin
            @(posedge din_ready);
                $fwrite(fd,"%d\t", din);            
        end

        $fclose(fd);
    end    

    integer fmod_i,fmod_q;

    initial begin
        fmod_i = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/mod_i.txt", "w");
        fmod_q = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/mod_q.txt", "w");
        wait(mod_valid);
        $display("mod_valid assert");

        while (mod_valid) begin
            @(posedge axi_clk);
                $fwrite(fmod_i,"%d\t", $signed(mod_i));
                $fwrite(fmod_q,"%d\t", $signed(mod_q));            
        end

        $fclose(fmod_i);
        $fclose(fmod_q); 
    end

    integer ffilter_i,ffilter_q;
    logic   [5:0]   filter_valid_shift = '1;
    initial begin
        ffilter_i = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/filter_i.txt", "w");
        ffilter_q = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/filter_q.txt", "w");
        wait(filter_valid);
        $display("filter_valid assert");

        while (|filter_valid_shift) begin
            @(posedge axi_clk);
                filter_valid_shift <= {filter_valid_shift[4:0],filter_valid};
                $fwrite(ffilter_i,"%d\t", $signed(filter_i));
                $fwrite(ffilter_q,"%d\t", $signed(filter_q));            
        end

        $fclose(ffilter_i);
        $fclose(ffilter_q); 
    end

    integer fqam_data;

    initial begin
        fqam_data = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/qam_data.txt", "w");
        wait(qam_valid);
        $display("qam_valid assert");

        while (qam_valid) begin
            @(posedge axi_clk);
                $fwrite(fqam_data,"%d\t", $signed(qam_data));          
        end

        $fclose(fqam_data);
    end    
endmodule
