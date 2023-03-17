%% 
%{
    参数
%}
filtlen           = 10;      % Filter length in symbols
rolloff           = 0.4;    % Filter rolloff factor
%% 方法1
%{
    使用平方根升余弦 （RRC） 滤波器执行脉冲整形和升余弦滤波

    rcosdesign(beta,span,sps,'sqrt') - 
        -beta越大误码率越接近理想值，但是牺牲的带宽也多，
        -span用于对时域脉冲响应的截断，可以理解成几个第一零点时间长度
        -sps是一个码元的采样点数，
        -sps*span+1就是这个滤波器的时域波形的长度，
        -'sqrt'就是根升余弦的意思，如果是normal那就是升余弦滤波器
    FVTool - 显示 RRC 滤波器脉冲响应 
%}
rrcFilter         = rcosdesign(rolloff,filtlen,sps);

txFiltSignalF     = upfirdn(dataModG,rrcFilter,sps,1);     % 发送出的滤波 QAM 信 升采样
rxSignalF         = awgn(txFiltSignalF,snr,'measured');    % 通过 AWGN 通道接收到的 QAM 信号
%{
    接收信号处理
    对接收到的信号使用 upfirdn 函数对信号进行下采样和滤波。
    使用与对传输信号上采样相同的过采样因子进行下采样。使用应用于传输信号的相同 RRC 滤波器进行过滤。
    每个滤波操作将信号延迟滤波器长度的一半（以符号 /2 为单位）。因此，发送和接收滤波的总延迟等于滤波器长度。

    对于 BER 计算，发送和接收信号的大小必须相同，并且必须考虑发送和接收信号之间的延迟。
    删除抽取信号中的第一个符号，以考虑发送和接收滤波操作的累积延迟。
    去掉抽取信号中的最后一个符号，以确保解调器输出中的采样数与调制器输入中的样本数匹配。
%}
% 方法1
rxFiltSignalF     = upfirdn(rxSignalF,rrcFilter,1,sps);      % Downsample and filter
rxFiltSignalF     = rxFiltSignalF(filtlen + 1:end - filtlen); % Account for delay
%% 方法2 
%{
    使用 comm 函数, 在配置上还有一些问题，误码率高
    发送端和接收端都使用根升余弦滤波器。发送和接收滤波器结合起来等效于升余弦滤波器导致了可忽略不计的ISI。

    滤波器阶数 filtlen * sps，抽头数 filtlen * sps +1。
    可以利用gain特性归一化滤波器系数以使滤波后的和未滤波数据匹配。
%}
% txfilter          = comm.RaisedCosineTransmitFilter('RolloffFactor',rolloff,'FilterSpanInSymbols',filtlen,'OutputSamplesPerSymbol',sps);
% tparameters       = coeffs(txfilter);
% %txfilter.Gain     = 1/max(tparameters.Numerator);
% %fvtool(txfilter)
% 
% rxfilter          = comm.RaisedCosineReceiveFilter('RolloffFactor',rolloff,'FilterSpanInSymbols',filtlen,'InputSamplesPerSymbol',sps,'DecimationFactor',sps);
% rparameters       = coeffs(rxfilter);
% %rxfilter.Gain     = 1/max(rparameters.Numerator);
% %fvtool(rxfilter)

% txFiltSignalF   = txfilter(dataModG);                    % 发送出的滤波 QAM 信号
% rxSignalF       = awgn(txFiltSignalF,snr,'measured');    % 通过 AWGN 通道接收到的 QAM 信号
%rxFiltSignalF    = rxfilter(rxSignalF);
%%
%{
    解调接收到的 QAM 信号，并转化为比特流
%}
dataSymbolsOutF   = qamdemod(rxFiltSignalF,M);
dataOutMatrixF    = de2bi(dataSymbolsOutF,k);   % Binary-encoded
dataOutF          = dataOutMatrixF(:);          % Return data in column vector
%%
%{
    计算滤波后 BER
%}
[numErrorsF,berF] = biterr(dataIn,dataOutF);
fprintf('\nFor RRC filter,an EbNo setting of %3.1f dB, the bit error rate is %5.2e, based on %d errors.\n', EbNo,berF,numErrorsF)
%%
%{
    眼图测试
%}
eyediagram(dataMod(1:200),2);           % 滤波前的发射信号

eyediagram(txFiltSignalF(1:200),sps*2);  % 滤波后的无噪声发射信号

eyediagram(rxSignalF(1:200),sps*2);     % 叠加了通道噪声的接收信号

eyediagram(rxFiltSignalF(1:200),2);      % 进行RRC滤波后的接收信号
%%
%{
    创建滤波前后的星座图
    按每个符号采样数的平方根缩放接收信号，以规范发射和接收功率电平。
%}
scatplot          = scatterplot(sqrt(sps)*rxSignalF(1:sps*n/k),sps,0,'g.');
hold on;
scatterplot(rxFiltSignalF(1:n/k),1,0,'bx',scatplot);
title('Received Signal, Before and After Filtering');
legend('Before Filtering','After Filtering');
axis([-5 5 -5 5]); % Set axis ranges
hold off;