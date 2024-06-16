%% s_python
%
% Instructions for installing a Python environment into Matlab.
%    Wandell, as instructed by Zhenyi
%    May 24, 2024
%
%% Mac Terminal:  Creating the environment
%
% I downloaded the miniconda installer*, and got an Apple Silicon version
% for the office, or the Intel version for my home.
% 
%   https://docs.anaconda.com/free/miniconda/
%
% I updated conda using the command
%
%   conda update -n base -c defaults conda
%
% I then created a py39 version using the conda command
%
%   conda create -n py39 python=3.9  
%
% I then activated the environment with this version of python
%
%   conda activate py39  
%
% So then we had a py39 environment activated as a python environment,
% which you can see in the terminal window (zsh).
%
%% Incorporating the demosaic requirements
%
% To run the demosaicing code, we need to install the libraries specified
% in the file (isethdrsensor/utility/python/requirements.txt).
%
%    pip install -r requirements.txt
%
%% Matlab
%
% After installation, on the Sonoma version of the MacOS, Matlab created
% the python environment with this command
%
%   pyenv('Version','/opt/miniconda3/envs/py39/bin/python');
%
% I could confirm that Matlab saw the environment by running
%
%   result = py.list([1, 2, 6]);
%
%%  Notes
%
% *  I had older versions of anaconda installed, which I deleted.  If you
% know what you are doing with the larger anaconda install, that should
% work, too.
%
