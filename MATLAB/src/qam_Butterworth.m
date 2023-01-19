%%
%{
    Butterworth 低通滤波器
%}
settings.fs = Fs;   %采样频率
settings.ap = Ap;   %通带最大衰减
settings.as = Ast;  %阻带最小衰减
settings.wp = Fp;   %通带截止频率
settings.ws = 0.01; %阻带起始频率

rxSignalBF = lpfilt(rxSignal,settings);
%%
%{
    解调接收到的 QAM 信号，并转化为比特流
%}
dataSymbolsOutBF = qamdemod(rxSignalBF,M);
dataOutMatrixBF  = de2bi(dataSymbolsOutBF,k);   % Binary-encoded
dataOutBF        = dataOutMatrixBF(:);          % Return data in column vector
%%
%{
    计算滤波后 BER
%}
[numErrorsBF,berBF] = biterr(dataIn,dataOutBF);
fprintf('\nFor Butterworth filter frequncy of %3.1f Hz, the bit error rate is %5.2e, based on %d errors.\n', Fp,berBF,numErrorsBF)
%%
%{
    函数
%}
function [output_sig] = lpfilt(input_sig,settings)
% 实现butterworth低通滤波器
% input_sig   输入信号
% settings    设置参数应该包含以下设置
% settings.fs 采样频率
% settings.ap 通带最大衰减
% settings.as 阻带最小衰减
% settings.wp 通带截止频率
% settings.ws 阻带起始频率
% output_sig  输出信号
  if(~exist('settings','var'))
      error('未设置参数')
  end
  check = [isfield(settings,'fs'),isfield(settings,'ap'),...
          isfield(settings,'as'),isfield(settings,'wp'),...
          isfield(settings,'ws')];
  if(~check(1))
      warning('采样频率未设置');
  end
  if(~check(2))
      warning('通带最大衰减未设置');
  end
  if(~check(3))
      warning('阻带最小衰减未设置');
  end
  if(~check(4))
      warning('通带截止频率未设置');
  end
  if(~check(5))
      warning('阻带起始频率未设置');
  end
  if(sum(check)>=5)
      fn  = settings.fs;
      ap  = settings.ap;
      as  = settings.as;
      wp  = settings.wp;
      ws  = settings.ws; %输入滤波器条件
      wpp = wp/(fn/2);   %归一化;
      wss = ws/(fn/2);   %归一化;

      [n,wn] = buttord(wpp,wss,ap,as); %计算阶数截止频率
      [b,a]  = butter(n,wn);           %计算分子、分母多项式的系数向量b、a
%       freqz(b,a,512,fn);             %做出H(z)的幅频、相频图
      output_sig=filter(b,a,input_sig);%实现滤波器
  else
    error('参数未设置，详情见警告')
  end
end