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

#include "ImfToMatlab.h"

#include <half.h>
#include <ImfPixelType.h>
#include <ImfCompression.h>

#include <mex.h>

#include <string>
#include <vector>
#include <utility>
#include <cstring>
#include <cassert>

using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;

// Utilities to convert from Matlab types to OpenEXR types

namespace OpenEXRforMatlab
{

///////////////////////////////////////////////////////////////////////////////
// Utilities
///////////////////////////////////////////////////////////////////////////////

inline bool isMatrix(const mxArray * pa, mwSize & outM, mwSize & outN) {
    const mwSize numDim = mxGetNumberOfDimensions(pa);
    if (numDim != 2) {
        return false;
    }
    const mwSize * dim = mxGetDimensions(pa);
    outM = dim[0];
    outN = dim[1];
    return true;
}


inline bool isVector(const mxArray * pa, mwSize & outNumel) {
    mwSize M, N;
    if (!isMatrix(pa, M, N)) {
        return false;
    }
    if (M != 1 && N != 1) {
        return false;
    }
    outNumel = mxGetNumberOfElements(pa);
    assert(outNumel == M*N);
    return true;
}


inline bool isScalar(const mxArray * pa) {
    mwSize M, N;
    if (!isMatrix(pa, M, N)) {
        return false;
    }
    return (M == 1 && N == 1);
}



///////////////////////////////////////////////////////////////////////////////
// Conversion from Matlab to C++. Return true if the conversion is successful
///////////////////////////////////////////////////////////////////////////////

template <typename T>
inline bool toNative(const mxArray * pa, T & outValue)
{
    return false;
}


template <typename T>
inline void toNativeCheck(const mxArray * pa, T & outValue)
{
    if (!toNative(pa, outValue)) {
        mexErrMsgIdAndTxt("OpenEXR:IllegalConversion",
            "Illegal data conversion from Matlab to C++");
    }
}


template <>
inline bool toNative(const mxArray * pa, std::string & outValue)
{
    char * data = mxArrayToString(pa);
    if (data == NULL) {
        return false;
    }
    outValue = data;
    mxFree(data);
    return true;
}


template<>
inline bool toNative(const mxArray * pa, std::vector<std::string> & outVec)
{
    // Be tolerant and accept a single string
    if (mxIsChar(pa)) {
        std::string result;
        if (!toNative(pa, result)) {
            return false;
        }
        outVec.push_back(result);
        return true;
    }
    else if (!mxIsCell(pa)) {
        return false;
    }

    // Handle the cell array
    const mwSize numDim = mxGetNumberOfDimensions(pa);
    if (numDim != 2) {
        mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion", "Tensors not supported.");
        return false;
    }
    const mwSize * dim = mxGetDimensions(pa);
    if (dim[0] != 1 && dim[1] != 1) {
        mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion", "Not a cell vector.");
        return false;
    }

    const size_t numel = mxGetNumberOfElements(pa);
    for (mwIndex i = 0; i != numel; ++i) {
        std::string result;
        const mxArray * element = mxGetCell(pa, i);
        if (!toNative(element, result)) {
            return false;
        }
        outVec.push_back(result);
    }
    return true;
}


template<>
inline bool toNative(const mxArray * pa,
                     std::pair<const mxArray *, mxClassID> & pair)
{
    if (mxIsNumeric(pa)) {
        if (mxIsComplex(pa)) {
            mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion",
                "Complex data is not supported.");
            return false;
        }
        pair.first  = pa;
        pair.second = mxGetClassID(pa);
        return true;
    }
    else {
        mexWarnMsgIdAndTxt("OpenEXR:IllegalConversion",
            "Non numeric type: %s", mxGetClassName(pa));
        return false;
    }
}


// Converto to a pixel type from a Matlab String
template <>
inline bool toNative(const mxArray * pa, OPENEXR_IMF_INTERNAL_NAMESPACE::PixelType & outType)
{
    char * data = mxArrayToString(pa);
    if (data == NULL) {
        return false;
    }

    bool result = true;
    if (strcmp(data, "half") == 0) {
        outType = OPENEXR_IMF_INTERNAL_NAMESPACE::HALF;
    }
    else if (strcmp(data, "single") == 0 || strcmp(data, "float") == 0) {
        outType = OPENEXR_IMF_INTERNAL_NAMESPACE::FLOAT;
    }
    else {
        mexWarnMsgIdAndTxt("OpenEXR:argument",
            "Unrecognized pixel type: %s", data);
        result = false;
    }

    mxFree(data);
    return result;
}


template <>
inline bool toNative(const mxArray * pa, OPENEXR_IMF_INTERNAL_NAMESPACE::Compression & outCompression)
{
    char * data = mxArrayToString(pa);
    if (data == NULL) {
        return false;
    }

    bool result = true;
    if (strcmp(data, "none") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::NO_COMPRESSION;
    }
    else if (strcmp(data, "rle") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::RLE_COMPRESSION;
    }
    else if (strcmp(data, "zips") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::ZIPS_COMPRESSION;
    }
    else if (strcmp(data, "zip") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::ZIP_COMPRESSION;
    }
    else if (strcmp(data, "piz") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::PIZ_COMPRESSION;
    }
    else if (strcmp(data, "pxr24") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::PXR24_COMPRESSION;
    }
    else if (strcmp(data, "b44") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::B44_COMPRESSION;
    }
    else if (strcmp(data, "b44a") == 0) {
        outCompression = OPENEXR_IMF_INTERNAL_NAMESPACE::B44A_COMPRESSION;
    }
    else {
        mexWarnMsgIdAndTxt("OpenEXR:argument",
            "Unrecognized compression: %s", data);
        result = false;
    }

    mxFree(data);
    return result;
}



///////////////////////////////////////////////////////////////////////////////
// Bulk array conversion
///////////////////////////////////////////////////////////////////////////////

namespace convert_detail
{

// Helper struct to cast types
template <typename TargetType>
struct type_traits
{
    template <typename T>
    static TargetType cast (const T & n)
    {
        return static_cast<TargetType> (n);
    }
};

template <>
struct type_traits<half>
{
    template <typename T>
    static half cast (const T & n)
    {
        const float f = static_cast<float> (n);
        return static_cast<half> (f);
    }
};

} // namespace convert_detail


// Convert an array of the given numeric type into another preallocated array.
template <typename SourceType, typename TargetType>
inline void convertData(TargetType * dest, const mxArray * pa, const size_t len)
{
    assert(mxGetClassID(pa) == mex_traits<SourceType>::classID);
    const SourceType * src = static_cast<const SourceType *>(mxGetData(pa));
    for (size_t i = 0; i != len; ++i) {
        dest[i] = convert_detail::type_traits<TargetType>::cast (src[i]);
    }
}


// Convert from a Matlab numeric array into the given data format
template <typename TargetType>
inline void convertData(TargetType * dest,
                        const mxArray * pa, mxClassID srcType, const size_t len)
{
    assert(srcType == mxGetClassID(pa));

    switch(srcType) {
    case mxDOUBLE_CLASS:
        convertData<real64_T>(dest, pa, len);
        break;
    case mxSINGLE_CLASS:
        convertData<real32_T>(dest, pa, len);
        break;
    case mxINT8_CLASS:
        convertData<int8_T>(dest, pa, len);
        break;
    case mxUINT8_CLASS:
        convertData<uint8_T>(dest, pa, len);
        break;
    case mxINT16_CLASS:
        convertData<int16_T>(dest, pa, len);
        break;
    case mxUINT16_CLASS:
        convertData<uint16_T>(dest, pa, len);
        break;
    case mxINT32_CLASS:
        convertData<int32_T>(dest, pa, len);
        break;
    case mxUINT32_CLASS:
        convertData<uint32_T>(dest, pa, len);
        break;
    case mxINT64_CLASS:
        convertData<int64_T>(dest, pa, len);
        break;
    case mxUINT64_CLASS:
        convertData<uint64_T>(dest, pa, len);
        break;

    default:
        assert("Unsupported mxClassID" == 0);
        mexErrMsgIdAndTxt("OpenEXR:unsupported",
            "Unsupported mxClassID: %s", mxGetClassName(pa));
    }
}



// Convert the Matlab type to a known Imf::Attribute. Returns NULL if
// the conversion fails, most likely because the conversion is not
// implemented yet.
Attribute* toAttribute(const mxArray* pa);

} // namespace OpenEXRforMatlab