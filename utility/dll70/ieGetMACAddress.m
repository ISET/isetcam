function MAC = ieGetMACAddress
%Read the local machine's MAC address
%
%   MAC = ieGetMacAdress
%
% This M-file is used for Linux and Apple architectures. For Windows there
% is a ieGetMACAddress mex file.  That one seems faster and pretty
% reliable.  But we had one site where it failed so I wrote this one as an
% alternate.
%
% The routine works by calling ipconfig, searching for the Physical Address
% and then manipulating the string.
%
% The separators in the MAC address are : to match ieGetMACAddress. Thus,
% an example address is 00:13:02:64:fd:09
%
% This routine is used whenever the license is checked for certain types of
% licenses.  It is slower than the mex-file ieGetMACAddress.  It is faster
% than nothing.
%
% The routine GetMAC might also be used, but it doesn't seem faster (maybe
% slower).  There may be java options.  See comments below.  These may be
% faster.
%
% This routine is mainly used to set up the original key.  There are some
% sites that use this routine every time a window is opened (if the key is
% locked to the particular computer rather than to a particular user). But
% that is not typical.
%
% Example:
%  ieGetMACAddress
%
% Copyright, ImagEval 2006
%

% TODO - Matlab central has another suggestion (this one came from there).
%
%  	Date: 2005-08-16
% From: Michael Kleder(mkleder@hotmail.com) Rating: Comments: Good approach
% if java isn't an option, such as when running matlab with "matlab -nojvm"
% or if a Java call isn't desired. If Java is an option, I've had good luck
% with: char(java.net.InetAddress.getLocalHost.toString)
%
% This is the wrong with: java.net.InetAddress.getLocalHost
% f = java.NetworkInterface.getHardwareAdress('')
% See other stuff at the end of the file

if ispc
    % The first physical address is always read.  This is not the case when
    % using the dll form of this function.
    str = strread(evalc('!ipconfig -all'),'%s','delimiter','\n'); 
    for ii=1:length(str)
        n = strfind(str{ii},'Physical Address. . . . . . . . . : ');
        if ~isempty(n),
            a = str{ii};
            c = strfind(str{ii},':');
            MAC = lower(strrep(a((c+1):end),'-',':'));
            return;
        end
    end
elseif isunix && ~ismac
    % The first physical address is always read.  We don't yet have a dll
    % form of this function.
    [s, macaddress] = unix('ifconfig |grep -i ether');
    c = strfind(lower(macaddress),'hwaddr ');
    enet=c(1);
    MAC = macaddress((enet+7):(enet+23));
elseif ismac
    [s, macaddress] = unix('ifconfig |grep -i ether');
    c = strfind(lower(macaddress),'ether ');
    enet=c(1);
    MAC = macaddress((enet+6):(enet+22));
else error('Unknown system');
    
end  

return;

% % 
% tic, 
% for ii=1:2, strread(evalc('!ipconfig -all'),'%s','delimiter','\n'); end; 
% toc
% % 
% tic, 
% for ii=1:2, a = evalc('!GetMAC'); end; 
% toc
