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

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include <ImathBox.h>
#include <ImfRgba.h>
#include <ImfRgbaFile.h>
#include <ImfInputFile.h>
#include <ImfChannelList.h>
#include <ImfArray.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "utilities.h"


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using namespace Imath;


namespace
{

// Read the RGB pixels using the simplfied interface
void readPixels(float * buffer, RgbaInputFile & file)
{
    const Box2i & dw = file.header().dataWindow();
    const int width  = dw.max.x - dw.min.x + 1;
    const int height = dw.max.y - dw.min.y + 1;

    Array2D<Rgba> halfPixels(height, width);
    const off_t offset = - dw.min.x - dw.min.y * width;

    file.setFrameBuffer(&halfPixels[0][0] + offset, 1, width);
    file.readPixels(dw.min.y, dw.max.y);

    // Write into the target buffer
    const off_t planeOffset = width * height;
    float * r = buffer;
    float * g = r + planeOffset;
    float * b = g + planeOffset;
    const off_t xStride = height;
    const off_t yStride = 1;

    // Traverse the image in column-major order. Perhaps it is more
    // efficient to copy the data in the same order and then call
    // the native Matlab transpose, but this should be decent enough.
    for (int h = 0; h < height; ++h) {
        const Rgba* scanline = halfPixels[h];
        off_t xOffset = 0;
        for (int w = 0; w < width; ++w, xOffset += xStride) {
            const Rgba & px = scanline[w];
            const off_t idx = xOffset + h*yStride;
            r[idx] = px.r;
            g[idx] = px.g;
            b[idx] = px.b;
        }
    }
}


// Read the RGB channels using the general interface. This load
// only the R,G,B channels of the image
void readPixels(float * buffer, InputFile & file)
{
    const Box2i & dw = file.header().dataWindow();
    const int width  = dw.max.x - dw.min.x + 1;
    const int height = dw.max.y - dw.min.y + 1;

    const off_t planeOffset = width * height;
    float * r = buffer;
    float * g = r + planeOffset;
    float * b = g + planeOffset;

    FrameBuffer framebuffer;

    // The "weird" strides are because Matlab uses column-major order
    const int xStride = height;
    const int yStride = 1;
    const off_t offset = - dw.min.x * xStride - dw.min.y * yStride;

    const ChannelList & channelList = file.header().channels();
    const char* channels[] = {"R", "G", "B"};
    float* data[] = {r, g, b};
    for (int i = 0; i < 3; ++i) {

        // Get the appropriate sampling factors
        int xSampling = 1, ySampling = 1;
        ChannelList::ConstIterator cIt = channelList.find(channels[i]);
        if (cIt != channelList.end()) {
            xSampling = cIt.channel().xSampling;
            ySampling = cIt.channel().ySampling;
        }

        // Insert the slice in the framebuffer
        framebuffer.insert(channels[i], Slice(FLOAT, (char*)(data[i] + offset),
            sizeof(float) * xStride,
            sizeof(float) * yStride,
            xSampling, ySampling));
    }

    // Finally read the pixels
    file.setFrameBuffer(framebuffer);
    file.readPixels(dw.min.y, dw.max.y);
}


// Main entry point. It returns an mxArray* with the appropriate RGB data
// loaded in the matlab way (column major, planar)
mxArray * readPixels(const char * filename)
{
    // Check if it is a YC file, so that we use the RGBA interface to decode it
    InputFile file(filename);
    const ChannelList & channels = file.header().channels();
    const bool isYC = channels.findChannel("Y")  != NULL || 
                      channels.findChannel("RY") != NULL || 
                      channels.findChannel("BY") != NULL;

    // Allocate the requied space
    const Box2i & dw = file.header().dataWindow();
    const mwSize width  = dw.max.x - dw.min.x + 1;
    const mwSize height = dw.max.y - dw.min.y + 1;
    const mwSize dims[] = {height, width, 3};
    mxArray * data = mxCreateNumericArray(3, &dims[0], mxSINGLE_CLASS, mxREAL);
    float * buffer = static_cast<float*> (mxGetData(data));

    if (!isYC) {
        readPixels(buffer, file);
    } else {
        OPENEXR_IMF_INTERNAL_NAMESPACE::RgbaInputFile ycFile(filename);
        readPixels(buffer, ycFile);
    }

    return data;
}

} // namespace


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{ 
    OpenEXRforMatlab::mexEXRInit();

    /* Check for proper number of arguments */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "The filename is required.");
    } else if (nlhs > 1) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Too many output arguments.");
    }

    char *inputfilePtr = mxArrayToString(prhs[0]);
    if (inputfilePtr == NULL) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Invalid filename argument.");
    }
    // Copy to a string so that the matlab memory may be freed asap
    const std::string inputfile(inputfilePtr);
    mxFree(inputfilePtr); inputfilePtr = static_cast<char*>(0);
    
    try {
        plhs[0] = readPixels(inputfile.c_str());        
    }
    catch(Iex::BaseExc &e) {
        mexErrMsgIdAndTxt("OpenEXR:exception", e.what());
    }
}
