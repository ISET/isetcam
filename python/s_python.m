%% s_python
%
% We installed anaconda with its own installer for the Mac M1
% (https://www.anaconda.com/).
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
% pe = pyenv('Version','/Users/wandell/opt/anaconda3/envs/py38/bin/python');
%
