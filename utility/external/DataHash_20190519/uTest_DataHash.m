function uTest_DataHash(doSpeed)
% Automatic test: DataHash (Mex)
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% uTest_DataHash(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%   The speed is compared to a Java method.
%
% Tested: Matlab 2009a, 2015b(32/64), 2016b, 2018b, Win7/10
% Author: Jan Simon, Heidelberg, (C) 2009-2019 matlab.2010(a)n(MINUS)simon.de

% $JRev: R-e V:004 Sum:cYYIAiiAf7sM Date:19-May-2019 16:58:59 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\UnitTests_\uTest_DataHash.m $
% History:
% 001: 02-Mar-2019 19:22, First version.

%#ok<*STRQUOT>   % Accept string('s') for R2016b
%#ok<*STRCLQT>
 
% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
ErrID = ['JSimon:', mfilename];

MatlabV = [100, 1] * sscanf(version, '%d.', 2);

% Initial values: --------------------------------------------------------------
if nargin == 0
   doSpeed = true;
end

% Program Interface: -----------------------------------------------------------
% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
fprintf('==== Test DataHash:  %s\n', datestr(now, 0));
fprintf('  Matlab: %s\n',   version);

fprintf('  Java:   %s\n\n', version('-java'));

% Known answer tests - see RFC1321: --------------------------------------------
disp('== Known answer tests:');

S.a = uint8([]);
S.b = {{1:10}, struct('q', uint64(415))};

TestData = { ...
   ... % Desc, Data, Opt, Result:
   '[]', [], {}, '5b302b7b2099a97ba2a276640a192485'; ...
   ...
   'int32(1:10), short, MD5', int32(1:10), {'short', 'MD5'}, ...
   '+tJN9yeF89h3jOFNN55XLg'; ...
   ...
   'int32(1:10), short, MD5, Opt as struct', int32(1:10), ...
   {struct('Format', 'short', 'Method', 'MD5')}, ...
   '+tJN9yeF89h3jOFNN55XLg'; ...
   ...
   'Struct, HEX, SHA-1', S, ...
   {'HEX', 'SHA-1'}, '18672BE876463B25214CA9241B3C79CC926F3093'; ...
   ...
   'Binary, SHA-1', 1:8, {'SHA-1', 'bin'}, ...
   '826cf9d3a5d74bbe415e97d4cecf03f445f69225'; ...
   ...
   '''abc'', SHA-256, ASCII', 'abc', {'SHA-256', 'ascii'}, ...
   'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'; ...
   ...
   'uint8(''abc''), SHA-256, ASCII', uint8('abc'), {'SHA-256', 'bin'}, ...
   'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'; ...
   ...
   'message digest, MD5, bin', 'message digest', {'MD5', 'ascii'}, ...
   'f96b697d7cb7938d525a2f31aaf161d0'; ...
   ...
   'char(0:255), MD5, bin', char(0:255), {'MD5', 'ascii'}, ...
   'e2c865db4162bed963bfaa9ef6ac18f0'; ...
   ...
   'char(0:255), MD5, bin', char(0:255), {'MD5', 'Array'}, ...
   '1e4558b49c05611cdb280a79cb2dbe34'; ...
   ...
   '[], SHA-256, base64', 1:33, {'SHA-256', 'base64'}, ...
   'SuuPZKpce2KetxeIClt1EXz/mCztEuYiawG9vaxKcfc='; ...
   ...
   '[], SHA-256, base64', 1:33, {'SHA-512', 'base64'}, ...
   ['V9Yp/ZBUbfmzQZ7WRzRvqNYLbb6Kzgrc3iaqPH7ta8MS/bMPKc7j', ...
   '+FRV5Oexu3OCOQ1+2p/E+ZcgKyRHheq0kQ==']; ...
   ...
   '[], MD5, short', 1:33, {'MD5', 'short'}, ...
   'RoNguVVzgq6s7ll9xoCSSg'; ...
   ...
   '[], SHA-256, short', 1:33, {'SHA-512', 'short'}, ...
   ['V9Yp/ZBUbfmzQZ7WRzRvqNYLbb6Kzgrc3iaqPH7ta8MS/bMPKc7j', ...
   '+FRV5Oexu3OCOQ1+2p/E+ZcgKyRHheq0kQ']; ...
   ...
   };

% Create string arrays, if possible:
if MatlabV >= 901  % R2016b
   TestData = cat(1, TestData, { ...
      '"", array', string(''), {'Array'}, ...
      '061bdd545213c6a236e0f3d655e38ff4'; ...
      ...
      '"hello", array', string('hello'), {'Array'}, ...
      '2614526bcbd4af5a8e7bf79d1d0d92ab'; ...
      ...
      '["hello", "world"]', string({'hello', 'world'}), {'Array'}, ...
      'a1bdbbe9a15c249764847ead9bf47326'; ...
      ...
      '["hello"; ""; "world"]', string({'hello'; ''; 'world'}), {'Array'}, ...
      'a6df2dc811d4e8dab214c01ce0dfc4b9'; ...
      ...
      '"", ascii', string(''), {'ascii'}, ...
      'd41d8cd98f00b204e9800998ecf8427e'; ...
      ...
      '"hello", ascii', string('hello'), {'ascii'}, ...
      '5d41402abc4b2a76b9719d911017c592'; ...
      ...
      });
end

% Run the known answer tests:
for iTest = 1:size(TestData, 1)
   Test = TestData(iTest, :);
   R    = DataHash(Test{2}, Test{3}{:});
   if isequal(R, Test{4})
      fprintf('  ok: %s\n', Test{1});
   else
      fprintf(2, 'Want: %s\nGot:  %s\n', Test{4}, R);
      error([ErrID, ':KAT'], 'Failed: %s', Test{1});
   end
end

% Create test file:
TestFile = fullfile(tempdir, [mfilename, '.txt']);
TestData = {'', 'd41d8cd98f00b204e9800998ecf8427e'; ...
   ...
   'abcdefghijklmnopqrstuvwxyz', ...
   'c3fcd3d76192e4007dfb496cca67e13b'; ...
   ...
   'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', ...
   'd174ab98d277d9f5a5611c2c9f419d9f'; ...
   ...
   ['123456789012345678901234567890123456789012345678901234567890123456', ...
   '78901234567890'], ...
   '57edf4a22be3c955ac49da2e2107b67a'; ...
   ...
   char(0:255), 'e2c865db4162bed963bfaa9ef6ac18f0'};

try
   for iTest = 1:size(TestData, 1)
      Test = TestData(iTest, :);
      
      % Create the file:
      [fid, msg] = fopen(TestFile, 'w');
      assert(fid ~= -1, msg);
      fwrite(fid, Test{1});
      fclose(fid);
   
      % Get hash for the file:
      R    = DataHash(TestFile, 'File');
      Want = DataHash(Test{1}, 'ascii');
      if isequal(R, Want, Test{2})
         fprintf('  ok: empty file\n');
      else
         fprintf(2, 'Want: %s\nGot:  %s\n', Want, R);
         error([ErrID, ':KAT'], 'Failed: File access');
      end
   end
   
catch ME
   if exist(TestFile, 'file')
      delete(TestFile);
   end
   rethrow(ME);
end

delete(TestFile);

% Check different output types: ------------------------------------------------
N   = 1000;
B64 = org.apache.commons.codec.binary.Base64;
   
disp('== Check output types:');
for i = 1:N
   data      = uint8(fix(rand(1, 1 + fix(rand * 100)) * 256));
   lowHexOut = DataHash(data, 'bin', 'hex');
   upHexOut  = DataHash(data, 'bin', 'HEX');
   decOut    = DataHash(data, 'bin', 'Double');
   base64Out = DataHash(data, 'bin', 'Base64');
   shortOut  = DataHash(data, 'bin', 'short');
   uint8Out  = DataHash(data, 'bin', 'Uint8');

   base64pad   = char(B64.encode(decOut)).';
   base64short = strrep(base64pad, '=', '');
      
   if not(strcmpi(lowHexOut, upHexOut) && ...
         isSame(sscanf(lowHexOut, '%2x'), decOut(:)) && ...
         isSame(base64Out, base64pad) && ...
         isSame(shortOut, base64short) && ...
         isSame(uint8Out, uint8(decOut)))
      fprintf('\n');
      error([ErrID, ':Output'], 'Different results for output types.');
   end
   
   % Check binary, e.g. if the data length is a multiple of 2:
   if rem(length(data), 2) == 0
      doubleData = double(data);
      uniData    = char(doubleData(1:2:end) + 256 * doubleData(2:2:end));
      uniOut     = DataHash(uniData, 'binary', 'double');
      if not(isequal(uniOut, decOut))
         error([ErrID, ':Output'], 'Different results for binary mode.');
      end
   end
end
fprintf(['  ok: %d random tests with hex, HEX, double, uint8, base64 ', ...
   'output\n'], N);

% Check arrays as inputs: ------------------------------------------------------
disp('== Test array input:');

% Hash must depend on the type of the array:
S1 = DataHash([], 'Array');
if ~isequal(S1, '5b302b7b2099a97ba2a276640a192485')
   error([ErrID, ':Array'], 'Bad result for array: []');
end

S1 = DataHash(uint8([]), 'Array');
if ~isequal(S1, 'cb8a2273d1168a72b70833bb0d79be13')
   error([ErrID, ':Array'], 'Bad result for array: uint8([])');
end

S1 = DataHash(int8([]), 'Array');
if ~isequal(S1, '0160dd4473fe1a952572be239e077ed3')
   error([ErrID, ':Array'], 'Bad result for array: int8([])');
end

Data = struct('Field1', 'string', 'Field2', {{'Cell string', '2nd string'}});
Data.Field3 = Data;
S1   = DataHash(Data, 'Array');
if ~isequal(S1, '4fe320b06e3aaaf4ba712980d649e274')
   error([ErrID, ':Array'], 'Bad result for array: <struct>.');
end

Data = sparse([1,0,2; 0,3,0; 4, 0,0]);
S1   = DataHash(Data, 'Array');
if ~isequal(S1, 'f157bdc9173dff169c782dd639984c82')
   error([ErrID, ':Array'], 'Bad result for array: <sparse>.');
end
fprintf('  ok: Array\n');

% Uninitialized cells contain NULL pointers:
Data = cell(1, 2);
S1   = DataHash(Data, 'Array');
if ~isequal(S1, '161842037bc65b9f3bceffdeb4a8d3bd')
   error([ErrID, ':Array'], 'Bad result for {NULL, NULL}.');
end
fprintf('  ok: Null pointer\n');

% Check string type:
if MatlabV >= 901  % R2016b
   Data = string('hello');
   S1   = DataHash(Data, 'Array');
   if ~isequal(S1, '2614526bcbd4af5a8e7bf79d1d0d92ab')
      error([ErrID, ':String'], 'Bad result for string.');
   end
   
   Data = string({'hello', 'world'});
   S1   = DataHash(Data, 'Array');
   if ~isequal(S1, 'a1bdbbe9a15c249764847ead9bf47326')
      error([ErrID, ':String'], 'Bad result for string.');
   end
   fprintf('  ok: String class\n');
end

% Speed test: ------------------------------------------------------------------
if doSpeed
   disp('== Test speed:');
   disp('  * Slower for shorter data due to overhead of calling a function!');
   disp('  * Process data in memory, not from disk');
   Delay = 2;
   
   % Compare speed with the C-mex GetMD5, if available:
   getmd5_M = which('GetMD5.m');
   getmd5_X = which(['GetMD5.', mexext]);
   if ~isempty(getmd5_M) && ~isempty(getmd5_X)
      Str       = fileread(getmd5_M);
      hasGetMD5 = any(strfind(Str, 'Author: Jan Simon'));
   else
      hasGetMD5 = false;  % [BUGFIX] 17-May-2019, Thanks zmi zmi
   end
   
   if hasGetMD5
      fprintf('  * Compare with: %s\n', getmd5_X);
      fprintf('  * DataHash uses Java for the hashing, GetMD5 fast C code\n\n');
      fprintf('  Data size:     DataHash:      GetMD5:\n');
   else
      fprintf('\n  Data size:     DataHash:\n');
   end
   
   for Len = [10, 100, 1000, 10000, 1e5, 1e6, 1e7, 1e8]
      [Number, Unit] = UnitPrint(Len, false);
      fprintf('%12s ', [Number, ' ', Unit]);
      data = uint8(fix(rand(1, Len) * 256));
      
      % Measure time:
      iLoop = 0;
      Time  = 0;
      tic;
      while Time < Delay || iLoop < 2
         Hash  = DataHash(data, 'binary', 'uint8');
         iLoop = iLoop + 1;
         Time  = toc;
      end
      LoopPerSec     = iLoop / Time;
      [Number, Unit] = UnitPrint(LoopPerSec * Len, true);
      
      if hasGetMD5  % Compare with GetMD5, if available:
         iLoop = 0;
         Time  = 0;
         tic;
         while Time < Delay || iLoop < 2
            Hash2 = GetMD5(data, 'binary', 'uint8');
            iLoop = iLoop + 1;
            Time  = toc;
         end
         LoopPerSec2      = iLoop / Time;
         [Number2, Unit2] = UnitPrint(LoopPerSec2 * Len, true);
         
         fprintf('%8s %s/s  %9s %s/s\n', Number, Unit, Number2, Unit2);
         
         % Compare the results:
         if ~isequal(Hash, Hash2)
            error([ErrID, ':Compare'], 'Result differs from GetMD5.');
         end
         
      else
         fprintf('%8s %s/s\n', Number, Unit);
      end
   end
end

fprintf('\n== DataHash passed the tests.\n');
   
end

% ******************************************************************************
function E = isSame(A, B)
E = isequal(A, B) && strcmp(class(A), class(B));
end

% ******************************************************************************
function [Number, Unit] = UnitPrint(N, useMB)

if N >= 1e6 || useMB
   Number = sprintf('%.1f', N / 1e6);
   Unit   = 'MB';
elseif N >= 1e3
   Number = sprintf('%.1f', N / 1000);
   Unit   = 'kB';
else
   Number = sprintf('%g', N);
   Unit   = ' B';
end

end
