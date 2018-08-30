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
#include <vector>
#include <cassert>

#include <mex.h>
#include <matrix.h>

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include <ImfHeader.h>
#include <ImfChannelList.h>
#include <ImfAttribute.h>
#include <ImfInputFile.h>
#include <ImfNamespace.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "ImfToMatlab.h"


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using namespace Imath;
using namespace OpenEXRforMatlab;


namespace {

// Temporaty struct to hold a name and a matlab value
struct Pair
{
    const char * name;
    mxArray * value;

    Pair() : name(NULL), value(NULL) {}

    Pair(const char * pName, mxArray * pValue = NULL) :
    name(pName), value(pValue)
    {}

    bool isValid() const {
        return name != NULL && value != NULL;
    }
};


// Create a cell array with only the name of the channels
mxArray * getChannelNames(const ChannelList & channels)
{
    typedef ChannelList::ConstIterator ChannelIterator;

    std::vector<mxArray *> channelNames;
    for (ChannelIterator it = channels.begin(); it != channels.end(); ++it)
    {
        mxArray * mStr = mxCreateString(it.name());
        channelNames.push_back(mStr);
    }
    assert(!channelNames.empty());

    mxArray * cells = mxCreateCellMatrix(1, channelNames.size());
    for (size_t i = 0; i != channelNames.size(); ++i) {
        mxSetCell(cells, i, channelNames[i]);
    }
    return cells;
}


// Create and populate a containters.Map object with the attributes
mxArray * getAttributesMap(const Header& header)
{
    std::vector<Pair> attributes;

    // Get the full set of attributes
    for (Header::ConstIterator it = header.begin(); it != header.end(); ++it) {
        const Attribute& attr = it.attribute();
        if (!Attribute::knownType(attr.typeName())) {
            continue;
        }

        Pair pair(it.name());
        pair.value = toMatlab(attr);
        if (pair.isValid()) {
            attributes.push_back(pair);
        }
    }
    assert(!attributes.empty());

    // Create cell arrays with the attributes' names and values
    mxArray * nameCell  = mxCreateCellMatrix(1, attributes.size());
    mxArray * valueCell = mxCreateCellMatrix(1, attributes.size());
    for (size_t i = 0; i != attributes.size(); ++i) {
        mxSetCell(nameCell,  i, mxCreateString(attributes[i].name));
        mxSetCell(valueCell, i, attributes[i].value);
    }

    // Create the attributes map
    mxArray* mapHandle = NULL;
    mxArray* mapArgs[2] = {nameCell, valueCell};
    if (mexCallMATLAB(1, &mapHandle, 2, &mapArgs[0], "containers.Map") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:exception",
            "Could not create the attribute map.");
        return NULL;
    }

    return mapHandle;
}


} // namespace


void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{ 
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
        // Open a file, but only read the header
        InputFile image(inputfile.c_str());
        const Header& header = image.header();

        const Box2i& dw = header.dataWindow();
        const int width  = dw.max.x - dw.min.x + 1;
        const int height = dw.max.y - dw.min.y + 1;

        // List of channel names
        mxArray* channelNames = getChannelNames(header.channels());

        // Attributes map
        mxArray* attributesMap = getAttributesMap(header);

        // Size in matlab style (rows by columns)
        const int dataSize[] = {height, width};
        mxArray* size = fromArray(dataSize);

        // Build the structure
        const char* fields[] = {"channels", "size", "attributes"};
        mxArray* bStruct = mxCreateStructMatrix(1, 1,
            sizeof(fields)/sizeof(const char*), &fields[0]);
        mxSetField(bStruct, 0, "channels",   channelNames);
        mxSetField(bStruct, 0, "size",       size);
        mxSetField(bStruct, 0, "attributes", attributesMap);
        
        // Assign the result
        plhs[0] = bStruct;
    }
    catch( std::exception& e ) {
        mexErrMsgIdAndTxt("OpenEXR:exception", e.what());
    }
}