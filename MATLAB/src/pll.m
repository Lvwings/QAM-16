
    clear all;
    close all;
%%
%{
    PLL : phase-locked loop

    Z域：

    vi(n) -> |E| -> err(n) -> |k0| -> vc(n) -> |LF| -> vo(n)
              |                                     |
              --------- <- sb(n) <- |VCO| <----------

    vi(n)   : 输入信号      input data
    vo(n)   : 输出信号      ouput data
    sb(n)   : VCO的反馈信号 feedback data through VCO  
    err(n)  : 相位差        phase error (fb - f)
    k0      : 增益          gain
    LF      : 环路滤波器    loop filter
    fs      : 采样率
 
%}
    
%%
%{
    输入信号定义
%}   
        
    % QAM 数据 : 使用公式 r = a + (b-a).*rand(N,1) 生成区间 (a,b) 内的 N 个随机数
    M           = 16;           % QAM Modulation order : 16-QAM (alphabet size or number of points in signal constellation)
    k           = log2(M);      % Number of bits per symbol : 16-QAM carry 4 bits  
    symbols     = 1e5;  % 码元数量 
    sps         = 4;            % Number of samples per symbol (oversampling factor)

    % 将二进制数据转换为整数值符号
    dataIn          = randi([0 15],1,symbols); % Generate vector of binary data

    % 使用 16-QAM 进行调制
    dataModG        = qammod(dataIn,M);          % Gray-encoded
%%
%{
    信号上采样
    y = upsample(x,n) 通过在样本之间插入 n - 1个零来增加 x 的采样率。如果 x 是矩阵，则该函数将每一列视为单独的序列
%}
    qdata_upsample  = upsample(imag(dataModG),sps);
    idata_upsample  = upsample(real(dataModG),sps);

%%
%{
    脉冲成型
%}
    fdata       = 1e6;    % 数据码率
    filtlen     = 10;      % Filter length in symbols
    roll_off    = 0.25;     % RRC根升余弦滤波器滚降

    % RRC 参数
    rrc_coe     = rcosdesign(roll_off,filtlen,sps,'sqrt');  % 发送端采用根升余弦滤波作为成形滤波器（脉冲成型）减少ISI
    rrc_coe     = rrc_coe/max(rrc_coe);                  % 滤波器参数归一化
    match_coe   = rrc_coe/(rrc_coe*rrc_coe');            % 接收端采用同样的匹配滤波器，并作适当缩放，让增益为1.    

    txFiltSignalF     = upfirdn(dataModG,rrc_coe,sps,1);     % 发送出的滤波 QAM 信 升采样  
    sPlotFig = scatterplot(txFiltSignalF,1,0,'g.');
    hold on
    scatterplot(dataModG,1,0,'k*',sPlotFig);  
    hold off     
    title("函数滤波");

    figure;
    subplot(2,1,1); plot(qdata_upsample); hold on; plot(imag(txFiltSignalF(length(rrc_coe)/2:end)),'r'); title("Q通道上采样"); legend('差值','RRC'); 
    subplot(2,1,2); plot(idata_upsample); hold on; plot(real(txFiltSignalF(length(rrc_coe)/2:end)),'r'); title("I通道上采样"); legend('差值','RRC');
    hold off     
%{
    添加白高斯噪声
    调制信号使信号具有指定信噪比（SNR）。SNR 将由每比特的能量与噪声的功率谱密度比值（EbNo : Eb/No）得到。本例中假设通道 Eb/No 为 10 分贝。

    awgn(x，snr，signalpower) - 将白高斯噪声添加到矢量信号 x 中，信噪比为 snr。'measured' 在添加噪声之前测量的功率
%}
    EbNo            = 14;
    snr             = EbNo+10*log10(k)-10*log10(sps);
    rxSignalG       = awgn(txFiltSignalF,snr,'measured');    % Gray-encoded 

%     sigma=0.02 ;
%     complex_noise   = (sigma*randn(1,sps*symbols+37))+...
%                         1j*(sigma*randn(1,sps*symbols+37));
%     rxSignalG       = rxSignalG + complex_noise;
                        
    rotated_signal  = rxSignalG.*exp(1i*2*pi/36);       % 添加相位旋转

%%
%{
    解调 16-QAM

    qamdemod - 解调接收到的数据并输出整数值数据符号。
%}

    rxFiltSignalF     = upfirdn(rotated_signal,match_coe,1,sps);     % 接收信号滤波 QAM 降采样
    rxFiltSignalF     = rxFiltSignalF(filtlen + 1:end - filtlen); % Account for delay

    sPlotFig = scatterplot(rxFiltSignalF,1,0,'g.');
    hold on
    scatterplot(dataModG,1,0,'k*',sPlotFig); 

    figure;
    subplot(2,1,1); plot(imag(dataModG)); hold on; plot(imag(rxFiltSignalF),'r'); title("Q通道接收"); legend('发送','接收'); 
    subplot(2,1,2); plot(real(dataModG)); hold on; plot(real(rxFiltSignalF),'r'); title("I通道接收"); legend('发送','接收');
    hold off 

    rxdata_nopll = qamdemod(rxFiltSignalF,M);
%{
    将整数值符号转换为二进制数据

    de2bi(X,n) - 将整数转换为 n 元组位比特流。对于 16-QAM，采用 4 元组
    resharp - 使数据再转换为比特流
%}  

    [numErrors,ber] = biterr(dataIn,rxdata_nopll);
    fprintf('\nThe binary coding bit error rate is %5.2e, based on %d errors.\n',ber,numErrors)       
%%
%{
    loop filter

    S域          ： 环路滤波器采用理想二阶2型环 : Fs = (1+s*T2)/(s*T1)
    双极性变换法  ： s = (2/ts)*((1-z^(-1))/(1+z^(-1)))
    Z域          ： Fz = ki + kp/((1-z^(-1));

                                 ---------<---------              
                                 |                 |
    phase_in ------> |ki| -> ---|+|---phase_int-----
                 |                                 |
                 --> |kp| ----------------------->|+|---phase_out------>    
%}
    fs      = 100e6;    % 采样率
    ts      = 1/fs;     % 采用周期 

    loop_bandwidth  = 1e-4;         % 环路带宽，取数据码率的1/20，归一化到载波频率
    damp_factor     = sqrt(2)/2;        % 阻尼系数

    ki  = (4*loop_bandwidth*loop_bandwidth)/...
            (1+2*damp_factor*loop_bandwidth+loop_bandwidth*loop_bandwidth);  % 环路滤波器系数
    kp  = (4*damp_factor*loop_bandwidth)/...
            (1+2*damp_factor*loop_bandwidth+loop_bandwidth*loop_bandwidth);  % 环路滤波器系数

    phase_accumulator   = 0;
    phase_int           = 0;
    data_shift          = zeros(1,length(rrc_coe));
    soft_data           = zeros(symbols,4);

    for n = 1:(symbols)
        correct(n) =  rxFiltSignalF(n)*exp(-1i*2*pi*phase_accumulator);

        qchannel = (imag(correct(n)));
        if qchannel < -2
            qdemod = -3;
        elseif qchannel < 0
            qdemod = -1;
        elseif qchannel < 2
            qdemod = 1;
        else
            qdemod = 3;
        end
       
        ichannel = (real(correct(n)));
        if ichannel < -2
            idemod = -3;
        elseif ichannel < 0
            idemod = -1;
        elseif ichannel < 2
            idemod = 1;
        else
            idemod = 3;
        end

        %
        qam_demod(n)  = idemod + 1i*qdemod;
        conjugate_product(n)    = correct(n) * (idemod - 1i*qdemod);  % 求共轭积

        % PLL
        phase_in(n) = angle(conjugate_product(n))/(2*pi);
        phase_int   = phase_in(n)*ki + phase_int;
        phase_out   = phase_in(n)*kp + phase_int;                   

        % 压控振荡器
        phase_accumulator = phase_accumulator + phase_out;
    end

    sPlotFig = scatterplot(correct,1,0,'g.');
    hold on
    scatterplot(qam_demod,1,0,'k*',sPlotFig); 
%{
    将整数值符号转换为二进制数据

    de2bi(X,n) - 将整数转换为 n 元组位比特流。对于 16-QAM，采用 4 元组
    resharp - 使数据再转换为比特流
%}
    rxdata          = qamdemod(qam_demod,M);

    [numErrors,ber] = biterr(dataIn,rxdata);
    fprintf('\nThe binary coding bit error rate is %5.2e, based on %d errors.\n',ber,numErrors)
%{
    对数似然比（Log-Likelihood Ratio，LLR）解调软信息输出
    max-log-map 算法
%}
    for n = 1 : symbols
        qchannel = (imag(correct(n)));
        ichannel = (real(correct(n)));

        % 
        d0(n) = (2 - abs(qchannel));

        d2(n) = (2 - abs(ichannel));

        if qchannel >= 2          
            d1(n) = (-2*qchannel + 2);
        elseif (qchannel > -2) && (qchannel < 2)
            d1(n) = (-qchannel);
        else
            d1(n) = (-2*qchannel - 2);
        end

        if ichannel >= 2
            d3(n) = (2*ichannel - 2);
        elseif (ichannel > -2) && (ichannel < 2)
            d3(n) = (ichannel);
        else
            d3(n) = (2*ichannel + 2);
        end        
    end


    d3(d3<0) = 0;
    d2(d2<0) = 0;
    d1(d1<0) = 0;
    d0(d0<0) = 0;

    d3(d3>0) = 1;
    d2(d2>0) = 1;
    d1(d1>0) = 1;
    d0(d0>0) = 1;

    for n = 1:symbols    
        soft_data(n,1:4) = [d0(n) d1(n) d2(n) d3(n)];  
    end

    soft_datad   = bi2de(soft_data);
    [numErrors,ber] = biterr(dataIn,soft_datad');
    fprintf('\nThe binary coding bit error rate is %5.2e, based on %d errors.\n',ber,numErrors);

    figure;
    plot(soft_datad' ~= dataIn); hold on;
    plot(rxdata ~= dataIn);hold on;
    legend("soft_datad","rxdata");