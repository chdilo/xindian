delete(instrfindall), clc
clear
clear global

global data
global d
global data1
global data2
global h1
global h2
global n
global error
global vref

port = 'COM1';
n = 0;
t = 5;
vref = 2.42;
d = zeros(13, 20);
data = zeros(260, 1);
data1 = zeros(1, 20);
data2 = zeros(1, 20);
error = 0;

x = linspace(0, t, t*512+1);
y = zeros(1, t*512);
subplot(211)
h1 = plot(x(2:end), y);
subplot(212)
h2 = plot(x(2:end), y);

s = serial(port, 'BaudRate', 115200);
fclose(s);
s.BytesAvailableFcnMode = 'byte';
s.BytesAvailableFcnCount = 416;
s.BytesAvailableFcn = @my_callback;
fopen(s);


function my_callback(s, ~)
global data
global d
global data1
global data2
global remain
global h1
global h2
global n
global error
global vref
n = n + 1;

data = fread(s, 416);
d = [remain; data];
for i = 1:length(d)
    if d(i)==170 && d(i+1)==170 && d(i+2)==241 && d(i+3)==8
        d(1:i-1) = [];
        break
    end
end

remain = d(floor(length(d)/13)*13+1:end);
d(floor(length(d)/13)*13+1:end) = [];
d = reshape(d, 13, []);

data1 = d(5,:)*16777216 + d(6,:)*65536 + d(7,:)*256 + d(8,:);
data1(data1 > 2147483647) = data1(data1 > 2147483647) - 4294967296;
data1 = vref*data1/8388607;

data2 = d(9,:)*16777216 + d(10,:)*65536 + d(11,:)*256 + d(12,:);
data2(data2 > 2147483647) = data2(data2 > 2147483647) - 4294967296;
data2 = vref*data2/8388607;

error = sum(d(end,:)~=mod(sum(d(1:end-1,:)),256)) / 32;

h1.YData = [h1.YData(1+length(data1):end), data1];
h2.YData = [h2.YData(1+length(data2):end), data2];

end

