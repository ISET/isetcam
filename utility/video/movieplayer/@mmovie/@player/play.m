function play(H)
%PLAY Play or resume playback of movie in movie player

feval(H.fcns.play,[],[],H.hfig);
