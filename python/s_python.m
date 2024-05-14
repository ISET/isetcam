%% s_python
%
% We installed anaconda3 with its own installer for the Mac M1 on wandell's
% office machine.
%
% https://www.anaconda.com/
%
% After installing anaconda3, it is in ~/opt/anaconda3 and the conda
% command is available.
% 
% We updated conda using the command
%
%   conda update -n base -c defaults conda
%
% We created a py38 envrionment with the command
%
%   conda create -n py38 python=3.8  
%
% We activated the environment with this version of python
%
%   conda activate py38  
%
% So then we had a py38 environment activated as a python environment
%
% Matlab accepted the python environment
%
%   pe = pyenv('Version','/Users/wandell/opt/anaconda3/envs/py38/bin/python');
%
%% May 8, 2024.  We updated to 3.9 using the commands above but replacing 38 with 39
%
%   pe = pyenv('Version','/Users/wandell/opt/anaconda3/envs/py39/bin/python');
%
%% May 13
%
% It seems I had an old Intel version installed. 
%
% We got the miniconda installer, and got an Apple Silicon version.  
% 
%   https://docs.anaconda.com/free/miniconda/
%
% I then created a py39 version using the conda command, as above.
%
%%
% On wandell's Mac at home, which is an Intel machine, we should do
% the same but with miniconda for the Intel architecture.
%
%    NYI
%
