% We took the sony CMOS QE from this page
% Sony CMOS from here 
% 
% https://scientificimaging.com/knowledge-base/quantum-efficiency-and-spectral-responsivity-of-scmos-and-cmos-imagers/#:~:text=If%2077%20of%20every%20100,on%20sCMOS%20and%20CMOS%20imagers.
%
% We got Gemini to read the graph and return the numbers.  Better than
% grabit, I think?
%

%% Read by Gemini. Checked by Peter C!

X = [ ...
150,0
180,0
210,0
240,0
270,0
300,0
330,12
360,27
390,41
420,50
450,60
480,70
510,76
540,77
570,71
600,60
630,52
660,45
690,38
720,33
750,29
780,25
810,22
840,18
870,15
900,12
930,9
960,7
990,5
1020,3
1050,1
1080,0];

%%
ieSaveSpectralFile(X(:,1),X(:,2)/100,'Sony CMOS from here https://scientificimaging.com/knowledge-base/quantum-efficiency-and-spectral-responsivity-of-scmos-and-cmos-imagers/#:~:text=If%2077%20of%20every%20100,on%20sCMOS%20and%20CMOS%20imagers.','sonyCMOSQE.mat');
