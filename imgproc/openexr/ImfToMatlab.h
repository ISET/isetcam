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

#include <mex.h>

#include <ImfNamespace.h>
#include <ImfAttribute.h>


// Utilities to convert from OpenEXR types to Matlab types

namespace OpenEXRforMatlab
{
///////////////////////////////////////////////////////////////////////////////
// Traits for matlab types
///////////////////////////////////////////////////////////////////////////////
template<typename T>
struct mex_traits
{
	static const mxClassID classID = mxUNKNOWN_CLASS;
};

template<>
struct mex_traits<double>
{
	static const mxClassID classID = mxDOUBLE_CLASS;
};

template<>
struct mex_traits<float>
{
	static const mxClassID classID = mxSINGLE_CLASS;
};

template<>
struct mex_traits<int8_T>
{
	static const mxClassID classID = mxINT8_CLASS;
};

template<>
struct mex_traits<uint8_T>
{
	static const mxClassID classID = mxUINT8_CLASS;
};

template<>
struct mex_traits<int16_T>
{
	static const mxClassID classID = mxINT16_CLASS;
};

template<>
struct mex_traits<uint16_T>
{
	static const mxClassID classID = mxUINT16_CLASS;
};

template<>
struct mex_traits<int32_T>
{
	static const mxClassID classID = mxINT32_CLASS;
};

template<>
struct mex_traits<uint32_T>
{
	static const mxClassID classID = mxUINT32_CLASS;
};

template<>
struct mex_traits<int64_T>
{
	static const mxClassID classID = mxINT64_CLASS;
};

template<>
struct mex_traits<uint64_T>
{
	static const mxClassID classID = mxUINT64_CLASS;
};

template<>
struct mex_traits<bool>
{
	static const mxClassID classID = mxLOGICAL_CLASS;
	mxLogical x;
};



///////////////////////////////////////////////////////////////////////////////
// Conversion from C++ types to Matlab versions
///////////////////////////////////////////////////////////////////////////////

template<typename T>
inline mxArray * fromScalar(T n)
{
	mxArray *arr = mxCreateNumericMatrix(1, 1, mex_traits<T>::classID, mxREAL);
	T * ptr = reinterpret_cast<T*>(mxGetPr(arr));
	*ptr = n;
	return arr;
}


template<typename T, size_t N>
inline mxArray * fromArray(const T (&arr)[N])
{
	mxArray *mArr = mxCreateNumericMatrix(1, N, mex_traits<T>::classID, mxREAL);
	T * ptr = reinterpret_cast<T*>(mxGetPr(mArr));
	for (size_t i = 0; i != N; ++i) {
		ptr[i] = arr[i];
	}
	return mArr;
}


// Convert the value of an attribute to a Matlab type. Returns NULL if
// the conversion fails, most likely because the conversion is not
// implemented yet.
mxArray* toMatlab(const OPENEXR_IMF_INTERNAL_NAMESPACE::Attribute & attr);


} // namespace OpenEXRforMatlab