classdef hiddenHandle < matlab.mixin.Copyable & handle
% Empty abstract class inheritated from handle class
% 
% Syntax:
%   hH = hiddenHandle()
%
% Description:
%    The main purpose for this class is to hide all the methods and
%    properties of handle class so that they will not appear in doc or
%    tab-completion
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/15  HJ/BW  Stanford VISTA Team, 2015
%    12/18/17  jnm    Formatting
%    01/19/18  jnm  Formatting update to match Wiki.

methods (Hidden)
    % Hidden methods
    %
    % These methods are still callable, but they will not appear in doc
    % and tab-completion
    function lh = addlistener(varargin)
        lh = addlistener@handle(varargin{:});
    end

    function delete(obj)
        delete@handle(obj)
    end

    function Hmatch = findobj(varargin)
        Hmatch = findobj@handle(varargin{:});
    end

    function mp = findprop(obj, property)
        mp = findprop@handle(obj, property);
    end

    function notify(varargin)
        notify@handle(varargin{:});
    end

    function tf = eq(H1, H2)
        tf = eq@handle(H1, H2);
    end

    function tf = ne(H1, H2)
        tf = ne@handle(H1, H2);
    end

    function tf = lt(H1, H2)
        tf = lt@handle(H1, H2);
    end

    function tf = le(H1, H2)
        tf = le@handle(H1, H2);
    end

    function tf = gt(H1, H2)
        tf = gt@handle(H1, H2);
    end

    function tf = ge(H1, H2)
        tf = ge@handle(H1, H2);
    end
end
end