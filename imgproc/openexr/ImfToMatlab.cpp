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


#include <cassert>

#include <mex.h>
#include <matrix.h>

#ifdef __clang__
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wlong-long"
  #pragma clang diagnostic ignored "-Wdeprecated-register"
  #pragma clang diagnostic ignored "-Wextra"
#endif

#include "ImfToMatlab.h"
#include <ImfAttribute.h>
#include <ImfBoxAttribute.h>
#include <ImfChannelListAttribute.h>
#include <ImfChromaticitiesAttribute.h>
#include <ImfCompressionAttribute.h>
#include <ImfDoubleAttribute.h>
#include <ImfEnvmapAttribute.h>
#include <ImfFloatAttribute.h>
#include <ImfIntAttribute.h>
#include <ImfKeyCodeAttribute.h>
#include <ImfLineOrderAttribute.h>
#include <ImfMatrixAttribute.h>
#include <ImfOpaqueAttribute.h>
#include <ImfPreviewImageAttribute.h>
#include <ImfRationalAttribute.h>
#include <ImfStringAttribute.h>
#include <ImfTileDescriptionAttribute.h>
#include <ImfTimeCodeAttribute.h>
#include <ImfVecAttribute.h>
#include <ImfStringVectorAttribute.h>
#include <ImfNamespace.h>

#ifdef __clang__
  #pragma clang diagnostic pop
#endif


using namespace OPENEXR_IMF_INTERNAL_NAMESPACE;
using namespace Imath;


namespace 
{
using namespace OpenEXRforMatlab;


// Utility to know if a cast will work
template<typename T>
inline bool canCastTo (const Attribute &a) {
	return dynamic_cast<const T*>(&a) != NULL;
}

// Utility to get the value of a typed attribute. It assumes
// that canCastTo<T> returns true!
template<typename T>
inline const T& getValue(const Attribute &a) {
	assert(canCastTo<TypedAttribute<T> >(a));
	return dynamic_cast<const TypedAttribute<T> *>(&a)->value();
}



///////////////////////////////////////////////////////////////////////////////
// Conversion from Imf enums to a string
///////////////////////////////////////////////////////////////////////////////

inline const char* getCompressionName(Compression c)
{
	switch(c) {
	case NO_COMPRESSION:
		return "none";
	case RLE_COMPRESSION:
		return "rle";
	case ZIPS_COMPRESSION:
		return "zips";
	case ZIP_COMPRESSION:
		return "zip";
	case PIZ_COMPRESSION:
		return "piz";
	case PXR24_COMPRESSION:
		return "pxr24";
	case B44_COMPRESSION:
		return "b44";
	case B44A_COMPRESSION:
		return "b44a";
	default:
		return "unknown";
	}
}


inline const char * getLineOrderName(LineOrder ord)
{
	switch(ord) {
	case INCREASING_Y:
		return "increasing_y";
	case DECREASING_Y:
		return "decreasing_y";
	case RANDOM_Y:
		return "random";
	default:
		return "unknown";
	}
}


inline const char * getPixelTypeName(PixelType p)
{
	switch(p) {
	case UINT:
		return "uint32";
	case HALF:
		return "half";
	case FLOAT:
		return "single";
	default:
		return "unknown";
	}
}



///////////////////////////////////////////////////////////////////////////////
// Conversion from C++ types to Matlab versions
///////////////////////////////////////////////////////////////////////////////


// Represent rationals as a struct with 'numerator' and 'denominator' fields
inline mxArray * fromRational(const Rational & value)
{
	mxArray *n = fromScalar(value.n);
	mxArray *d = fromScalar(value.d);
	const char* fields[2] = {"numerator", "denominator"};
	mxArray *bStruct = mxCreateStructMatrix(1, 1, 2, &fields[0]);
	mxSetField(bStruct, 0, "numerator",   n);
	mxSetField(bStruct, 0, "denominator", d);
	return bStruct;
}


template<typename T, template <typename> class VecType>
inline mxArray * fromVector(const VecType<T> & vec)
{
	const int ndim = VecType<T>::dimensions();
	mxArray *mArr = mxCreateNumericMatrix(1, ndim, mex_traits<T>::classID, mxREAL);
	T * ptr = static_cast<T*>(mxGetData(mArr));
	for (int i = 0; i != ndim; ++i) {
		ptr[i] = vec[i];
	}
	return mArr;
}


// Represent boxes as a struct with 'min' and 'max' attributes
template<typename T, template <typename> class VecType>
inline mxArray * fromBox(const Box<VecType<T> > & box)
{
	mxArray *minArr = fromVector(box.min);
	mxArray *maxArr = fromVector(box.max);
	const char* fields[2] = {"min", "max"};
	mxArray *bStruct = mxCreateStructMatrix(1, 1, 2, &fields[0]);
	mxSetField(bStruct, 0, "min", minArr);
	mxSetField(bStruct, 0, "max", maxArr);
	return bStruct;
}


template<int ndim, typename T, template <typename> class MatrixType>
inline mxArray * fromMatrix(const MatrixType<T> &m)
{
	// Imath has only square, 3x3 or 4x4 matrices
	mxArray *mArr = mxCreateNumericMatrix(ndim, ndim, mex_traits<T>::classID, mxREAL);
	T * ptr = static_cast<T*>(mxGetData(mArr));
	// Matlab uses column-major matrices
	for (int j = 0; j < ndim; ++j) {
		for (int i = 0; i < ndim; ++i) {
			*ptr++ = m[i][j];
		}
	}
	return mArr;
}


inline mxArray * fromStringVector(const StringVector & vec)
{
	assert(!vec.empty());
	mxArray * cells = mxCreateCellMatrix(1, vec.size());
	for (size_t i = 0; i != vec.size(); ++i) {
		mxSetCell(cells, i, mxCreateString(vec[i].c_str()));
	}
	return cells;
}


// Represent channels as structs with each member
inline mxArray * fromChannelList(const ChannelList & channelList)
{
	typedef ChannelList::ConstIterator CIter;
	
	// Find out the number of channels
	int nChannels = 0;
	for (CIter it = channelList.begin(); it != channelList.end(); ++it) {
		++nChannels;
	}
	assert(nChannels > 0);

	const char* fields[] =
		{"name", "type", "perceptionlinear", "xsampling", "ysampling"};
	const size_t nFields = sizeof(fields)/sizeof(const char *);
	mxArray *cStruct = mxCreateStructMatrix(1, nChannels, nFields, &fields[0]);

	int channelIdx = 0;
	for (CIter it = channelList.begin(); it != channelList.end(); ++it) {
		mxArray * name = mxCreateString(it.name());
		mxArray * type = mxCreateString(getPixelTypeName(it.channel().type));
		mxArray * pLinear = fromScalar(it.channel().pLinear);
		mxArray * xs   = fromScalar(it.channel().xSampling);
		mxArray * ys   = fromScalar(it.channel().ySampling);

		mxSetField(cStruct, channelIdx, "name",             name);
		mxSetField(cStruct, channelIdx, "type",             type);
		mxSetField(cStruct, channelIdx, "perceptionlinear", pLinear);
		mxSetField(cStruct, channelIdx, "xsampling",        xs);
		mxSetField(cStruct, channelIdx, "ysampling",        ys);

		++channelIdx;
	}
	assert(channelIdx == nChannels);

	return cStruct;
}

} // namespace



mxArray* OpenEXRforMatlab::toMatlab(const OPENEXR_IMF_INTERNAL_NAMESPACE::Attribute& attr)
{
	// Use the same order as Header.cpp in IlmIfm so that we can compare them

	// Boxes
	if (canCastTo<Box2fAttribute>(attr)) {
		return fromBox(getValue<Box2f>(attr));
	} else if (canCastTo<Box2iAttribute>(attr)) {
		return fromBox(getValue<Box2i>(attr));
	}

	// Channel list
	else if (canCastTo<ChannelListAttribute>(attr)) {
		return fromChannelList(getValue<ChannelList>(attr));
	}

	// Compression enum
	else if (canCastTo<CompressionAttribute>(attr)) {
		const char * name = getCompressionName(getValue<Compression>(attr));
		return mxCreateString(name);
	}

	// Chromaticities
	else if (canCastTo<ChromaticitiesAttribute>(attr)) {
		// TODO Support chromaticities
	}

	// Primitive types
	else if (canCastTo<IntAttribute>(attr)) {
		return fromScalar(getValue<int>(attr));
	} else if (canCastTo<FloatAttribute>(attr)) {
		return fromScalar(getValue<float>(attr));
	} else if (canCastTo<DoubleAttribute>(attr)) {
		return fromScalar(getValue<double>(attr));
	}

	// Environment Map
	else if (canCastTo<EnvmapAttribute>(attr)) {
		// TODO Support EnvmapAttribute
	}
	// Key code
	else if (canCastTo<KeyCodeAttribute>(attr)) {
		// TODO Support KeyCodeAttribute
	}
	// Line order enum
	else if (canCastTo<LineOrderAttribute>(attr)) {
		const char * name = getLineOrderName(getValue<LineOrder>(attr));
		return mxCreateString(name);
	}

	// Matrices
	else if (canCastTo<M33fAttribute>(attr)) {
		return fromMatrix<3>(getValue<M33f>(attr));
	} else if (canCastTo<M44fAttribute>(attr)) {
		return fromMatrix<4>(getValue<M44f>(attr));
	}
	else if (canCastTo<M33dAttribute>(attr)) {
		return fromMatrix<3>(getValue<M33d>(attr));
	} else if (canCastTo<M44dAttribute>(attr)) {
		return fromMatrix<4>(getValue<M44d>(attr));
	}

	// Preview Image
	else if (canCastTo<PreviewImageAttribute>(attr)) {
		// TODO Suppport PreviewImageAttribute
	} 
	// Rational number
	else if (canCastTo<RationalAttribute>(attr)) {
		return fromRational(getValue<Rational>(attr));
	}
	// Strings
	else if (canCastTo<StringAttribute>(attr)) {
		const std::string & value = getValue<std::string>(attr);
		return mxCreateString(value.c_str());
	}
	else if (canCastTo<StringVectorAttribute>(attr)) {
		return fromStringVector(getValue<StringVector>(attr));
	}
	// Tile description
	else if (canCastTo<TileDescriptionAttribute>(attr)) {
		// TODO Support TileDescriptionAttribute
	}
	// Time code
	else if (canCastTo<TimeCodeAttribute>(attr)) {
		// TODO Support TimeCodeAttribute
	}

	// Vectors
	else if (canCastTo<V2fAttribute>(attr)) {
		return fromVector(getValue<V2f>(attr));
	} else if (canCastTo<V2iAttribute>(attr)) {
		return fromVector(getValue<V2i>(attr));
	} else if (canCastTo<V3fAttribute>(attr)) {
		return fromVector(getValue<V3f>(attr));
	} else if (canCastTo<V3iAttribute>(attr)) {
		return fromVector(getValue<V3i>(attr));
	}
	else if (canCastTo<V2dAttribute>(attr)) {
		return fromVector(getValue<V2d>(attr));
	} else if (canCastTo<V3dAttribute>(attr)) {
		return fromVector(getValue<V3d>(attr));
	}


	return NULL;
}
