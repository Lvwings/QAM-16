close all; clear all;

m = -4:0.1:4;
y1 = exp(-(m+1).^2);
y2 = exp(-(m-1).^2);
y3 = exp(-(m+3).^2);
y4 = exp(-(m-3).^2);

plot(m,y1); hold on;
plot(m,y2); hold on;
plot(m,y3); hold on;
plot(m,y4); hold on;

legend(' -(m+1)^2','-(m+3)^2','-(m-1)^2','-(m-3)^2');
fprintf( "--------------------b0 = 1------------------------ \n")
if (y1(10) > y2(10))    fprintf( "<-2 : exp(-(m+1).^2) \n");
else                    fprintf( "<-2 : exp(-(m-1).^2) \n"); end

if (y1(30) > y2(30))    fprintf( "<0 : exp(-(m+1).^2) \n");
else                    fprintf( "<0 : exp(-(m-1).^2) \n"); end

if (y1(50) > y2(50))    fprintf( "<2 : exp(-(m+1).^2) \n");
else                    fprintf( "<2 : exp(-(m-1).^2) \n"); end

if (y1(70) > y2(70))    fprintf( ">2 : exp(-(m+1).^2) \n");
else                    fprintf( ">2 : exp(-(m-1).^2) \n"); end
%
fprintf( "--------------------b0 = 0------------------------ \n");
if (y3(10) > y4(10))    fprintf( "<-2 : exp(-(m+3).^2) \n");
else                    fprintf( "<-2 : exp(-(m-3).^2) \n"); end

if (y3(30) > y4(30))    fprintf( "<0 : exp(-(m+3).^2) \n");
else                    fprintf( "<0 : exp(-(m-3).^2) \n"); end

if (y3(50) > y4(50))    fprintf( "<2 : exp(-(m+3).^2) \n");
else                    fprintf( "<2 : exp(-(m-3).^2) \n"); end

if (y3(70) > y4(70))    fprintf( ">2 : exp(-(m+3).^2) \n");
else                    fprintf( ">2 : exp(-(m-3).^2) \n"); end   

m = -4:0.1:4;
y1 = exp(-(m+1).^2);
y2 = exp(-(m+3).^2);
y3 = exp(-(m-1).^2);
y4 = exp(-(m-3).^2);

plot(m,y1); hold on;
plot(m,y2); hold on;
plot(m,y3); hold on;
plot(m,y4); hold on;

legend(' -(m+1)^2','-(m+3)^2','-(m-1)^2','-(m-3)^2');
fprintf( "--------------------b1 = 1------------------------ \n")
if (y1(10) > y2(10))    fprintf( "<-2 : exp(-(m+1).^2) \n");
else                    fprintf( "<-2 : exp(-(m+3).^2) \n"); end

if (y1(30) > y2(30))    fprintf( "<0 : exp(-(m+1).^2) \n");
else                    fprintf( "<0 : exp(-(m+3).^2) \n"); end

if (y1(50) > y2(50))    fprintf( "<2 : exp(-(m+1).^2) \n");
else                    fprintf( "<2 : exp(-(m+3).^2) \n"); end

if (y1(70) > y2(70))    fprintf( ">2 : exp(-(m+1).^2) \n");
else                    fprintf( ">2 : exp(-(m+3).^2) \n"); end
%
fprintf( "--------------------b1 = 0------------------------ \n");
if (y3(10) > y4(10))    fprintf( "<-2 : exp(-(m-1).^2) \n");
else                    fprintf( "<-2 : exp(-(m-3).^2) \n"); end

if (y3(30) > y4(30))    fprintf( "<0 : exp(-(m-1).^2) \n");
else                    fprintf( "<0 : exp(-(m-3).^2) \n"); end

if (y3(50) > y4(50))    fprintf( "<2 : exp(-(m-1).^2) \n");
else                    fprintf( "<2 : exp(-(m-3).^2) \n"); end

if (y3(70) > y4(70))    fprintf( ">2 : exp(-(m-1).^2) \n");
else                    fprintf( ">2 : exp(-(m-3).^2) \n"); end

m = -4:0.1:4;
y1 = exp(-(m+1).^2);
y2 = exp(-(m-1).^2);
y3 = exp(-(m+3).^2);
y4 = exp(-(m-3).^2);

plot(m,y1); hold on;
plot(m,y2); hold on;
plot(m,y3); hold on;
plot(m,y4); hold on;

legend(' -(m+1)^2','-(m+3)^2','-(m-1)^2','-(m-3)^2');
fprintf( "--------------------b2 = 1------------------------ \n")
if (y1(10) > y2(10))    fprintf( "<-2 : exp(-(m+1).^2) \n");
else                    fprintf( "<-2 : exp(-(m-1).^2) \n"); end

if (y1(30) > y2(30))    fprintf( "<0 : exp(-(m+1).^2) \n");
else                    fprintf( "<0 : exp(-(m-1).^2) \n"); end

if (y1(50) > y2(50))    fprintf( "<2 : exp(-(m+1).^2) \n");
else                    fprintf( "<2 : exp(-(m-1).^2) \n"); end

if (y1(70) > y2(70))    fprintf( ">2 : exp(-(m+1).^2) \n");
else                    fprintf( ">2 : exp(-(m-1).^2) \n"); end
%
fprintf( "--------------------b2 = 0------------------------ \n");
if (y3(10) > y4(10))    fprintf( "<-2 : exp(-(m+3).^2) \n");
else                    fprintf( "<-2 : exp(-(m-3).^2) \n"); end

if (y3(30) > y4(30))    fprintf( "<0 : exp(-(m+3).^2) \n");
else                    fprintf( "<0 : exp(-(m-3).^2) \n"); end

if (y3(50) > y4(50))    fprintf( "<2 : exp(-(m+3).^2) \n");
else                    fprintf( "<2 : exp(-(m-3).^2) \n"); end

if (y3(70) > y4(70))    fprintf( ">2 : exp(-(m+3).^2) \n");
else                    fprintf( ">2 : exp(-(m-3).^2) \n"); end    

m = -4:0.1:4;
y1 = exp(-(m-3).^2);
y2 = exp(-(m-1).^2);
y3 = exp(-(m+3).^2);
y4 = exp(-(m+1).^2);

plot(m,y1); hold on;
plot(m,y2); hold on;
plot(m,y3); hold on;
plot(m,y4); hold on;

legend(' -(m-3)^2','-(m-1)^2','-(m+3)^2','-(m+1)^2');
fprintf( "--------------------b3 = 1------------------------ \n")
if (y1(10) > y2(10))    fprintf( "<-2 : exp(-(m-3).^2) \n");
else                    fprintf( "<-2 : exp(-(m-1).^2) \n"); end

if (y1(30) > y2(30))    fprintf( "<0 : exp(-(m-3).^2) \n");
else                    fprintf( "<0 : exp(-(m-1).^2) \n"); end

if (y1(50) > y2(50))    fprintf( "<2 : exp(-(m-3).^2) \n");
else                    fprintf( "<2 : exp(-(m-1).^2) \n"); end

if (y1(70) > y2(70))    fprintf( ">2 : exp(-(m-3).^2) \n");
else                    fprintf( ">2 : exp(-(m-1).^2) \n"); end
%
fprintf( "--------------------b3 = 0------------------------ \n");
if (y3(10) > y4(10))    fprintf( "<-2 : exp(-(m+3).^2) \n");
else                    fprintf( "<-2 : exp(-(m+1).^2) \n"); end

if (y3(30) > y4(30))    fprintf( "<0 : exp(-(m+3).^2) \n");
else                    fprintf( "<0 : exp(-(m+1).^2) \n"); end

if (y3(50) > y4(50))    fprintf( "<2 : exp(-(m+3).^2) \n");
else                    fprintf( "<2 : exp(-(m+1).^2) \n"); end

if (y3(70) > y4(70))    fprintf( ">2 : exp(-(m+3).^2) \n");
else                    fprintf( ">2 : exp(-(m+1).^2) \n"); end     