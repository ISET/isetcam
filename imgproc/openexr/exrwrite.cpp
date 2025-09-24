//////////////////////////////////////////////////////////////////////////
//
// exrwrite.cpp
//
// Matlab interface for writting a float image to exr file
//
// exrwrite(img, filename)
//
// img can be 2d (gray) or 3d (color) hdr image
//
// see also exrread.cpp
// 
// Jinwei Gu. 2006/02/10
// jwgu@cs.columbia.edu
//
// Modified by Edgar Velazquez-Armendariz
// <cs#cornell#edu - eva5>
//
// When using mex to compiling it in matlab, make sure to use VC7.1 or above
// instead of VC6. 
//////////////////////////////////////////////////////////////////////////

#if _MSC_VER >= 1600
# define CHAR16_T wchar_t
#endif


#include <mex.h>

#ifdef OCTAVE
	// #include <matrix.h>
    // #include <tmwtypes.h>   // Matlab types
    // #include <ImfNamespace.h>
#else 
    #include <matrix.h>
	#include <tmwtypes.h>   // Matlab types
    #include <ImfNamespace.h>
#endif


#include <ImathBox.h>
#include <ImfRgba.h>
#include <ImfRgbaFile.h>
#include <string>

#include <string>
#include <vector>
#include <memory>
#include <cassert>

#include <mex.h>

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include <half.h>
#include <ImfAttribute.h>
#include <ImfPixelType.h>
#include <ImfCompression.h>
#include <ImfOutputFile.h>
#include <ImfHeader.h>
#include <ImfChannelList.h>
#include <ImathMath.h>
#include <ImfFrameBuffer.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "utilities.h"
#include "ImfToMatlab.h"
#include "MatlabToImf.h"


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using Imath::Box2i;



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
            copyPixels(pixels, (double*)img, width, height, isMonochrome);
            break;
        case mxSINGLE_CLASS:
            copyPixels(pixels, (float*)img, width, height, isMonochrome);
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