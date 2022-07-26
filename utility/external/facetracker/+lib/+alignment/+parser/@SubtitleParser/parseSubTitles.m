function subtitles = parseSubTitles(obj,subTitleFile)

%% Copied from Minh's code
fin = fopen(subTitleFile, 'r');
subId = 0;
index = 1;
while (true)
    subId = subId + 1;
    tline = fgetl(fin);
    
    if (tline == -1)
        break;
    elseif isempty(tline)
        break;
    end;
    
    id = str2double(tline); % remove '#frame'
    if (id ~= subId)
        error(sprintf('Subtitle numbering is wrong, expected: %d, actual %d\n', subId, id));
    end
    timestr = fgetl(fin);
    time_start = timestr(1:12);
    time_end = timestr(18:29);
    attachToPrev = false;
    currIndex = [];
    while (true)
        tline = fgetl(fin);
        if isempty(tline) || (tline(1) == -1)
            break;
        end;
        subtitles(index).start = time_start;
        subtitles(index).end = time_end;
        subtitles(index).text = tline;
        subtitles(index).startTime = time_start;
        subtitles(index).startFrame = obj.subtitleTimeToFrame(time_start);
        subtitles(index).endTime = time_end;
        subtitles(index).endFrame = obj.subtitleTimeToFrame(time_end);
        
        subtitles(index).attachToPrev = attachToPrev;
        subtitles(index).shots = [];
        attachToPrev = true;
        currIndex(end+1) = index;
        index = index+1;
    end;
    
    if(numel(currIndex)>1)
       startFrames = linspace(subtitles(currIndex(1)).startFrame, subtitles(currIndex(1)).endFrame,numel(currIndex)+1);
       for si = 1:numel(currIndex)
           subtitles(currIndex(si)).startFrame  = floor(startFrames(si));
           subtitles(currIndex(si)).endFrame  = floor(startFrames(si+1));
       end
       
    end
    if tline == -1
        break;
    end;
end
fclose(fin);

end