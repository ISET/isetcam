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
#include <ImfNamespace.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif

#include "utilities.h"
#include "ImfToMatlab.h"
#include "MatlabToImf.h"


namespace OpenEXRforMatlab
{

// Helper struct to hold Matlab pointers to matrices of the same size
struct MatricesVec
{
    mwSize M;
    mwSize N;
    std::vector<std::pair<const mxArray *, mxClassID> > data;
};

// To hold a vector of attributes
typedef std::pair<std::string, OPENEXR_IMF_INTERNAL_NAMESPACE::Attribute *> AttributePair;
typedef std::vector<AttributePair> AttributeVector;


template<>
bool toNative(const mxArray * pa, MatricesVec & outData)
{
    // If not a cell array, it might be a single matrix
    if (!mxIsCell(pa)) {
        std::pair<const mxArray *, mxClassID> pair;
        if (!toNative(pa, pair)) {
            return false;
        }
        mwSize M, N;
        if (!isMatrix(pair.first, M, N)) {
            return false;
        }
        outData.data.push_back(pair);
        outData.M = M;
        outData.N = N;
        return true;
    }

    mwSize numel = 0;
    if (!isVector(pa, numel)) {
        return false;
    } else if (numel == 0) {
        mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion", "Empty cell vector.");
        return false;
    }

    // Get the size from the first element
    {
        const mxArray * elem = mxGetCell(pa, 0);
        std::pair<const mxArray *, mxClassID> pair;
        if (!toNative(elem, pair)) {
            return false;
        }
        mwSize M, N;
        if (!isMatrix(pair.first, M, N)) {
            return false;
        }
        outData.data.push_back(pair);
        outData.M = M;
        outData.N = N;
    }

    // Iterate over the rest
    for (mwIndex i = 1; i != numel; ++i) {
        const mxArray * elem = mxGetCell(pa, i);
        std::pair<const mxArray *, mxClassID> currPair;
        if (!toNative(elem, currPair)) {
            return false;
        }
        mwSize currM, currN;
        if (!isMatrix(currPair.first, currM, currN)) {
            return false;
        }
        else if (currM != outData.M || currN != outData.N) {
            mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion",
                "Inconsistent matrix sizes.");
            return false;
        }
        outData.data.push_back(currPair);
    }

    return true;
}



// Convert from a containters.Map object into a set of attributes. The caller
// is responsible to delete the attribute pointers returned.
template <>
bool toNative(const mxArray * pa, AttributeVector &outAttributes)
{
    if (!mxIsClass(pa, "containers.Map")) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not a containers.Map object.");
    }

    // Extract the cell arrays with the names and values for the attributes
    mxArray * map = const_cast<mxArray *>(pa);
    mxArray * isempty    = NULL;
    mxArray * namesCell  = NULL;
    mxArray * valuesCell = NULL;
    if (mexCallMATLAB(1, &isempty, 1, &map, "isempty") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not query the map.");
    }
    else if (mxIsLogicalScalarTrue(isempty)) {
        mxDestroyArray (isempty);
        return true;
    }

    if (mexCallMATLAB(1, &namesCell, 1, &map, "keys") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not get the map keys.");
    }

    std::vector<std::string> names;
    if (!toNative(namesCell, names)) {
        mexWarnMsgIdAndTxt("OpenEXR:unsupported",
            "The attribute map contains non-string keys.");
        mxDestroyArray(namesCell);
        return false;
    } else {
        mxDestroyArray(namesCell);
        namesCell = NULL;
    }

    if (mexCallMATLAB(1, &valuesCell, 1, &map, "values") != 0) {
        mxDestroyArray(namesCell);
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not get the map values.");
    }

    assert(names.size() == mxGetNumberOfElements(valuesCell));
    for (size_t i = 0; i != names.size(); ++i) {
        OPENEXR_IMF_INTERNAL_NAMESPACE::Attribute* attr = toAttribute(mxGetCell(valuesCell, i));
        if (attr != NULL) {
            AttributePair pair(names[i], attr);
            outAttributes.push_back(pair);
        }
    }

    mxDestroyArray(valuesCell);
    return true;
}



// Convert from a containters.Map object. This is very memory intensive since
// it will create cell arrays using dynamic Matlab memory.
bool toNative(const mxArray * pa,
    std::vector<std::string> &outNames, MatricesVec & outData)
{
    if (!mxIsClass(pa, "containers.Map")) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not a containers.Map object.");
    }

    // Extract the cell arrays with the data and the channel names
    mxArray * map = const_cast<mxArray *>(pa);
    mxArray * isempty   = NULL;
    mxArray * namesCell = NULL;
    mxArray * dataCell  = NULL;
    if (mexCallMATLAB(1, &isempty, 1, &map, "isempty") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not query the map.");
    }
    else if (mxIsLogicalScalarTrue(isempty)) {
        mxDestroyArray (isempty);
        return true;
    }
    mxDestroyArray (isempty);


    if (mexCallMATLAB(1, &namesCell, 1, &map, "keys") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not get the map keys.");
    }
    if (mexCallMATLAB(1, &dataCell, 1, &map, "values") != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Could not get the map values.");
    }

    if (toNative(namesCell, outNames) && toNative(dataCell, outData)) {
        return true;
    } else {
        mxDestroyArray (namesCell);
        mxDestroyArray (dataCell);
        return false;
    }
}

} // namespace OpenEXRforMatlab




using namespace OpenEXRforMatlab;


namespace
{

// Class to be queried for actual data during the OpenEXR file creation
class WriteData {

public:
    WriteData(const std::string & filename,
         OPENEXR_IMF_INTERNAL_NAMESPACE::Compression compression, OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType targetPixelType,
         const AttributeVector & attributes,
         const std::vector<std::string> & channelNames,
         const MatricesVec channelData);

    ~WriteData();

    typedef std::pair<std::string, char *> DataPair;

    // Write the OpenEXR file. Note that this method may throw exceptions
    void writeEXR() const;

    inline size_t size() const {
        return m_channels.size();
    }

    inline size_t typeSize() const {
        switch(type()) {
        case OPENEXR_IMF_INTERNAL_NAMESPACE::HALF:
            return sizeof(half);
            break;
        case OPENEXR_IMF_INTERNAL_NAMESPACE::FLOAT:
            return sizeof(float);
            break;
        default:
            assert("Unknown type" == 0);
            return 0;
        }
    }

    inline size_t xStride() const {
        return m_height;
    }

    inline size_t yStride() const {
        return 1;
    }

    inline size_t width() const {
        return m_width;
    }

    inline size_t height() const {
        return m_height;
    }

    inline const std::string & filename() const {
        return m_filename;
    }

    inline OPENEXR_IMF_INTERNAL_NAMESPACE::Compression compression() const {
        return m_compression;
    }

    inline OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType type() const {
        return m_type;
    }


private:

    // Helper function to create local copies of the data if necessary
    template <typename TargetType>
    char* prepareChannel(const std::pair<const mxArray *, mxClassID> & pair);

    inline const std::string & channelName (size_t index) const {
        return m_channels[index].first;
    }

    inline char * channelData (size_t index) const {
        return m_channels[index].second;
    }

    
    const std::string m_filename;
    const OPENEXR_IMF_INTERNAL_NAMESPACE::Compression m_compression;
    const OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType m_type;
    const size_t m_width;
    const size_t m_height;

    // Attributes of which we take ownership
    AttributeVector m_attributes;
    
    // Pairs of channels and a pointer to the data
    std::vector<DataPair> m_channels;

    // Data created through mxMalloc
    std::vector<void*> m_allocated;
};


WriteData::WriteData(const std::string & filename,
                    OPENEXR_IMF_INTERNAL_NAMESPACE::Compression compression,
                    OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType targetPixelType,
                    const AttributeVector & attributes,
                    const std::vector<std::string> & channelNames,
                    const MatricesVec channelData) :
m_filename(filename), m_compression(compression), m_type(targetPixelType),
m_width(channelData.N), m_height(channelData.M),
m_attributes(attributes)
{
    assert(!channelNames.empty());
    assert(channelNames.size() == channelData.data.size());

    for (size_t i = 0; i < channelNames.size(); ++i) {
        char * data;
        switch (type()) {
        case OPENEXR_IMF_INTERNAL_NAMESPACE::FLOAT:
            data = prepareChannel<float>(channelData.data[i]);
            break;
        case OPENEXR_IMF_INTERNAL_NAMESPACE::HALF:
            data = prepareChannel<half>(channelData.data[i]);
            break;
        default:
            assert("Unsupported Pixel Type" == 0);
            mexErrMsgIdAndTxt("OpenEXR:unsupported",
                "Unsupported pixel type: %d", static_cast<int>(type()));
            data = NULL; // Keep compiler happy

        }

        DataPair pair(channelNames[i], data);
        m_channels.push_back(pair);
    }
}


template <typename TargetType>
char * WriteData::prepareChannel(const std::pair<const mxArray *,
                                 mxClassID> & pair)
{
    const mxArray* pa       = pair.first;
    const mxClassID srcType = pair.second;

    if (srcType == OpenEXRforMatlab::mex_traits<TargetType>::classID) {
        // If the type is compatible, just return a pointer to the Matlab data
        return static_cast<char*>(mxGetData(pa));
    }
    else {
        // Allocate enough space and convert in place
        const size_t numPixels = width() * height();
        void * rawData = mxMalloc(sizeof(TargetType) * numPixels);
        m_allocated.push_back(rawData);
        TargetType * dest = static_cast<TargetType*> (rawData);
        convertData(dest, pa, srcType, numPixels);
        return reinterpret_cast<char*>(dest);
    }
}


WriteData::~WriteData()
{
    for (size_t i = 0; i != m_allocated.size(); ++i) {
        mxFree(m_allocated[i]);
    }

    for (size_t i = 0; i != m_attributes.size(); ++i) {
        if (m_attributes[i].second != NULL) {
            delete m_attributes[i].second;
        }
    }
}


void WriteData::writeEXR() const
{
    using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
    using namespace Imath;

    Header header(static_cast<int>(width()), static_cast<int>(height()),
        1.0f,            // aspect ratio
        V2f(0.0f, 0.0f), // screen window center,
        1.0f,            // screen window width,
        INCREASING_Y,    // line order
        compression());

    // Add the attributes
    for (AttributeVector::const_iterator it = m_attributes.begin();
        it != m_attributes.end(); ++it)
    {
        header.insert(it->first.c_str(), *(it->second));
    }

    // Insert channels in the header
    for (size_t i = 0; i != size(); ++i) {
        header.channels().insert(channelName(i).c_str(), Channel(type()));
    }

    OutputFile file(filename().c_str(), header);

    // Create and populate the frame buffer
    FrameBuffer frameBuffer;
    for (size_t i = 0; i != size(); ++i) {
        frameBuffer.insert(channelName(i).c_str(),  // name
            Slice(type(),                           // type
                  channelData(i),                   // base
                  typeSize() * xStride(),           // xStride
                  typeSize() * yStride()));         // yStride
    }

    file.setFrameBuffer(frameBuffer);
    file.writePixels(static_cast<int>(height()));
}



// Unify the different ways to call the function
WriteData * prepareArguments(const int nrhs, const mxArray * prhs[])
{
    int currArg = 0;

    std::string filename;
    OPENEXR_IMF_INTERNAL_NAMESPACE::Compression compression = OPENEXR_IMF_INTERNAL_NAMESPACE::ZIP_COMPRESSION;
    OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType pixelType = OPENEXR_IMF_INTERNAL_NAMESPACE::HALF;
    
    const mxArray * attribs = NULL;
    AttributeVector attributesVector;
    std::vector<std::string> channelNames;
    MatricesVec channelData;


    /////////// Filename, compression and pixel type //////////////////////////
    
    if (currArg >= nrhs) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not enough arguments.");
    }
    else if (!mxIsChar(prhs[currArg])) {
        mexErrMsgIdAndTxt("OpenEXR:argument",
            "Argument %d is not a string.", currArg + 1);
    }
    else {
        toNativeCheck(prhs[currArg], filename);
        ++currArg;
    }

    if (currArg >= nrhs) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not enough arguments.");
    }
    else if (mxIsChar(prhs[currArg])) {
        toNativeCheck(prhs[currArg], compression);
        ++currArg;

        if (currArg < nrhs && mxIsChar(prhs[currArg])) {
            toNativeCheck(prhs[currArg], pixelType);
            ++currArg;
        }
    }


    ////////////////////// Optional arguments map ////////////////////////////////

    enum DataType { UNKNOWN, MAP, NAMES_DATA };
    DataType dType = UNKNOWN;

    if (currArg >= nrhs) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not enough arguments.");
    }
    if ((nrhs - currArg) == 3) {
        if (mxIsClass(prhs[currArg], "containers.Map")) {
            attribs = prhs[currArg];
            ++currArg;
            dType = NAMES_DATA;
        }
        else {
            mexErrMsgIdAndTxt("OpenEXR:argument",
                "Expected a containers.Map handle as argument %d.", currArg);
        }
    }
    else if ((nrhs - currArg) == 2) {
        if (mxIsClass(prhs[currArg], "containers.Map")) {
            attribs = prhs[currArg];
            ++currArg;
            dType = MAP;
        }
        else {
            dType = NAMES_DATA;
        }
    }
    else if ((nrhs - currArg) == 1) {
        dType = MAP;
    }
    else {
        mexErrMsgIdAndTxt("OpenEXR:argument", "%s arguments.",
            (nrhs - currArg) > 3 ? "Too many" : "Not enough");
    }
    assert(dType != UNKNOWN);


    /////////////////////////// Channel data /////////////////////////////////////

    switch(dType) {
    case MAP:
        assert(currArg == nrhs - 1);
        if (!mxIsClass(prhs[currArg], "containers.Map")) {
            mexErrMsgIdAndTxt("OpenEXR:argument",
                "Expected a containers.Map handle as last argument.");
        }
        if (!toNative(prhs[currArg], channelNames, channelData)) {
            mexErrMsgIdAndTxt("OpenEXR:argument",
                "Could not convert the channels map at argument %d.", currArg);
        }

        break;
    case NAMES_DATA:
        assert(currArg == nrhs - 2);
        if (mxIsChar(prhs[currArg])) {
            // Single channel mode
            toNativeCheck(prhs[currArg],   channelNames);
            toNativeCheck(prhs[currArg+1], channelData);
        }
        else if (mxIsCell(prhs[currArg])) {
            // Multiple channel mode
            if (!mxIsCell(prhs[currArg+1])) {
                mexErrMsgIdAndTxt("OpenEXR:argument",
                    "Expected a cell vector of real matrices as last argument.");
            }
            toNativeCheck(prhs[currArg],   channelNames);
            toNativeCheck(prhs[currArg+1], channelData);
        }
        else {
            mexErrMsgIdAndTxt("OpenEXR:argument",
                "Expected a string or cell vector of strings as second to last argument.");
        }
        break;
    default:
        mexErrMsgIdAndTxt("OpenEXR:IllegalState", "Unknown channel data format");
    }

    if (channelNames.empty()) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Empty list of channel names.");
    }
    if (channelData.data.empty()) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Empty list of channel data.");
    }
    if (channelData.M < 1 || channelData.N < 1) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Invalid data size: [%d %d].",
            static_cast<int>(channelData.M), static_cast<int>(channelData.N));
    }
    if (channelNames.size() != channelData.data.size()) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Missmatch between number of "
            "provided channel names and channel data matrices.");
    }

    if (attribs != NULL) {
        // Delay the conversion until here to avoid memory leaks: the generated
        // attributes will get deleted only by the WriteData destructor
        if (!toNative(attribs, attributesVector)) {
            mexWarnMsgIdAndTxt("OpenEXR:unsupported",
                "Attribute generation failed.");
        }
    }

    // B44[a] only compresses half channels
    if (pixelType != OPENEXR_IMF_INTERNAL_NAMESPACE::HALF && (compression == OPENEXR_IMF_INTERNAL_NAMESPACE::B44_COMPRESSION ||
                                   compression == OPENEXR_IMF_INTERNAL_NAMESPACE::B44A_COMPRESSION))
    {
        mexWarnMsgIdAndTxt("OpenEXR:compression",
            "B44[A] format stores uncompressed data when the pixel type is not HALF.");
    }


    WriteData * writeData = new WriteData(filename, compression, pixelType,
        attributesVector, channelNames, channelData);
    return writeData;
}

} // namespace



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    OpenEXRforMatlab::mexEXRInit();

    // Check for proper number of arguments
    if (nrhs < 2) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Not enough arguments.");
    } else if (nlhs != 0) {
        mexErrMsgIdAndTxt("OpenEXR:argument", "Too many output arguments.");
    }

    try {
        std::auto_ptr<WriteData> data(prepareArguments(nrhs, prhs));
        data->writeEXR();
    }
    catch (Iex::BaseExc & e) {
        mexErrMsgIdAndTxt("OpenEXR:exception", e.what());
    }
}
