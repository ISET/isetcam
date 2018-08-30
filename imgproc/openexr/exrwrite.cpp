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


#include <string>

#include <mex.h>
#include <matrix.h>
#include <tmwtypes.h>

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include <ImathBox.h>
#include <ImfRgba.h>
#include <ImfRgbaFile.h>
#include <ImfNamespace.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "utilities.h"


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using namespace Imath;


// Templated function to copy data from either a float or a double array
template <class T>
void copyPixels(Rgba *pixels, const T *img, int width, int height, 
    bool isMonochrome = false)
{
    // Stride to write the same value in all channels when the image
    // is monochromatic
    const int A = isMonochrome ? 0 : width*height;
    
    // Copy the pixels
    for(int i=0; i<height; ++i)
    for(int j=0; j<width;  ++j)
    {
        int k = j*height+i;
        pixels[i*width+j].r = (half)((float)img[k]);
        pixels[i*width+j].g = (half)((float)img[k+A]);
        pixels[i*width+j].b = (half)((float)img[k+2*A]);
        pixels[i*width+j].a = 1.0f;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    OpenEXRforMatlab::mexEXRInit();

    /* Check for proper number of arguments */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Two input arguments required.");
    } else if (nlhs != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Too many output arguments.");
    }

    int width = 0, height = 0;
   
    const mwSize nd = mxGetNumberOfDimensions(prhs[0]);
    if(nd == 2) {
        height = (int)mxGetM(prhs[0]);
        width  = (int)mxGetN(prhs[0]);
    } else if(nd == 3) {
        height = (int)mxGetM(prhs[0]);
        width  = (int)mxGetN(prhs[0])/3;
    } else {
        mexErrMsgIdAndTxt("OpenEXR:argument",
            "\"img\" must be either a 2d or 3d matrix.");
    }

    char *outputfilePtr = mxArrayToString(prhs[1]);
    if (outputfilePtr == NULL) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Invalid filename argument.");
    }
    // Copy to a string so that the matlab memory may be freed asap
    const std::string outputfile(outputfilePtr);
    mxFree(outputfilePtr); outputfilePtr = static_cast<char*>(0);

    // Uses matlab's alloc, so that the memory if released when
    // the control returns to matlab
    Rgba *pixels = (Rgba*)mxCalloc(width*height, sizeof(Rgba));
    
    const bool isMonochrome = nd==3 ? false : true;
    
    // We only know how to write real data, so we cast img to the
    // right type, and the template will do the magic, or just
    // raise an error
    if (mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt( "OpenEXR:unsupported",
                "Matrices of complex data are unsupported." );
    }
    void *img = mxGetPr(prhs[0]);
    mxClassID category = mxGetClassID(prhs[0]);
    switch (category) {
        case mxDOUBLE_CLASS:
            copyPixels(pixels, (real64_T*)img, width, height, isMonochrome);
            break;
        case mxSINGLE_CLASS:
            copyPixels(pixels, (real32_T*)img, width, height, isMonochrome);
            break;
        case mxINT8_CLASS:
            copyPixels(pixels, (int8_T*)img, width, height, isMonochrome);
            break;
        case mxINT16_CLASS:
            copyPixels(pixels, (int16_T*)img, width, height, isMonochrome);
            break;
        case mxINT32_CLASS:
            copyPixels(pixels, (int32_T*)img, width, height, isMonochrome);
            break;
        case mxINT64_CLASS:
            copyPixels(pixels, (int64_T*)img, width, height, isMonochrome);
            break;
        case mxUINT8_CLASS:
            copyPixels(pixels, (uint8_T*)img, width, height, isMonochrome);
            break;
        case mxUINT16_CLASS:
            copyPixels(pixels, (uint16_T*)img, width, height, isMonochrome);
            break;
        case mxUINT32_CLASS:
            copyPixels(pixels, (uint32_T*)img, width, height, isMonochrome);
            break;
        case mxUINT64_CLASS:
            copyPixels(pixels, (uint64_T*)img, width, height, isMonochrome);
            break;
         
        default:
            mexErrMsgIdAndTxt( "OpenEXR:unsupported",
                "Matrices of type %s are unsupported.", 
                mxGetClassName(prhs[0]) );
    }

    try {
        RgbaOutputFile file(outputfile.c_str(), width, height, WRITE_RGB);
        file.setFrameBuffer(pixels, 1, width);
        file.writePixels(height);
    }
    catch( std::exception &e ) {
        mexErrMsgIdAndTxt("OpenEXR:exception", e.what());
    }

    // We don't need to explicitly delete the data because we
    // allocated it with mxCalloc
    /*delete[] pixels; pixels = NULL;*/
}
