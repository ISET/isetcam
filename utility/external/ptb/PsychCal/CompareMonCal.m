function isSame = CompareMonCal(cal1,cal2,IGNOREDATE)
% isSame = CompareMonCal(cal1,cal2,[IGNOREDATE])
%
% Checks if the two calibrations are the same.  Useful
% for preventing blunders if you have programs that
% precompute and save quantities based on monitor calibrations.
% In that case, this can be used to ensure that current 
% calibration matches the one used to do the pre-computing.
%
% Checks date/time, screen, and computer.  Could check the
% actual data, but that seems like overkill.
% 
% 9/17/97  pbe       Wrote it. 
% 9/18/97  pbe, dhb  Modify interface, change name.
% 1/16/98  dhb       Add any around string compares, necessary for desired effect.
% 1/21/98  dhb       Add IGNOREDATE flag.
% 3/10/98  dhb	     Change name to CompareMonCal.
% 7/3/98   dhb, pbe  Change for cal.describe format.

if (nargin < 3 || isempty(IGNOREDATE))
	IGNOREDATE = 0;
end

isSame = 1;
if (~IGNOREDATE)
	if (~streq(cal1.describe.date,cal2.describe.date))
		%fprintf(1,'CompareCal:\n');
		%fprintf(1,'\tcal1 calibration date: %s',cal1.describe.date);
		%fprintf(1,'\tcal2 calibration date: %s',cal2.describe.date);
		isSame = 0;
	end
end
if (cal1.describe.whichScreen ~= cal2.describe.whichScreen)
	%fprintf(1,'CompareCal:\n');
	%fprintf(1,'\tcal1 calibration screen: %g\n',cal1.describe.whichScreen);
	%fprintf(1,'\tcal2 calibration screen: %g\n',cal2.describe.whichScreen);
	isSame = 0;
end	
if (~streq(cal1.describe.computer,cal2.describe.computer))
	%fprintf(1,'CompareCal:\n');
	%fprintf(1,'\tcal1 computer: %s',cal1.describe.computer);
	%fprintf(1,'\tcal2 computer: %s',cal2.describe.computer);
	isSame = 0;
end
if (~streq(cal1.describe.driver,cal2.describe.driver))
	%fprintf(1,'CompareCal:\n');
	%fprintf(1,'\tcal1 driver: %s\n',cal1.describe.driver);
	%fprintf(1,'\tcal2 driver: %s\n',cal2.describe.driver);
	isSame = 0;
end
if (cal1.describe.dacsize ~= cal2.describe.dacsize)
	%fprintf(1,'CompareCal:\n');
	%fprintf(1,'\tcal1 DAC size: %g\n',cal1.describe.dacsize);
	%fprintf(1,'\tcal2 DAC size: %g\n',cal2.describe.dacsize);
	isSame = 0;
end

