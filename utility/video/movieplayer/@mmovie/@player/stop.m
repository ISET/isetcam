function stop(H)
%STOP Halt playback of movie in movie player

feval(H.fcns.stop,[],[],H.hfig);
