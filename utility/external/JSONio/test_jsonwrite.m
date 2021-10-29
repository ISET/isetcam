function tests = test_jsonwrite
% Unit Tests for jsonwrite

% $Id: test_jsonwrite.m 7526 2019-02-06 14:33:18Z guillaume $

tests = functiontests(localfunctions);


function test_jsonwrite_array(testCase)
exp = {'one';'two';'three'};
act = jsonread(jsonwrite(exp));
testCase.verifyTrue(isequal(exp, act));

exp = 2;
act = nnz(jsonwrite(1:3) == ',');
testCase.verifyTrue(isequal(exp, act));

function test_jsonwrite_object(testCase)
exp = struct('Width',800,'Height',600,'Title','View from the 15th Floor','Animated',false,'IDs',[116;943;234;38793]);
act = jsonread(jsonwrite(exp));
testCase.verifyTrue(isequal(exp, act));

function test_jsonwrite_all_types(testCase)
exp = [];
act = jsonread(jsonwrite(exp));
testCase.verifyTrue(isequal(exp, act));

exp = [true;false];
act = jsonread(jsonwrite(exp));
testCase.verifyTrue(isequal(exp, act));

exp = struct('a','');
act = jsonread(jsonwrite(exp));
testCase.verifyTrue(isequal(exp, act));

str = struct('str',reshape(1:9,3,3));
exp = jsonread('{"str":[[1,4,7],[2,5,8],[3,6,9]]}');
act = jsonread(jsonwrite(str));
testCase.verifyTrue(isequal(act, exp));

str = [1,2,NaN,3,Inf];
exp = jsonread('[1,2,null,3,null]');
act = jsonread(jsonwrite(str));
testCase.verifyTrue(isequaln(act, exp));

%function test_jsonwrite_chararray(testCase)
%str = char('one','two','three');
%exp = {'one  ';'two  ';'three'};
%act = jsonread(jsonwrite(str));
%testCase.verifyTrue(isequal(exp, act));

function test_options(testCase)
exp = struct('Width',800,'Height',NaN,'Title','View','Bool',true);
jsonwrite(exp,'indent','');
jsonwrite(exp,'indent','  ');
jsonwrite(exp,'replacementStyle','underscore');
jsonwrite(exp,'replacementStyle','hex');
jsonwrite(exp,'convertInfAndNaN',true);
jsonwrite(exp,'convertInfAndNaN',false);
jsonwrite(exp,'indent',' ','replacementStyle','hex','convertInfAndNaN',false);
jsonwrite(exp,struct('indent','\t'));
jsonwrite(exp,struct('indent','\t','convertInfAndNaN',false));
