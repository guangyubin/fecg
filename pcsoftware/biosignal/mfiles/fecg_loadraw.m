
% FECG的raw 文件格式
% 前256个字节保留
% packet大小为 126
% 6个字节头+120个字节数据
% 前两个字节为seqid，数据类型为short
% 120个字节为4个通道10个采样点的数据，每个采样点3个字节
function [data,hd,seqid] = fecg_loadraw(fname)
% fname = 'D:\MatlabWork\AEP\FECG\2020219161119.raw';
fid = fopen(fname,'rb');
tmp = uint8(fread(fid,256,'uint8'));
hd.descript = char(tmp(1:16));
hd.chan = typecast(tmp(17:20),'uint32');
hd.fs = typecast(tmp(21:24),'uint32');
% hd.nsmp = typecast(tmp(25:28),'uint32');
% hd.res = typecast(tmp(29:32),'uint32');
hd.startTime = typecast(tmp(25:28),'uint32');
hd.endTime = typecast(tmp(29:32),'uint32');
hd.duration = hd.endTime  - hd.startTime;
hd.startTime = ConvertDate(hd.startTime);
hd.endTime = ConvertDate(hd.endTime);

    
uart_packet_len = 126;
d = fread(fid, 'uint8');
d = uint8(d);
d = reshape(d,[126 length(d)/126]);
npcks = size(d,2);
seqid = zeros(1,npcks);
m = 1;
for ii = 1:size(d,2)    
    seqid(ii) = typecast(d(1:2,ii),'UINT16');    
end
d1 = d(7:end,:);
d2 = reshape(d1,[3 size(d1,1)*size(d1,2)/3]);
ecg = zeros(1,size(d2,2));
for ii = 1:length(d2)
    x(1:3) = d2(3:-1:1,ii);
    if x(3) > 127
        x(4) = 255;
    else
        x(4) = 0 ;
    end
    ecg(ii) = typecast(x,'INT32'); 
end
data = reshape(ecg,[4 length(ecg)/4]);
end
function [date] = ConvertDate(x)
    x = double(x);

    date = datestr((x+28800)/86400 + datenum(1970,1,1),31);

end


