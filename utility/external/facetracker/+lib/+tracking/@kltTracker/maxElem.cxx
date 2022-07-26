#include "mex.h"

template<class T>
void Max(const T *X, int n, T &mx, int &mi)
{
	mx = *(X++);
	mi = 1;
	for (int i = 2; i <= n; i++, X++)
	{
		if (*X > mx)
		{
			mx = *X;
			mi = i;
		}
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 2)
		mexErrMsgTxt("1 input argument expected");
	if (nlhs != 1 && nlhs != 2)
		mexErrMsgTxt("1 or 2 output arguments expected");

	int n;
	if (mxIsComplex(prhs[1]) ||
		(!mxIsSingle(prhs[1]) && !mxIsDouble(prhs[1])) ||
		!(n = mxGetNumberOfElements(prhs[1])))
		mexErrMsgTxt("argument 1 must be a non-empty single/double array");

	plhs[0] = mxCreateNumericMatrix(1, 1, mxGetClassID(prhs[1]), mxREAL);

	int mi;
	switch (mxGetClassID(prhs[1]))
	{
		case mxSINGLE_CLASS:
			Max((const float *) mxGetData(prhs[1]), n, *((float *) mxGetData(plhs[0])), mi);
			break;
		case mxDOUBLE_CLASS:
			Max((const double *) mxGetData(prhs[1]), n, *((double *) mxGetData(plhs[0])), mi);
			break;
	}

	if (nlhs > 1)
		plhs[1] = mxCreateDoubleScalar(mi);
}
