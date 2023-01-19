%%
%{
    系统自带 lowpass 低通滤波器
%}
fs = 1e5;                                       %sampling rate per second
fp = 1000;
[rxSignalLPS,f] = lowpass(rxSignalG,fp,fs);          %以 fp 为频率上限，做lowpass
lowpass(rxSignalG,fp,fs)
%% 功率谱
%pspectrum(rxSignalLPS)
%%
%{
    解调接收到的 QAM 信号，并转化为比特流
%}
dataSymbolsOutLPS = qamdemod(rxSignalLPS,M);
dataOutMatrixLPS  = de2bi(dataSymbolsOutLPS,k);   % Binary-encoded
dataOutLPS        = dataOutMatrixLPS(:);          % Return data in column vector
%%
%{
    计算滤波后 BER
%}
[numErrorsLPS,berLPS] = biterr(dataIn,dataOutLPS);
fprintf('\nFor lowpass filter frequncy of %3.1f Hz, the bit error rate is %5.2e, based on %d errors.\n', fp,berLPS,numErrorsLPS)

%%
