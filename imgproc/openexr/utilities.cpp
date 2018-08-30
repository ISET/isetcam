/*============================================================================
 
 OpenEXR for Matlab
 
 Distributed under the MIT License (the "License");
 see accompanying file LICENSE for details
 or copy at http://opensource.org/licenses/MIT
 
 Originated from HDRITools - High Dynamic Range Image Tools
 Copyright 2011 Program of Computer Graphics, Cornell University
 
 This software is distributed WITHOUT ANY WARRANTY; without even the
 implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the License for more information.
 -----------------------------------------------------------------------------
 Authors:
 Jinwei Gu <jwgu AT cs DOT cornell DOT edu>
 Edgar Velazquez-Armendariz <eva5 AT cs DOT cornell DOT edu>
 Manuel Leonhardt <leom AT hs-furtwangen DOT de>
 
 ============================================================================*/


#if defined(_WIN32)
  #define WINDOWS_LEAN_AND_MEAN
  #include <windows.h>
#elif USE_SYSCONF
  #include <unistd.h>
#endif

#include <mex.h>

#include <ImfThreading.h>

#include "utilities.h"


namespace
{

// Actual function to get the number of CPUs
inline int get_num_cpus()
{
#if defined(_WIN32)
    SYSTEM_INFO info;
    GetSystemInfo(&info);
    const int n = (int)info.dwNumberOfProcessors;
    return n > 0 ? n : 1;
#elif USE_SYSCONF
    const int n = sysconf(_SC_NPROCESSORS_ONLN);
    return n > 0 ? n : 1;
#else
    // Nothing better
    return 1;
#endif
}

} // namespace


int OpenEXRforMatlab::getNumCPUs()
{
    static int numCPUs = get_num_cpus();
    return numCPUs;
}


// Exit callback
extern "C" void mexEXRExitCallback(void)
{
    OPENEXR_IMF_INTERNAL_NAMESPACE::setGlobalThreadCount(0);
}


void OpenEXRforMatlab::mexEXRInit()
{
    static bool initialized = false;
    if (!initialized) {
        // Use up to 75% of CPUs to avoid oversubscription
        const int numCPUs = (3*getNumCPUs() + 3) / 4;
        OPENEXR_IMF_INTERNAL_NAMESPACE::setGlobalThreadCount(numCPUs);
        mexAtExit(mexEXRExitCallback);
        initialized = true;
    }
}
