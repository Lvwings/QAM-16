%% 读取仿真中的数据
din = load("D:/Algorithm/QAM/Git_QAM/MATLAB/data/din.txt");
idata = load("D:/Algorithm/QAM/Git_QAM/MATLAB/data/idata.txt");
qdata = load("D:/Algorithm/QAM/Git_QAM/MATLAB/data/qdata.txt");

%%
%{
    系统自带 lowpass 低通滤波器

    lowpass(x,fpass,fs)
%}
fs = 20e6;                                       %sampling rate per second
fp = 0.1;
[rxSignalLPS,f] = lowpass(idata,fp,fs);          %以 fp 为频率上限，做lowpass
lowpass(idata,fp,fs)