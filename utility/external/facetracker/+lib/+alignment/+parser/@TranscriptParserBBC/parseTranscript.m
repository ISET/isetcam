function transcripts = parseTranscript(obj,tranScriptFile)

fin = fopen(tranScriptFile, 'r');
index = 1;
transcripts = {};
while (true)
    tline = fgetl(fin);
   
    if (tline == -1)
        break;
    end;
    tline = strtrim(tline);
    tempLines = {};
    tempLines{1} = tline;
    while(true)
        tline = fgetl(fin);
        if (tline == -1)
            break;
        end;
        tline = strtrim(tline);
        if(isempty(tline))
            if(index == 106)
                a = 1;
            end
            transcripts{index} = obj.parseChunk(tempLines);
            index = index + 1;
            break;
        end
        tempLines{end+1} = tline;
    end

    if tline == -1
        break;
    end;
end
fclose(fin);
transcripts = cat(2,transcripts{:});
end