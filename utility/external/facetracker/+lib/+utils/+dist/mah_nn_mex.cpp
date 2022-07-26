// mex -O CXXFLAGS="\$CXXFLAGS -funroll-loops -ftree-vectorizer-verbose=2" mah_nn_mex.cpp
// mex -O mah_nn_mex.cpp

// TODO add AVX support (requires checking if AVX is available)

#include<cfloat>
#include <x86intrin.h>

#include "mex.h"

using namespace std;

// Mahalanobis distance
float mah_dist(int ndim, const float *a, const float *b, const float *s)
{
    float sum = 0;
    __m128 sseSum = _mm_setzero_ps();
    
    for (; ndim >= 4; ndim -= 4) 
    {
        __m128 sseA = _mm_loadu_ps(a);
        __m128 sseB = _mm_loadu_ps(b);
        __m128 sseS = _mm_loadu_ps(s);
        
        __m128 sseDelta = _mm_sub_ps(sseA, sseB);
        __m128 sseDelta2 = _mm_mul_ps(sseDelta, sseDelta);
        __m128 sseDelta2div = _mm_mul_ps(sseDelta2, sseS);
        
        sseSum = _mm_add_ps(sseSum, sseDelta2div);
        
        a += 4;
        b += 4;
        s += 4;
    }
    
    sseSum = _mm_hadd_ps(sseSum, sseSum);
    sseSum = _mm_hadd_ps(sseSum, sseSum);
    
    sum = _mm_cvtss_f32(sseSum);
    
    while (ndim--) 
    {
        float delta = (*a++) - (*b++);        
        sum += delta * delta * (*s++);
    }
    
    return sum;
}

// computes Mahalanobis NNs
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const mxArray *pmxFeat = prhs[0];
    const mxArray *pmxMean = prhs[1];
    const mxArray *pmxVar = prhs[2];
    const mxArray *pmxLogVarSum = prhs[3];
    
    float *pFeat = (float *)mxGetData(pmxFeat);
    float *pMean = (float *)mxGetData(pmxMean);
    float *pInvVar = (float *)mxGetData(pmxVar);
    float *pLogVarSum = (float *)mxGetData(pmxLogVarSum);
    
    const int nClusters = mxGetN(pmxMean);
    const int featDim = mxGetM(pmxMean);
    const int nFeat = mxGetN(pmxFeat);
    
//     mexPrintf("nClusters = %d, featDim = %d, nFeat = %d\n", nClusters, featDim, nFeat);
    
    plhs[0] = mxCreateNumericMatrix(1, nFeat, mxINT32_CLASS, mxREAL);
    int *pAssign = (int *)mxGetData(plhs[0]); 
    
    // feature loop
    for (int iFeat = 0; iFeat < nFeat; iFeat++)
    {
        float *pMeanCur = pMean;
        float *pInvVarCur = pInvVar;
        
        float minDist = FLT_MAX;
        int minIdx = -1;
        
        // cluster loop
        for (int iCluster = 0; iCluster < nClusters; iCluster++)
        {
            float curDist = mah_dist(featDim, pFeat, pMeanCur, pInvVarCur) + pLogVarSum[iCluster];
            
            // check if min
            if (curDist < minDist)
            {
                minDist = curDist;
                minIdx = iCluster;
            }
            
            pMeanCur += featDim;
            pInvVarCur += featDim;            
                
        }
        
        // convert to mlab indices
        *pAssign++ = minIdx + 1;
        
        pFeat += featDim;
    }
}