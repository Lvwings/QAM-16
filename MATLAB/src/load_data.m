%% 读取仿真中的数据
%{
	符号数据 din 根据载波周期上传
%}
close all; clear all;
din      = load("D:/Algorithm/QAM/Git_QAM/MATLAB/data/din.txt");

mod_i    = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/mod_i.txt");
mod_q    = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/mod_q.txt");

filter_i = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/filter_i.txt");
filter_i = filter_i/2^8;
filter_q = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/filter_q.txt");
filter_q = filter_q/2^8;

qam_data = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/qam_data.txt");
qam_data = qam_data/2^9;

demult_i = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demult_i.txt");
demult_i = demult_i/2^30;
demult_q = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demult_q.txt");
demult_q = demult_q/2^30;

defilter_i = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/defilter_i.txt");
defilter_i = defilter_i/2^30;
defilter_q = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/defilter_q.txt");
defilter_q = defilter_q/2^30;

demod_i    = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demod_i.txt");
demod_q    = textread("D:/Algorithm/QAM/Git_QAM/MATLAB/data/demod_q.txt");
%%
%{
	采样相关参数
	n   : 符号数量 
	fs  : 系统频率 200e6     200MHz

	fc  : 载波频率 3.125e6   3.125MHz
	fm  : 信号频率 195.3125e3 195.3125KHz 
	N   : 采样点数 (fs/fc)*(fc/fm)*n      
%}
fs = 200e6;
fc = 3.125e6;
fm = 195.3125e3;

M  = 16;                        % QAM Modulation order : 16-QAM (alphabet size or number of points in signal constellation)
k  = log2(M);                   % Number of bits per symbol : 16-QAM carry 4 bits

n  = fix(numel(din)/(fc/fm));   % Number of symbol to process
N  = (fs/fc)*(fc/fm)*n;

%%
%{
	使用 16-QAM 进行调制

	qammod - 将相位偏移为零的 16-QAM 调制应用于列矢量，以进行二进制编码和格雷编码的位到符号映射。
	qam.data = I+jQ

%}

dataMod     = qammod(din(1:(fc/fm)*n),M,'bin');    % Binary-encoded
dataModG    = qammod(din(1:(fc/fm)*n),M);          % Gray-encoded

qModG = imag(dataModG);
iModG = real(dataModG);

% 由于符号速率远低于系统频率，需要将符号向量按 采样数量/符号数量 进行扩展，但是数据在上传时用的是载波频率，因此需要再扣除这个倍率
Q = repmat(qModG,N/(n*(fc/fm)),1);     
Q = reshape(Q,1,numel(Q));
I = repmat(iModG,N/(n*(fc/fm)),1);
I = reshape(I,1,numel(I));

len = 1e4;

subplot(2,1,1); plot(Q(1:len)); hold on; plot(mod_q(1:len),'r'); title("Q通道QAM映射"); legend('matlab中QAM映射','fpga中QAM映射');
subplot(2,1,2); plot(I(1:len)); hold on; plot(mod_i(1:len),'r'); title("I通道QAM映射"); legend('matlab中QAM映射','fpga中QAM映射');
%% 使用升余弦 （RC） 滤波器执行脉冲整形和升余弦滤波
%{
    % Fs = 100;  % Sampling Frequency
    %
    % N    = 16;         % Order
    % Fc   = 0.1;        % Cutoff Frequency
    % TM   = 'Rolloff';  % Transition Mode
    % R    = 0.25;       % Rolloff
    % DT   = 'Normal';   % Design Type
    % Beta = 0.33;       % Window Parameter
%}
q_rc = filter_design(Q');
i_rc = filter_design(I');

figure
subplot(2,2,1); plot(q_rc(1:len)); hold on; plot(Q(1:len),'r'); title("Q通道数据与升余弦滤波后数据"); legend('符号数据RC滤波','符号数据');
subplot(2,2,2); plot(i_rc(1:len)); hold on; plot(I(1:len),'r'); title("I通道数据与升余弦滤波后数据"); legend('符号数据RC滤波','符号数据');

subplot(2,2,3); plot(q_rc(1:len)); hold on; plot(filter_q(1:len),'r'); title("Q通道升余弦滤波后数据"); legend('matlab中RC滤波','fpga中RC滤波');
subplot(2,2,4); plot(i_rc(1:len)); hold on; plot(filter_i(1:len),'r'); title("I通道升余弦滤波后数据"); legend('matlab中RC滤波','fpga中RC滤波');

%% 进行载波调制
%{
	ts  : 采样间隔 ts = 1/fs;
	qam.data = I*cos - Q*sin
%}
ts = 1/2e8;
t = [0:N-1]*ts;         % sample time

fcos = cos(2*pi*fc*t);  % I Chanel carrier
fsin = sin(2*pi*fc*t);  % Q Chanel carrier

tq = q_rc.*(-fsin'); % 2?
ti = i_rc.*fcos';
tout = ti + tq;

figure
subplot(2,3,1); plot(fsin(1:len));   hold on;  title("Q通道载波");
subplot(2,3,2); plot(q_rc(1:len));   hold on;  title("Q通道数据");
subplot(2,3,3); plot(tq(1:len));     hold on;  title("Q通道调制");
subplot(2,3,4); plot(fcos(1:len));   hold on;  title("I通道载波");
subplot(2,3,5); plot(i_rc(1:len));   hold on;  title("I通道数据");
subplot(2,3,6); plot(ti(1:len));     hold on;  title("I通道调制");

figure
plot(tout(1:len));   hold on;  plot(qam_data(1:len),'r'); title("QAM输出"); legend('matlab中QAM输出','fpga中QAM输出');
%%%
%{
    存储QAM输出到本地
%}
tout_int = round(single(tout*2^10));
fid      = fopen("D:/Algorithm/QAM/Git_QAM/MATLAB/data/tx_qam.txt",'w');
fprintf(fid,"%d\n",tout_int);
fclose(fid);

%% 解调
rq = tout.*(-fsin');
ri = tout.*fcos';
figure
subplot(2,1,1); plot(rq(1:len));   hold on; plot(demult_q(1:len),'r'); title("Q通道解调"); legend('Matlab接收解调Q','Fpga接收解调Q');
subplot(2,1,2); plot(ri(1:len));   hold on; plot(demult_i(1:len),'r'); title("I通道解调"); legend('Matlab接收解调I','Fpga接收解调I');

%%%
%{
    SR 滤波
%}
rq_rc = filter_design(double(2^8*rq));
ri_rc = filter_design(double(2^8*ri));
figure
subplot(2,1,1); plot(rq_rc(1:len));   hold on; plot(defilter_q(1:len),'r'); title("Q通道滤波"); legend('Matlab接收滤波Q','Fpga接收滤波Q');
subplot(2,1,2); plot(ri_rc(1:len));   hold on; plot(defilter_i(1:len),'r'); title("I通道滤波"); legend('Matlab接收滤波I','Fpga接收滤波I');


%%
%{
    创建星座图
    AWGN的效果存在于星座图中。

    scatterplot(x,n,offset,plotstring,scatfig) - 显示调制信号的同相和正交分量，以及通道后接收到的噪声信号。 
    n : 抽取因子
    plotstring : 设置散点图的绘制符号、线类型和颜色
    scatfig : 在现有对象中生成散点图
%}

zout = (double(ri_rc) + 1i*double(rq_rc))*2^9; 
scatterplot(zout',1,0,'g*');
legend('Matlab星座图');
dout = (defilter_i + 1i*defilter_q)*2^12;
scatterplot(dout',1,0,'k*');
legend('Fpga星座图');
%%
%{
	系统自带 lowpass 低通滤波器

	lowpass(x,fpass,fs)
%}
% fs = 20e6;                                       %sampling rate per second
% fp = 0.1;
% [rxSignalLPS,f] = lowpass(qami,fp,fs);          %以 fp 为频率上限，做lowpass
