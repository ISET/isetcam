%  Copyright (c) 2014, Omkar Parkhi
%  All rights reserved.

classdef utils < handle
    
    
    properties
    end

    methods

      function obj = utils()
            
      end

      function K = computeSimilarity(obj,feats)
          if isstr(feats)
            load(feats);
          end
          feats = single(feats);
          K = vl_alldist2(feats);
      end

      function [gt,labelMap] = labelsToGT(obj,labels,labelMap)
          
          if isempty(labelMap)
             labelMap = unique(labels); 
          end
          
          gt = -ones(1,numel(labels));
          
          for i=1:numel(labels)
             gt(i)= find(strcmp(labelMap,labels{i})); 
          end
          
          
      end

      function[scores,trackpairs,pair_gt,sameshot] = makepairs(obj,K,facedets,gt)
            tracks = [facedets.track];
            utracks = unique(tracks);
            [t1 t2] = meshgrid(1:numel(utracks),1:numel(utracks));
            %t1 = t1(:); t2=t2(:);
            t1 = triu(t1,1); t2= triu(t2,1);
            t1 = t1(t1~=0); t2=t2(t2~=0);
            
            idx = sub2ind(size(K),t1,t2);
            scores = K(idx);
            gt1 = gt(t1);
            gt2 = gt(t2);
            pair_gt = 2*(gt1==gt2)-1;
            trackpairs = [utracks(t1);utracks(t2)]';
            
            shots = [facedets.shot];
            trackshots = zeros(1,numel(utracks));
            
            for i=1:numel(trackshots)
                trackshots(i) = unique(shots(tracks==utracks(i)));
            end
            s1 = trackshots(t1);
            s2 = trackshots(t2);
            sameshot = 2*(s1==s2)-1;
            
            
      end
      
      function gtTracks = convertGTTracks(obj,gtTracks)
            temp =[];
            gtTracks = strrep(gtTracks,'.jpg','');
            for i=1:numel(gtTracks)
               temp(i) = str2num(gtTracks{i}); 
            end
            gtTracks = temp;
      end
      
      function idx = getIdxForLabel(obj,labelMap,gt,label)
         labelId = find(strcmp(labelMap,label));
         idx = find(gt==labelId);
      end
      
      function [facedetsMod,featsMod,gtMod,trackIdsMod,labelsMod] = removeItemsFor(obj,labelMap,gt,rmLabels,...
              trackIds,facedets,feats,labels)
          
          idx = {};
          trackIdsMod = [];
          facedetsMod = [];
          featsMod = [];
          
          for i=1:numel(rmLabels)
            idx{i} = obj.getIdxForLabel(labelMap,gt,rmLabels{i});
          end
          idx = cat(2,idx{:});
    
          gtMod = gt;
          gtMod(idx) = [];
          
          
          if(~isempty(trackIds))
              trackIds(idx) = [];
              trackIdsMod = trackIds;
          end
          
          if(~isempty(facedets) && ~isempty(trackIdsMod))
              keepIdx = zeros(1,numel(facedets));
              for i=1:numel(facedets)
                 if(sum((trackIdsMod==facedets(i).track))>0)
                    keepIdx(i) = 1;
                 end
              end
              keepIdx = keepIdx==1;
              facedetsMod = facedets(keepIdx);
          end
   
          
          if(~isempty(feats))
             feats(:,idx) = [];
             featsMod = feats;
          end
           

          
          if(~isempty(labels))
              labels(idx) = [];
              labelsMod = labels;
          end
      end
      
      
%       function [K,gtMod,trackIdsMod,facedetsMod,featsMod,labelsMod] = removeItemsFor(obj,K,labelMap,gt,rmLabels,...
%               trackIds,facedets,feats,labels)
%           
%           idx = {};
%           trackIdsMod = [];
%           facedetsMod = [];
%           featsMod = [];
%           
%           for i=1:numel(rmLabels)
%             idx{i} = obj.getIdxForLabel(labelMap,gt,rmLabels{i});
%           end
%           idx = cat(2,idx{:});
%           K(idx,:) = [];
%           K(:,idx) = [];
%           gtMod = gt;
%           gtMod(idx) = [];
%           
%           
%           if(~isempty(trackIds))
%               trackIds(idx) = [];
%               trackIdsMod = trackIds;
%           end
%           
%           if(~isempty(facedets) && ~isempty(trackIdsMod))
%               keepIdx = zeros(1,numel(facedets));
%               for i=1:numel(facedets)
%                  if(sum((trackIdsMod==facedets(i).track))>0)
%                     keepIdx(i) = 1;
%                  end
%               end
%               keepIdx = keepIdx==1;
%               facedetsMod = facedets(keepIdx);
%           end
%    
%           
%           if(~isempty(feats))
%              feats(:,idx) = [];
%              featsMod = feats;
%           end
%            
% 
%           
%           if(~isempty(labels))
%               labels(idx) = [];
%               labelsMod = labels;
%           end
%       end
          
          function [facedets] = mergeInShot(obj,facedets,scores,trackpairs,isSameShot)
             
             trackpairs = sort(trackpairs,2);
             [ign perm] = sort(trackpairs(:,1),1);
             
             trackpairs = trackpairs(perm,:);
             scores = scores(perm);
             isSameShot = isSameShot(perm);
            
             idx = find(scores<=35 & isSameShot'==1);
             mergePairs = trackpairs(idx,:);
             clusters = 1:size(mergePairs,1);
            
             newClusterId = size(mergePairs,1)+1;
             
             for j=1:size(mergePairs,1);
                 %if(merged(j)~=1)
                     
                     idx = find(mergePairs(:,1)==mergePairs(j,2)|mergePairs(:,2)==mergePairs(j,2));
                     %if(j==1)
                         idx1 = find(mergePairs(:,1)==mergePairs(j,1)|mergePairs(:,1)==mergePairs(j,1));
                         idx = unique(cat(1,idx,idx1));
                     %end
                     idx(idx<=j) = [];
                     if(~isempty(idx))
                         useClusters = [];
                         for k=1:numel(idx)
                             %if(merged(idx(k))==1)
                                 useClusters(end+1) =  clusters(idx(k));
                             %end
                         end
                         useClusters(end+1) = clusters(j);
                         useClusters = unique(useClusters);
                         for k =1: numel(useClusters)
                            idx = find(clusters == useClusters(k));
                            clusters(idx) = newClusterId;
                            %merged(j)
                         end
                         newClusterId = newClusterId +1;
                     end
                     %merged(j) = 1;
                 %end
             end
             
             minTrack = [];
             trackLink ={};
             
             uClusters = unique(clusters);
             
             for j=1:numel(uClusters)
                idx = find(clusters == uClusters(j));
                linkTracks = unique(mergePairs(idx,:));
                minTrack(end+1) = linkTracks(1);
                trackLink{end+1} = linkTracks(2:end);
             end
             
             tracks = [facedets.track];
             utracks = unique(tracks);
             clusters = 1:numel(utracks);
             newClusterId = numel(clusters)+1;
             for i=1:numel(utracks)
                 idx = find(minTrack==utracks(i));
                 if(~isempty(idx))
                     currTracks = [minTrack(idx);trackLink{idx}];
                     for j=1:numel(currTracks)
                         clusters(utracks==currTracks(j)) = newClusterId;
                     end
                     newClusterId = newClusterId+1;
                 end
                 
             end
             
             outtracks = {};
             uClusters = unique(clusters);
             
             for i=1:numel(uClusters)
                cidx = find(clusters == uClusters(i));
                ctdata = [];
                for j=1:numel(cidx)
                    tidx = tracks == utracks(cidx(j));
                    ctdata = cat(2,ctdata,facedets(tidx));
                end
                if numel(cidx)>1
                    shot_merged = 1;
                else
                    shot_merged = 0;
                end
                    minTrack = min([ctdata.track]);
                    for j=1:numel(ctdata)
                        ctdata(j).track = minTrack;
                        ctdata(j).shot_merged = shot_merged;
                    end
                %end
                outtracks{end+1} = ctdata;
             end
             facedets = cat(2,outtracks{:});
             
%              merged = zeros(1,numel(utracks));
%              for j=1:numel(utracks)
%                  if(merged(j)==0)
%                      idx = find(minTrack==utracks(j));
%                      if(isempty(idx))
%                          tidx = tracks == utracks(j);
%                          outtracks{end+1} = facedets(tidx);
%                          merged(j)=1;
%                      else
%                          currTracks = [minTrack(idx) trackLink{idx}];
%                          ctdata = [];
%                          for k=1:numel(currTracks)
%                              tidx = tracks == currTracks(k);
%                              ctdata = cat(2,ctdata,facedets(tidx));
%                          end
%                          for k=1:numel(ctdata)
%                              ctdata(k).track = currTracks(1);
%                          end
%                      end
%                      outtracks{end+1} =ctdata;
%                  end
%              end
%              facedets = cat(2,outtracks{:}); 
%              utracks1 = unique([facedets.track]);
          end
          
          function [feats,gt,trackIds,labels] = reorganise(obj,facedets,feats,gt,trackIds,labels)
                utracks = unique([facedets.track]);
                reorder = [];
                for i=1:numel(utracks)
                    reorder(i) = find(trackIds==utracks(i));
                end
                feats = feats(:,reorder);
                gt = gt(reorder);
                trackIds = trackIds(reorder);
                labels = labels(reorder);
          end
          
          function track_shots = getTrackShots(obj,facedets)
              track_shots = [];
              tracks = [facedets.track];
              shots = [facedets.shot];
              utracks = unique(tracks);
              
              for i=1:numel(utracks)
                  track_shots(i) = unique(shots(tracks==utracks(i)));
              end
          end
          function tOvl = getTemporalOverlap(obj,facedets,trackIds,track_shots)
             tOvl = zeros(numel(trackIds));
             
             uTrackShots =  unique(track_shots);
             tracks = [facedets.track];
             frames = [facedets.frame];
             for i=1:numel(uTrackShots)
                idx = find(track_shots == uTrackShots(i));
                if(numel(idx)>1)
                    for j=1:numel(idx)
                        for k=j+1:numel(idx)
                            cIdx1 = idx(j);
                            cIdx2 = idx(k);
                            t1 = trackIds(cIdx1);
                            t2 = trackIds(cIdx2);
                            f1 = frames(tracks==t1);
                            f2 = frames(tracks==t2);
                            sf1 = min(f1); ef1 = max(f1);
                            sf2 = min(f2); ef2 = max(f2);
                            ov = calcBoxOverlap([sf1;1;ef1;10],[sf2;1;ef2;10]);
                            if any(ov)>0
                                tOvl(cIdx1,cIdx2) = 1;
                                tOvl(cIdx2,cIdx1) = 1;
                            end
                            
                        end
                    end
                end
             end
             
             
          end
      end

    end


