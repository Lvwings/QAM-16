%%
%{
    为200 MHz采样数据设计低通FIR滤波器。通带边沿频率为8 kHz。通带纹波为0.01 dB，阻带衰减为80 dB。将滤波器级数为 120。
%}
N   = 120;        % FIR filter order            
Fs  = 200e6;     % 200 MHz sampling frequency  
Fp  = 8e3;       % 8 kHz passband-edge frequency   
Ap  = 0.01;      % 通带纹波 : 0.01 dB
Ast = 80;       % 阻带衰减 : 80 dB
%%
%{
    计算通带和阻带纹波的最大偏差
%}
Rp  = (10^(Ap/20) - 1)/(10^(Ap/20) + 1); 
Rst = 10^(-Ast/20);
%%
%{
    使用和查看幅度频率响应设计滤波器
%}
LPF = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge');
fvtool(LPF,'Fs',Fs)
%%
%{
    对接收信号进行低通滤波
%}
rxSignalL = upfirdn(rxSignalG,LPF,sps,1);     % 低通滤波
%%
%{
    解调接收到的 QAM 信号，并转化为比特流
%}
dataSymbolsOutL = qamdemod(rxSignalL,M);
dataOutMatrixL  = de2bi(dataSymbolsOutL,k);   % Binary-encoded
dataOutL        = dataOutMatrixL(:);          % Return data in column vector
%%
%{
    计算滤波后 BER
%}
[numErrorsL,berL] = biterr(dataIn,dataOutL(1:n));
fprintf('\nFor low-pass filter frequncy of %3.1f Hz, the bit error rate is %5.2e, based on %d errors.\n', Fp,berL,numErrorsL)
