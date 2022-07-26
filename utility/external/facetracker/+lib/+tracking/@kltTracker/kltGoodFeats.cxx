#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 6)
		mexErrMsgTxt("5 input arguments expected");
	if (nlhs != 1)
		mexErrMsgTxt("1 output argument expected");

	if (mxIsComplex(prhs[1]) ||	!mxIsLogical(prhs[1]) || mxGetNumberOfDimensions(prhs[1]) != 2)
		mexErrMsgTxt("argument 1 (M) must be a logical matrix");
	int h = mxGetM(prhs[1]), w = mxGetN(prhs[1]);
	const mxLogical *M = mxGetLogicals(prhs[1]);

	if (mxIsComplex(prhs[2]) ||	!mxIsSingle(prhs[2]) || mxGetM(prhs[2]) != h || mxGetN(prhs[2]) != w)
		mexErrMsgTxt("argument 2 (XX) must be asingle matrix");
	const float *XX = (const float *) mxGetData(prhs[2]);

	if (mxIsComplex(prhs[3]) ||	!mxIsSingle(prhs[3]) || mxGetM(prhs[3]) != h || mxGetN(prhs[3]) != w)
		mexErrMsgTxt("argument 3 (YY) must be a single matrix");
	const float *YY = (const float *) mxGetData(prhs[3]);

	if (mxIsComplex(prhs[4]) ||	!mxIsSingle(prhs[4]) || mxGetM(prhs[4]) != h || mxGetN(prhs[4]) != w)
		mexErrMsgTxt("argument 3 (XY) must be a single matrix");
	const float *XY = (const float *) mxGetData(prhs[4]);

	if (mxIsComplex(prhs[5]) ||	!mxIsDouble(prhs[5]) || mxGetNumberOfElements(prhs[5]) != 1)
		mexErrMsgTxt("argument 4 (mineigval) must be a double scalar");
	float mineigval = (float) mxGetScalar(prhs[5]);
	
	float ninf = (float) -mxGetInf();

	mineigval *= 2;

	plhs[0] = mxCreateNumericMatrix(h, w, mxSINGLE_CLASS, mxREAL);
	float *EV = (float *) mxGetData(plhs[0]);

	for (int x = 0; x < w; x++)
	{
		for (int y = 0; y < h; y++, M++, XX++, YY++, XY++, EV++)
		{
			*EV = ninf;

			if (*M)
			{
				float tr = *XX + *YY;
				if (tr >= mineigval)
				{
					float ev = tr - sqrt((*XX - *YY) * (*XX - *YY) + 4 * *XY * *XY);

					if (ev >= mineigval)
						*EV = ev / 2;
				}
			}
		}
	}
}
