
ISET and md5

The new Matlab versions require a slew of mex file extensions, and these appear to change frequently.

The two ISET files that are needed in a mex format are md5 (here) and ieGetMacAdress.

The C++ program for md5 is md5.cpp.

So far, we have been able to compile it properly on all Matlab versions.

Simply change to the directory and execute the following commands

 chdir(fullfile(isetRootPath,'utility','dll70','md5'));
 mex md5.cpp
 movefile(['md5.',mexext],fullfile((isetRootPath,'utility','dll70'))
 path(path)
 which md5

I put these commands into an ISET script in dll70, md5Mex.  We can just run that when this all smooths out in the future.

Brian
