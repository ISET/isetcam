function pause(H)
%PAUSE Pause playback of movie in movie player
%  Note that the play and pause methods are identical.
%  Pause is equivalent to calling play.

feval(H.fcns.play,[],[],H.hfig);
