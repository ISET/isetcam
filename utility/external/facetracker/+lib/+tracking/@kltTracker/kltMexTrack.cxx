#include "mex.h"

const char *szErrMsgs[] =
{
	"ok",
	"error in tracking context",
	"error in pyramid"
};

enum {ERR_OK = 0, ERR_TC, ERR_PYR };

enum {
	klt_tracked = 0,
	klt_notfound = 1,
	klt_smalldet = -2,
	klt_maxiters = -3,
	klt_oob = -4,
	klt_largeresid = -5
};

struct IXYLevel
{
	int			nHeight, nWidth;
	const float *I, *GX, *GY;
};

struct IXYPyramid
{
	int			nLevels;
	IXYLevel	*Level;

	IXYPyramid()
	{
	}

	~IXYPyramid()
	{
		delete[] Level;
	}
};

struct TrackingContext
{
	int		nPyramidLevels;
	int		nWinSize;
	int		nMaxIters;
	float	fMinDisp;
	float	fMinDet;
	float	fMaxResidual;

	IXYPyramid *pPyramid;

	TrackingContext()
	{
		pPyramid = NULL;
	}

	~TrackingContext()
	{
		if (pPyramid)
			delete pPyramid;
	}
};

template<class T>
inline T ABS(T x)
{
	return (x > 0) ? x : -x;
}

template<class T>
bool ParseScalar(const mxArray *a, T &val)
{
	if (a && !mxIsComplex(a) && mxIsDouble(a) && mxGetNumberOfElements(a) == 1)
	{
		val = (T) mxGetScalar(a);
		return true;
	}
	else
		return false;
}

IXYPyramid *ParsePyramid(const mxArray *a, int &err)
{
	IXYPyramid *p = new IXYPyramid;

	p->nLevels = mxGetNumberOfElements(a);
	p->Level = new IXYLevel[p->nLevels];

	IXYLevel *l = p->Level;
	for (int i = 0; i < p->nLevels; i++, l++)
	{
		const mxArray *lev = mxGetCell(a, i);
		l->I = (const float *) mxGetData(mxGetField(lev, 0, "I"));
		l->GX = (const float *) mxGetData(mxGetField(lev, 0, "GX"));
		l->GY = (const float *) mxGetData(mxGetField(lev, 0, "GY"));

		if (!l->I || !l->GX || !l->GY)
		{
			err = ERR_PYR;
			delete p;
			return NULL;
		}

		l->nHeight = mxGetM(mxGetField(lev, 0, "I"));
		l->nWidth = mxGetN(mxGetField(lev, 0, "I"));
	}

	err = ERR_OK;
	return p;
}

TrackingContext *ParseTrackingContext(const mxArray *a, int &err)
{
	TrackingContext *tc = new TrackingContext;

	{
		const mxArray *p = mxGetField(a, 0, "pyramid");
		if (p)
			tc->pPyramid = ParsePyramid(p, err);
		else
			err = ERR_TC;
	}

	if (!err)	err = ParseScalar(mxGetField(a, 0, "pyramid_levels"), tc->nPyramidLevels) ? ERR_OK : ERR_TC;
	if (!err)	err = ParseScalar(mxGetField(a, 0, "winsize"), tc->nWinSize) ? ERR_OK : ERR_TC;
	if (!err)	err = ParseScalar(mxGetField(a, 0, "maxiters"), tc->nMaxIters) ? ERR_OK : ERR_TC;
	if (!err)	err = ParseScalar(mxGetField(a, 0, "mindisp"), tc->fMinDisp) ? ERR_OK : ERR_TC;
	if (!err)	err = ParseScalar(mxGetField(a, 0, "mindet"), tc->fMinDet) ? ERR_OK : ERR_TC;
	if (!err)	err = ParseScalar(mxGetField(a, 0, "maxresidual"), tc->fMaxResidual) ? ERR_OK : ERR_TC;

	if (err)
	{
		delete tc;
		return NULL;
	}
	else
		return tc;
}

template<class T>
inline void BilinearInterpolate(const T *I, int ih, float x0, float y0, int bw, int bh, T *J)
{
	int		x0i = (int) x0, y0i = (int) y0;
	float	ax = x0 - x0i, ay = y0 - y0i;
	float	a00 = (1 - ax) * (1 - ay), a01 = ax * (1 - ay),
			a10 = (1 - ax) * ay, a11 = ax * ay;
	int		xoff = ih - 2 * bh - 1;

	I += (x0i - bw - 1) * ih + y0i - bh - 1;

	for (int x = -bw; x <= bw; x++, I += xoff)
		for (int y = -bh; y <= bh ; y++, I++)
			*(J++) = I[0] * a00 + I[1] * a10 + I[ih] * a01 + I[ih + 1] * a11;
}

inline int SolveLK(const float *I1, const float *GX1, const float *GY1,
			 const float *I2, const float *GX2, const float *GY2,
			 int n,
			 float mindet,
			 float &dx, float &dy)
{
	float gxx, gxy, gyy, ex, ey;

	gxx = gxy = gyy = ex = ey = 0;

	while (n--)
	{
		float	d = *(I1++) - *(I2++);
		float	gx = *(GX1++) + *(GX2++);
		float	gy = *(GY1++) + *(GY2++);
		
		gxx += gx * gx;
		gxy += gx * gy;
		gyy += gy * gy;
		ex += d * gx;
		ey += d * gy;
	}

	float dt = gxx * gyy - gxy * gxy;

	if (dt >= mindet)
	{
		dx = (gyy * ex - gxy * ey) / dt;
		dy = (gxx * ey - gxy * ex) / dt;
		return klt_tracked;
	}
	else
		return klt_smalldet;
}

inline float L1Error(const float *I1, const float *I2, int n)
{
	float e = 0;

	while (n--)
		e += ABS(*(I1++) - *(I2++));

	return e;
}

// KLT_TRACKFEAT(tc,oldpyr,x1,y1,x2,y2)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 5 && nrhs != 6)
		mexErrMsgTxt("3 or 4 input arguments expected");
	if (nlhs != 1)
		mexErrMsgTxt("1 output argument expected");

	int err;

	TrackingContext *tc = ParseTrackingContext(prhs[1], err);
	if (err)
		mexErrMsgTxt(szErrMsgs[err]);

	IXYPyramid *oldpyr = ParsePyramid(prhs[2], err);
	if (err)
	{
		delete tc;
		mexErrMsgTxt(szErrMsgs[err]);
	}

	if (!mxIsSingle(prhs[3]) || mxIsComplex(prhs[3]) || mxGetNumberOfDimensions(prhs[3]) != 2 ||
		mxGetM(prhs[3]) != 3)
	{
		delete tc;
		mexErrMsgTxt("argument 3 (P) must be a 3 x n single matrix");
	}
	int nf = mxGetN(prhs[3]);

	if (!mxIsSingle(prhs[4]) || mxIsComplex(prhs[4]) || mxGetNumberOfDimensions(prhs[4]) != 2 ||
		mxGetM(prhs[4]) != 3 || mxGetN(prhs[4]) != nf)
	{
		delete tc;
		mexErrMsgTxt("argument 4 (Pp) must be a 3 x n single matrix");
	}

	const mxLogical *M = NULL;
	if (nrhs > 5)
	{
		if (!mxIsLogical(prhs[5]) || mxGetNumberOfDimensions(prhs[5]) != 2)
		{
			delete tc;
			mexErrMsgTxt("argument 5 (M) must be a logical matrix");
		}
		M = mxGetLogicals(prhs[5]);
	}

	plhs[0] = mxDuplicateArray(prhs[3]);

	int	wsz = tc->nWinSize, wdim = (wsz * 2 + 1) * (wsz * 2 + 1);

	float	*I1 = (float *) mxMalloc(wdim * sizeof(float)),
			*GX1 = (float *) mxMalloc(wdim * sizeof(float)),
			*GY1 = (float *) mxMalloc(wdim * sizeof(float));

	float	*I2 = (float *) mxMalloc(wdim * sizeof(float)),
			*GX2 = (float *) mxMalloc(wdim * sizeof(float)),
			*GY2 = (float *) mxMalloc(wdim * sizeof(float));


	const float *P = (const float *) mxGetData(prhs[3]);
	const float *Pp = (const float *) mxGetData(prhs[4]);
	float *Q = (float *) mxGetData(plhs[0]);

	int scl0 = 1 << tc->nPyramidLevels;

	for (int f = 0; f < nf; f++, P += 3, Pp += 3, Q += 3)
	{
		if (P[2] < 0)
			continue;

		float	x1 = (P[0] - 1) / scl0 + 1,
				y1 = (P[1] - 1) / scl0 + 1,
				x2 = (Pp[0] - 1) / scl0 + 1,
				y2 = (Pp[1] - 1) / scl0 + 1;

		int status;

		for (int r = tc->nPyramidLevels - 1; r >= 0 ; r--)
		{
			const IXYLevel &lOld = oldpyr->Level[r], lNew = tc->pPyramid->Level[r];

			x1 = (x1 - 1) * 2 + 1;
			y1 = (y1 - 1) * 2 + 1;
			x2 = (x2 - 1) * 2 + 1;
			y2 = (y2 - 1) * 2 + 1;

			if (x1 - wsz < 2 || x1 + wsz >= lOld.nWidth || y1 - wsz < 2 || y1 + wsz >= lOld.nHeight)
			{
				status = klt_oob;
				break;
			}

			BilinearInterpolate(lOld.I, lOld.nHeight, x1, y1, wsz, wsz, I1);
			BilinearInterpolate(lOld.GX, lOld.nHeight, x1, y1, wsz, wsz, GX1);
			BilinearInterpolate(lOld.GY, lOld.nHeight, x1, y1, wsz, wsz, GY1);

			status = klt_maxiters;

			for (int i = 0; i < tc->nMaxIters; i++)
			{
				if (x2 - wsz < 2 || x2 + wsz >= lNew.nWidth || y2 - wsz < 2 || y2 + wsz >= lNew.nHeight)
				{
					status = klt_oob;
					break;
				}

				BilinearInterpolate(lNew.I, lNew.nHeight, x2, y2, wsz, wsz, I2);
				BilinearInterpolate(lNew.GX, lNew.nHeight, x2, y2, wsz, wsz, GX2);
				BilinearInterpolate(lNew.GY, lNew.nHeight, x2, y2, wsz, wsz, GY2);

				float dx, dy;
			
				status = SolveLK(I1, GX1, GY1, I2, GX2, GY2, wdim, tc->fMinDet, dx, dy);
				if (status == klt_smalldet)
					break;

				status = klt_tracked;

				x2 += dx;
				y2 += dy;

				if (ABS(dx) < tc->fMinDisp && ABS(dy) < tc->fMinDisp)
					break;
			}

			if (status == klt_smalldet)
				break;

			if (x2 - wsz < 2 || x2 + wsz >= lNew.nWidth || y2 - wsz < 2 || y2 + wsz >= lNew.nHeight)
			{
				status = klt_oob;
				break;
			}
		}

		if (status == klt_tracked)
		{
			const IXYLevel &lNew = tc->pPyramid->Level[0];

			if (M && M[((int) (x2) - 1) * lNew.nHeight + ((int) y2 - 1)])
				status = klt_oob;

			if (status == klt_tracked)
			{
				BilinearInterpolate(lNew.I, lNew.nHeight, x2, y2, wsz, wsz, I2);
				if (L1Error(I1, I2, wdim) > tc->fMaxResidual * wdim)
					status = klt_largeresid;
			}
		}

		if (status == klt_tracked)
		{
			Q[0] = x2;
			Q[1] = y2;
		}
		else
			Q[0] = Q[1] = -1;
		Q[2] = status;
	}
}
