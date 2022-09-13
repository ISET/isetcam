function frame = subtitleTileToFrame(obj,timeStr)
    frame = 0;
    ele = regexp(timeStr,':','split');
    hrs = str2num(ele{1});
    mins = str2num(ele{2});
    secs = str2num(strrep(ele{3},',','.'));
    secs = hrs*3600+mins*60+secs;
    frame = ceil(secs*obj.frameRate);
end