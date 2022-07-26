function data = parseChunk(obj,chunk)

data = [];
data.isSceneStart = false;
data.actTime = '';
data.text = '';
data.description  = '';
data.speaker = '';
data.startFrame = 0;
data.endFrame = 0;
data.aligned = false;
data.shots = [];

for i=1:numel(chunk)
    
    tline = chunk{i};
    if(isempty(tline))
        continue;
    end
   
    if(tline(1) == '#')
        data.isSceneStart = true;
        tline = tline(2:end);
    end
    tline = strtrim(tline);
    ele = regexp(tline,'\t\t','split');
    if(numel(ele)>1)
        data.actTime = ele{1};
        tline = ele{2};
    end
    
    if(~isempty(strfind(tline,':')))
        ele = regexp(tline,':','split');
        data.speaker = ele{1};
        if(~isempty(data.text))
            data.text = sprintf('%s \n %s',data.text,ele{2});
        else
            data.text = ele{2};
        end
    else
        if(~isempty(data.text))
            data.text = sprintf('%s \n %s',data.text,tline);
        else
            data.text = tline;
        end
        
    end
    
end


end