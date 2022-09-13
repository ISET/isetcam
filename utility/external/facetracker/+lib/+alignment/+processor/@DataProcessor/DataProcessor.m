classdef DataProcessor < handle
    
    properties
        shots
        subtitles
        transcript
        frameRate
        matchInterval
        shotParser
        subtitleParser
        transcriptParser
    end
    
    methods
        
        function obj = DataProcessor(shotsFile,subTitleFile,tranScriptFile)
            obj.shots = [];
            obj.subtitles = [];
            obj.frameRate = 25;
            obj.matchInterval = 5;
            obj.shotParser = lib.alignment.parser.ShotParser();
            obj.subtitleParser = lib.alignment.parser.SubtitleParser(obj.frameRate);
            obj.transcriptParser = lib.alignment.parser.TranscriptParser();
            
            obj.loadShots(shotsFile);
            obj.loadSubtitles(subTitleFile);
            obj.loadTranscript(tranScriptFile);
            obj.doAlign();
            obj.populateShotInfo();
            
        end
        
        function getSpeakerMappingFile(obj,fileName)
            speakers = unique({obj.transcript(:).speaker});
            fp = fopen(fileName,'w+');
            for i=1:numel(speakers)
                fprintf(fp,'%s\n',speakers{i});
            end
            fclose(fp);
        end
        
        function loadShots(obj,shotsFile)
            
            obj.shots = obj.shotParser.parseShots(shotsFile);
            
        end
        
        writeShotInfo(obj,outFile);
        populateShotInfo(obj);
        loadSubtitles(obj,subTitleFile)
        
        function loadTranscript(obj,transcriptFile)
            
            obj.transcript = obj.transcriptParser.parseTranscript(transcriptFile);
            
        end
        
        function tokens = line2tokens(obj,line)
            line = regexprep(line, '<(/)?\w*>', ''); % remove html style tags
            tokens = textscan(line, '%s', 'Delimiter', ' ''"()[]{}<>,;.?!:-_~*/', 'MultipleDelimsAsOne', 1);
            tokens = tokens{1};
        end
        
        % similarity between two sets of tokents
        function sim = lineSim(obj,tokens1, tokens2)
            % Count the number of words in tokens1 that appear in tokens2.
            % This is assymmetric distance
            nMatch = 0;
            for i=1:length(tokens1)
                match = strcmpi(tokens1{i}, tokens2);
                if find(match)
                    nMatch = nMatch + 1;
                end
            end
            
            % assymmetric distance, put more emphasize on matching tokens1
            sim = nMatch/length(tokens1) + 0.1*nMatch/length(tokens2);
            %fprintf('total number of match: %d/%d, dist: %g\n', nMatch, length(tokens1), dist);
        end
        
        function [seq2idxs, D] = dtw(obj,A)
            [r, c] = size(A);
            
            D = zeros(r, c);
            phi = zeros(r, c);
            
            D(1,1) = A(1,1);
            for j=2:c
                [D(1,j), phi(1,j)] = max([D(1,j-1), A(1,j)]);
            end;
            
            D(:,1) = cumsum(A(:,1));
            phi(:,1) = 2;
            
            for i = 2:r;
                for j = 2:c;
                    [D(i,j), phi(i,j)] = max([D(i,j-1), A(i,j) + D(i-1,j)]);
                end
            end
            
            % Traceback from top left
            i = r;
            j = c;
            q = [];
            while i > 0 && j > 0
                tb = phi(i,j);
                if (tb == 1)
                    j = j-1;
                elseif (tb == 2)
                    q = [j, q];
                    i = i-1;
                else
                    error('unexpected phi value');
                end;
            end
            seq2idxs = q;
            
        end
        
        
        doAlign(obj)
        
        function makeDataFile(obj,mappingFile,outFile)
            
            fp = fopen(mappingFile,'r');
            
            mapping = containers.Map();
            line = fgetl(fp);
            while ischar(line)
                line = strtrim(line);
                elems = regexp(line,'##','split');
                mapping(elems{1}) = elems{2};
                line = fgetl(fp);
            end
            sub_start = [];
            sub_end = [];
            scene_start = [];
            scene_end =[];
            shot_start = [];
            shot_end = [];
            sub_speaker = {};
            
            for i=1:numel(obj.subtitles)
               if(~isempty(obj.subtitles(i).speaker))
                   if(mapping.isKey(obj.subtitles(i).speaker))
                       sub_start(end+1) = obj.subtitles(i).startFrame;
                       sub_end(end+1) = obj.subtitles(i).endFrame;
                       sub_speaker{end+1} = mapping(obj.subtitles(i).speaker);
                       
                   end
               end
            end
            
            shot_start = [obj.shots.startFrame];
            shot_end = [obj.shots.endFrame];
            idx = [obj.shots.isSceneStart];
            scene_start = [obj.shots(idx).startFrame];
            scene_end = scene_start(2:end)-1;
            scene_end(end+1) = shot_end(end);
            save(outFile,'sub_start','sub_end','sub_speaker','shot_start','shot_end','scene_start','scene_end','-append');
            

            
            
        end
        
        function appendAnnotations(obj,trackFile,dataFile,annotationFile)
            load(trackFile);
            [ign track_ids gt] = textread(annotationFile,'%s %d %s');
            speaking_track = false(1,numel(track_ids));
            spk_pred = false(1,numel(track_ids));
            
            tracks = [track_data.track];
            track_start = []; track_end = [];
            for i=1:numel(track_ids)
                idx = tracks==track_ids(i);
                track_start(end+1) = min([track_data(idx).frame]);
                track_end(end+1) = max([track_data(idx).frame]);
            end
            
            use_track = ~(strcmp(gt,'FalsePositive') | strcmp(gt,'Ignore'));
            save(dataFile,'speaking_track','spk_pred','gt','track_ids','track_start','track_end','use_track','-append');
            
        end
        
        function writeSpeakerSubTitleFile(obj,speakerSubTitleFile)
            idx =1;
            fp = fopen(speakerSubTitleFile,'w+');
            for i=1:numel(obj.subtitles)
                if(~obj.subtitles(i).attachToPrev)
                    fprintf(fp,'\n%d\n',idx);
                    fprintf(fp,'%s --> %s\n',obj.subtitles(i).startTime,obj.subtitles(i).endTime);
                    idx = idx + 1;
                end
                fprintf(fp,'%s : %s\n',obj.subtitles(i).speaker,obj.subtitles(i).text);
                if(~obj.subtitles(i).attachToPrev)
                    fprintf(fp,'\n');
                end
            end
            fclose(fp);
        end
    end
    
    
end
