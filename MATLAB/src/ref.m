%% 参数与RRC滤波器
M               = 16;           % Modulation order
k               = log2(M);      % Bits per symbol
numBits         = k*7.5e4;      % Bits to process
sps             = 4;            % Samples per symbol (oversampling factor)

filtlen         = 10;      % Filter length in symbols
rolloff         = 0.25;    % Filter rolloff factor
rrcFilter       = rcosdesign(rolloff,filtlen,sps);
%% 发送数据生成
rng default;                        % Use default random number generator
dataIn          = randi([0 1],numBits,1);               % Generate vector of binary data
dataInMatrix    = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary 4-tuples
dataSymbolsIn   = bi2de(dataInMatrix);                  % Convert to integers
dataMod         = qammod(dataSymbolsIn,M);
%% 信道参数
EbNo            = 12;
snr             = EbNo + 10*log10(k) - 10*log10(sps);
%% 无滤波
rxSignal        = awgn(dataMod,snr,'measured');         % No filter
dataSymbolsOut  = qamdemod(rxSignal,M);
dataOutMatrix   = de2bi(dataSymbolsOut,k);
dataOut         = dataOutMatrix(:); % Return data in column vector
%% 滤波
txFiltSignalF    = upfirdn(dataMod,rrcFilter,sps,1);
rxSignalF        = awgn(txFiltSignalF,snr,'measured');

rxFiltSignalF    = upfirdn(rxSignalF,rrcFilter,1,sps); % Downsample and filter
rxFiltSignalF    = rxFiltSignalF(filtlen + 1:end - filtlen); % Account for delay

dataSymbolsOutF  = qamdemod(rxFiltSignalF,M);
dataOutMatrixF   = de2bi(dataSymbolsOutF,k);
dataOutF         = dataOutMatrixF(:); % Return data in column vector
%% 误码统计
[numErrors,ber] = biterr(dataIn,dataOut);
fprintf('\nFor an EbNo setting of %3.1f dB, the bit error rate is %5.2e, based on %d errors.\n', ...
    EbNo,ber,numErrors)

[numErrorsF,berF] = biterr(dataIn,dataOutF);
fprintf('\nFor RRC filter, an EbNo setting of %3.1f dB, the bit error rate is %5.2e, based on %d errors.\n', ...
    EbNo,berF,numErrorsF)
%%
%{
    创建星座图
    AWGN的效果存在于星座图中。

    scatterplot(x,n,offset,plotstring,scatfig) - 显示调制信号的同相和正交分量，以及通道后接收到的噪声信号。 
    n : 抽取因子
    plotstring : 设置散点图的绘制符号、线类型和颜色
    scatfig : 在现有对象中生成散点图
%}
sPlotFig = scatterplot(rxSignal,1,0,'g.');
hold on
scatterplot(rxFiltSignalF,1,0,'k*',sPlotFig)
title('Received Signal, Before and After Filtering');
legend('Before Filtering','After Filtering');
axis([-5 5 -5 5]); % Set axis ranges
hold off;