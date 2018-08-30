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
#include <cassert>
#include <vector>

#include <mex.h>

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include <ImfInputFile.h>
#include <ImfChannelList.h>
#include <ImfNamespace.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "utilities.h"


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using Imath::Box2i;


namespace {

// Get the strings of the explicitly requested channel names.
// The first two arguments are the original inputs to mexFunction(...)
void getRequestedChannels(int nrhs, const mxArray *prhs[],
    std::vector<std::string> & outChannels)
{
    std::vector<const mxArray *> mxChannels;
    if (nrhs == 2) {
        // The second argument must be a cell array with strings or a string
        if (mxIsCell(prhs[1])) {
            // All the elements of the cell array must be strings
            const mxArray * cellArr = prhs[1];
            const mwSize nDim = mxGetNumberOfDimensions(cellArr);
            if (nDim != 2) {
                mexErrMsgIdAndTxt("OpenEXR:argument",
                    "Invalid cell array dimensions: %d", static_cast<int>(nDim));
            }
            const mwSize * dims = mxGetDimensions(cellArr);
            if (dims[0] != 1 && dims[1] != 1) {
                mexErrMsgIdAndTxt("OpenEXR:argument", "Not a cell vector.");
            }
            const mwSize numel = mxGetNumberOfElements(cellArr);
            for (mwSize i = 0; i != numel; ++i) {
                const mxArray * cVal = mxGetCell(cellArr, i);
                if (!mxIsChar(cVal)) {
                    mexErrMsgIdAndTxt("OpenEXR:argument",
                        "Cell vector contains non-string data.");
                }
                mxChannels.push_back(cVal);
            }
        }
        else if (mxIsChar(prhs[1])) {
            mxChannels.push_back(prhs[1]);
        } else {
            mexErrMsgIdAndTxt("OpenEXR:argument",
                "The second input argument is neither a cell array nor a string.");
        }
    } else if (nrhs > 2) {
        // All the arguments must be strings
        for (int i = 1; i < nrhs; ++i) {
            if (!mxIsChar(prhs[i])) {
                const int index = i+1;
                const char * suffix = index == 2 ? "nd" : (index == 3 ? "rd" : "th");
                mexErrMsgIdAndTxt("OpenEXR:argument", "The %d-%s argument is not a string",
                    index, suffix);
            }
            mxChannels.push_back(prhs[i]);
        }
    }

    // Now convert the mxArray* strings into std::string's
    typedef std::vector<const mxArray *>::const_iterator mxArrayIter;
    for(mxArrayIter it = mxChannels.begin(); it != mxChannels.end(); ++it) {
        char * str = mxArrayToString(*it);
        outChannels.push_back(std::string(str));
        mxFree(str);
    }
}



// Prepares a framebuffer for the requested channels, allocating also the
// appropriate Matlab memory
void prepareFrameBuffer(FrameBuffer & fb, const Box2i & dataWindow,
    const ChannelList & channels,
    const std::vector<std::string> & requestedChannels,
    std::vector<mxArray *> & outMatlabData)
{
    assert(!requestedChannels.empty());
    assert(outMatlabData.size() == requestedChannels.size());

    const Box2i & dw = dataWindow;
    const int width  = dw.max.x - dw.min.x + 1;
    const int height = dw.max.y - dw.min.y + 1;

    // The "weird" strides are because Matlab uses column-major order
    const int xStride = height;
    const int yStride = 1;

    // Offset for all the slices
    const off_t offset = - (dw.min.x * xStride + dw.min.y * yStride);

    for (size_t i = 0; i != requestedChannels.size(); ++i) {
        // Allocate the memory
        mxArray * data = 
            mxCreateNumericMatrix(height, width, mxSINGLE_CLASS, mxREAL);
        outMatlabData[i] = data;

        float * ptr = static_cast<float*>(mxGetData(data));

        // Get the appropriate sampling factors
        int xSampling = 1, ySampling = 1;
        ChannelList::ConstIterator cIt = channels.find(requestedChannels[i].c_str());
        if (cIt != channels.end()) {
            xSampling = cIt.channel().xSampling;
            ySampling = cIt.channel().ySampling;
        }
        
        // Insert the slice in the framebuffer
        fb.insert(requestedChannels[i].c_str(), Slice(FLOAT, (char*)(ptr + offset),
            sizeof(float) * xStride,
            sizeof(float) * yStride,
            xSampling, ySampling));
    }
}


// Utility to fill the given array with the names of all the channels
inline void getChannelNames(const ChannelList & channels,
    std::vector<std::string> & result)
{
    typedef ChannelList::ConstIterator CIter;

    for (CIter it = channels.begin(); it != channels.end(); ++it) {
        result.push_back(std::string(it.name()));
    }
}


// Create a containers.Map object with the channel names and value
 mxArray * buildMap(const std::vector<std::string> &channelNames,
     const std::vector<mxArray *> & mxData)
 {
     assert(channelNames.size() == mxData.size());
     assert(!channelNames.empty());
     const size_t numel = channelNames.size();

     // Create cell arrays with the channels' names and data
    mxArray * nameCell  = mxCreateCellMatrix(1, numel);
    mxArray * dataCell  = mxCreateCellMatrix(1, numel);
    for (size_t i = 0; i != numel; ++i) {
        mxSetCell(nameCell, i, mxCreateString(channelNames[i].c_str()));
        mxSetCell(dataCell, i, mxData[i]);
    }

    // Create the channels map
    mxArray * mapHandle = NULL;
    mxArray * mapArgs[2] = {nameCell, dataCell};
    if (mexCallMATLAB(1, &mapHandle, 2, &mapArgs[0], "containers.Map") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:exception",
            "Could not create the attribute map.");
    }

     return mapHandle;
 }


} // namespace



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{ 
	OpenEXRforMatlab::mexEXRInit();

    /* Check for proper number of arguments */
    if (nrhs < 1) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Too few arguments.");
    }

    char *inputfilePtr = mxArrayToString(prhs[0]);
    if (inputfilePtr == NULL) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Invalid filename argument.");
    }
    // Copy to a string so that the matlab memory may be freed asap
    const std::string inputfile(inputfilePtr);
    mxFree(inputfilePtr); inputfilePtr = static_cast<char*>(0);

    // Get the strings of explicitly requested channels channels
    std::vector<std::string> channelNames;
    getRequestedChannels(nrhs, prhs, channelNames);

    // Validate the output arguments
    if (nlhs > 1 && nlhs != static_cast<int>(channelNames.size())) {
        mexErrMsgIdAndTxt("OpenEXR:argument",
            "Invalid number of output arguments.");
    }
    

    try {
        InputFile img(inputfile.c_str());

        if (!channelNames.empty()) {
            // Validate that the channels are actually on the file
            const ChannelList & channels = img.header().channels();
            for (size_t i = 0; i != channelNames.size(); ++i) {
                if (channels.find(channelNames[i].c_str()) == channels.end()) {
                    mexErrMsgIdAndTxt("OpenEXR:argument",
                        "Channel not in file: %s", channelNames[i].c_str());
                }
            }
        } else {
            // If there are no explicitly required channels, read all
            getChannelNames(img.header().channels(), channelNames);
        }
        assert(!channelNames.empty());

        // Prepare the framebuffer
        const Box2i & dw = img.header().dataWindow();
        const ChannelList & imgChannels = img.header().channels();
        std::vector<mxArray *> mxData(channelNames.size());
        FrameBuffer framebuffer;
        prepareFrameBuffer(framebuffer, dw, imgChannels, channelNames, mxData);

        // Actually read the pixels
        img.setFrameBuffer(framebuffer);
        img.readPixels(dw.min.y, dw.max.y);

        // Assemble the result
        if (nlhs <= 1) {
            // Return a map if there are multiple channels, otherwise the data
            if (channelNames.size() != 1) {
                mxArray * resultMap = buildMap(channelNames, mxData);
                plhs[0] = resultMap;
            } else {
                plhs[0] = mxData[0];
            }
        }
        else {
            // Multiple output arguments, assign the data directly
            assert(nlhs == channelNames.size());
            for (int i = 0; i < nlhs; ++i) {
                plhs[i] = mxData[i];
            }
        }
    }
    catch( Iex::BaseExc &e ) {
        mexErrMsgIdAndTxt("OpenEXR:exception", e.what());
    }
}
