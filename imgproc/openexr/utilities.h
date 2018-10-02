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


#pragma once

namespace OpenEXRforMatlab
{

// Get the number of CPUs in the system
int getNumCPUs();

// Generic initialization for Matlab: sets up the number of threads to
// use in OpenEXR and registers the exit callback.
void mexEXRInit();

} // namespace OpenEXRforMatlab