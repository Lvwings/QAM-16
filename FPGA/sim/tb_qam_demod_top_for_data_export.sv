
`timescale 1ns/1ps

module tb_qam_demod_top_for_data_export (); /* this is automatically generated */

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
    import parameter_def ::*;
    logic    signed [QAM_WIDTH-1 : 0] qam_data;
    logic                             qam_valid;
    logic                             dout_valid;
    logic                       [3:0] dout;
    logic                             demod_valid;
    logic      signed [MOD_WIDTH-1:0] demod_q;
    logic      signed [MOD_WIDTH-1:0] demod_i;
    logic                             demult_valid;
    logic   signed [DEMULT_WIDTH-1:0] demult_q;
    logic   signed [DEMULT_WIDTH-1:0] demult_i;
    logic                             cor_valid;
    logic  signed [CARRIER_WIDTH-1:0] sin;
    logic  signed [CARRIER_WIDTH-1:0] cos;
    logic                             defilter_valid;
    logic signed [DEFILTER_WIDTH-1:0] defilter_q;
    logic signed [DEFILTER_WIDTH-1:0] defilter_i;

    qam_demod_top_for_data_export inst_qam_demod_top_for_data_export
        (
            .axi_clk        (axi_clk),
            .axi_rstn       (axi_rstn),
            .qam_data       (qam_data),
            .qam_valid      (qam_valid),
            .dout_valid     (dout_valid),
            .dout           (dout),
            .demod_valid    (demod_valid),
            .demod_q        (demod_q),
            .demod_i        (demod_i),
            .demult_valid   (demult_valid),
            .demult_q       (demult_q),
            .demult_i       (demult_i),
            .cor_valid      (cor_valid),
            .sin            (sin),
            .cos            (cos),
            .defilter_valid (defilter_valid),
            .defilter_q     (defilter_q),
            .defilter_i     (defilter_i)
        );

    task init();
        qam_data  <= '0;
        qam_valid <= '0;
    endtask

    integer fqam;
    initial begin
        init();
        // fpga data : qam_data // matlab data : tx_qam
        fqam = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/qam_data.txt", "r");  // qam_data

        wait(axi_rstn);
        repeat(50) @(posedge axi_clk);

        while (!$feof(fqam)) begin
            @(posedge axi_clk);
            $fscanf(fqam,"%d",qam_data);
            //qam_data    <= $fgetc(fqam);
            qam_valid   <= 1;                 
        end

        qam_data  = '0;
        qam_valid = '0;  
             
        $fclose(fqam);
    end    


    integer fdemod_i,fdemod_q;

    initial begin
        fdemod_i = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demod_i.txt", "w");
        fdemod_q = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demod_q.txt", "w");
        wait(demod_valid);
        $display("demod_valid assert");

        while (demod_valid) begin
            @(posedge axi_clk);
                $fwrite(fdemod_i,"%d\t", $signed(demod_i));
                $fwrite(fdemod_q,"%d\t", $signed(demod_q));            
        end

        $fclose(fdemod_i);
        $fclose(fdemod_q); 
    end

    integer fdemult_i,fdemult_q;

    initial begin
        fdemult_i = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demult_i.txt", "w");
        fdemult_q = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demult_q.txt", "w");
        wait(demult_valid);
        $display("demult_valid assert");

        while (demult_valid) begin
            @(posedge axi_clk);
                $fwrite(fdemult_i,"%d\t", $signed(demult_i));
                $fwrite(fdemult_q,"%d\t", $signed(demult_q));            
        end

        $fclose(fdemult_i);
        $fclose(fdemult_q); 
    end
    
    integer fdefilter_i,fdefilter_q;
    logic   [5:0]   defilter_valid_shift = '1;
    initial begin
        fdefilter_i = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/defilter_i.txt", "w");
        fdefilter_q = $fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/defilter_q.txt", "w");
        wait(defilter_valid);
        $display("defilter_valid assert");

        while (|defilter_valid_shift) begin
            @(posedge axi_clk);
                defilter_valid_shift <= {defilter_valid_shift[4:0],defilter_valid};
                $fwrite(fdefilter_i,"%d\t", $signed(defilter_i));
                $fwrite(fdefilter_q,"%d\t", $signed(defilter_q));            
        end

        $fclose(fdefilter_i);
        $fclose(fdefilter_q); 
    end
endmodule
