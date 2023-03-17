%%
%{
    定义参数，生成长度为 N 的比特流

    rng — 控制随机数生成,将函数设置为其默认状态或任何静态种子值，以便示例生成可重复的结果。
    randi — 生成随机数据流
%}
M   = 16;       % QAM Modulation order : 16-QAM (alphabet size or number of points in signal constellation)
k   = log2(M);  % Number of bits per symbol : 16-QAM carry 4 bits
n   = 3e4;      % Number of bits to process
sps = 4;        % Number of samples per symbol (oversampling factor)

rng default;
dataIn = randi([0 1],n,1); % Generate vector of binary data

%{
    使用词干图显示随机二进制数据流的前 40 位的二进制值。在调用函数时使用冒号 （） 运算符来选择二进制向量的一部分。
%}
stem(dataIn(1:40),'filled');
title('Random Bits');
xlabel('Bit Index');
ylabel('Binary Value');
%%
%{
    将二进制数据转换为整数值符号
    QAM函数的默认配置需要整数值数据作为要调制的输入符号。这里将前面生成的比特流进行转换

    reshape(A,sz1,...,szN) - 将 A 重构为一个 sz1×...×szN 数组
    bi2de(X) - 将二进制行向量转换为十进制整数

    在这个例子中使用了16-QAM，使用 reshape 将比特流分为每4-bit作为一组。
%}
dataInMatrix    = reshape(dataIn,length(dataIn)/k,k);
dataSymbolsIn   = bi2de(dataInMatrix);
figure;                    % Create new figure window.
stem(dataSymbolsIn);
title('Random Symbols');
xlabel('Symbol Index');
ylabel('Integer Value');
%%
%{
    使用 16-QAM 进行调制

    qammod - 将相位偏移为零的 16-QAM 调制应用于列矢量，以进行二进制编码和格雷编码的位到符号映射。
%}
dataMod     = qammod(dataSymbolsIn,M,'bin');    % Binary-encoded
dataModG    = qammod(dataSymbolsIn,M);          % Gray-encoded

%{
    添加白高斯噪声
    调制信号使信号具有指定信噪比（SNR）。SNR 将由每比特的能量与噪声的功率谱密度比值（EbNo : Eb/No）得到。本例中假设通道 Eb/No 为 10 分贝。

    awgn(x，snr，signalpower) - 将白高斯噪声添加到矢量信号 x 中，信噪比为 snr。'measured' 在添加噪声之前测量的功率
%}
EbNo        = 18;
snr         = EbNo+10*log10(k)-10*log10(sps);
rxSignal    = awgn(dataMod,snr,'measured');     % Binary-encoded
rxSignalG   = awgn(dataModG,snr,'measured');    % Gray-encoded
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
scatterplot(dataMod,1,0,'k*',sPlotFig);
%%
%{
    解调 16-QAM

    qamdemod - 解调接收到的数据并输出整数值数据符号。
%}
dataSymbolsOut  = qamdemod(rxSignal,M,'bin'); % Binary-encoded data symbols
dataSymbolsOutG = qamdemod(rxSignalG,M);      % Gray-coded data symbols

%{
    将整数值符号转换为二进制数据

    de2bi(X,n) - 将整数转换为 n 元组位比特流。对于 16-QAM，采用 4 元组
    resharp - 使数据再转换为比特流
%}
dataOutMatrix   = de2bi(dataSymbolsOut,k);
dataOut         = dataOutMatrix(:);     % Return data in column vector
dataOutMatrixG  = de2bi(dataSymbolsOutG,k);
dataOutG        = dataOutMatrixG(:);   % Return data in column vector   
%%
%{
    计算系统 BER
    该函数计算原始二进制数据流和接收的数据流的位错误统计信息。可以观察到采用格雷码将显著降低 BER
%}
[numErrors,ber] = biterr(dataIn,dataOut);
fprintf('\nThe binary coding bit error rate is %5.2e, based on %d errors.\n',ber,numErrors)
[numErrorsG,berG] = biterr(dataIn,dataOutG);
fprintf('\nThe Gray coding bit error rate is %5.2e, based on %d errors.\n', berG,numErrorsG)
%%
%{
    绘制信号星座，显示 16-QAM 星座的自然和灰度编码二进制符号映射
    前面显示的星座图绘制了QAM星座中的点，但它没有指示符号值和星座点之间的映射。
%}
x       = (0:15);               % Integer input
symbin  = qammod(x,M,'bin');    % 16-QAM output (binary-coded)
symgray = qammod(x,M,'gray');   % 16-QAM output (Gray-coded)

scatterplot(symgray,1,0,'b*');
grid on;
for i = 1:M
    text(real(symgray(i)) - 0.0,imag(symgray(i)) + 0.3, ...
        dec2base(x(i),2,4));
     text(real(symgray(i)) - 0.5,imag(symgray(i)) + 0.3, ...
         num2str(x(i)));
    
%     text(real(symbin(i)) - 0.0,imag(symbin(i)) - 0.3, ...
%         dec2base(x(i),2,4),'Color',[1 0 0]);
%     text(real(symbin(i)) - 0.5,imag(symbin(i)) - 0.3, ...
%         num2str(x(i)),'Color',[1 0 0]);
end
title('16-QAM Symbol Mapping');
axis([-4 4 -4 4]);
