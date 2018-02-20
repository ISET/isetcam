#include <math.h>
#include "mex.h"

/* Input Arguments */
#define	C_IN	prhs[0]
#define	D_IN	prhs[1]

/* Output Arguments */
#define	A_OUT	plhs[0]

static	double	pi = 3.1415926;

static void processMat(
		   double	*A,
		   double	*C,
 		   double	*D,
           int   m,
           int   n,
           int   mD,
           int   nD
		   )
{
    int i, j, k;
    double gi, hi;

    for(i = 0; i < nD; i++)
    {
        for(j = 0; j < m; j++)
        {
            for(k = 0; k < n; k++)
            {
                gi = *(C + k*m + j)/(*(D + i));
                if( gi >= 1 || gi <= -1)
                    hi = 0;
                else
                    hi = (2/pi)*(acos(gi) - (gi * sqrt(1 - gi*gi)));
                *(A + i*m*n + k*m + j) = hi;
            }
        }        
    }
    return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *A; 
    double *C,*D; 
    int rC, cC, rD, cD, ntemp; 
    int  dims[3];
    
    /* Check for proper number of arguments */
    if (nrhs != 2)
    { 
        mexErrMsgTxt("Two input arguments required."); 
    } 
    else if (nlhs > 1) 
    {
        mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* Check the dimensions of D.  D can be m * 1 or 1 * n. */ 
    rD = mxGetM(D_IN); 
    cD = mxGetN(D_IN);   /* F = length(D) */
    if(cD == 1)
    {
        ntemp = rD;
        rD = cD;
        cD = ntemp;
    }
    
    if (!mxIsDouble(C_IN) || !mxIsDouble(D_IN)/*|| (MIN(r, f) != 1)*/) 
    {
        mexErrMsgTxt("processMat requires the input arguments must be of type double."); 
    } 
   
    /* [r, c] = size(C) */
    rC = mxGetM(C_IN);
    cC = mxGetN(C_IN);
       
     /* Create a matrix for the return argument */ 
    dims[0] = rC;
    dims[1] = cC;    
    dims[2] = cD;
    A_OUT = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    /* Assign pointers to the various parameters */ 
    A = mxGetPr(A_OUT);
    
    C = mxGetPr(C_IN); 
    D = mxGetPr(D_IN);
        
    /* Do the actual computations in a subroutine */
    processMat(A, C, D, rC, cC, rD, cD);
    
   /* Reshape the out put */
    if(rC ==1)
    {
        if( cC == 1)
        {
            mxSetM(A_OUT, cD);
            mxSetN(A_OUT, cC);
        }
        else
        {
            mxSetM(A_OUT, cC);
            mxSetN(A_OUT, cD);
        }
    }
    else if(cC == 1)
    {
        mxSetM(A_OUT, rC);
        mxSetN(A_OUT, cD);
    }    
    return;    
}
