/*
 *
 mex -c MexAndCpp.cpp
 mex  GetFundamental.cpp cv.lib cxcore.lib MexAndCpp.obj
 
 */

#include "mex.h"
#include "MatlabToOpenCV.h"

#include "matrix.h"


mxArray* GetMC(const mxArray *in,int y,int x);
void SetMC(mxArray *in,int y,int x,mxArray* val,int h,int w);
void SetMA(mxArray *in,int y,int x,double val,int h,int w);
double GetMA(const mxArray *in,int y,int x,int h,int w);


void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  
    int N=mxGetN(in[0]);
    double threshold=mxGetScalar(in[2]);
    
    CvMat* point1=cvCreateMat(N,2,CV_64FC1);
    CvMat* point2=cvCreateMat(N,2,CV_64FC1);

    CvMat* P=cvCreateMat(3,3,CV_64F);
    for(int i=0;i<N;i++)
    {
        cvSet2D(point1,i,0,cvScalar(GetMA(in[0],0,i,2,N)));
        cvSet2D(point1,i,1,cvScalar(GetMA(in[0],1,i,2,N)));
        cvSet2D(point2,i,0,cvScalar(GetMA(in[1],0,i,2,N)));
        cvSet2D(point2,i,1,cvScalar(GetMA(in[1],1,i,2,N)));
    }
    CvMat* status=cvCreateMat(1,N,CV_8UC1);
	
	out[0]=mxCreateDoubleMatrix(3,3,mxREAL);
    out[1]=mxCreateDoubleMatrix(1,N,mxREAL);
	
	if(threshold>0)
	{	
     cvFindHomography(point1,point2,P,CV_RANSAC,threshold,status);	
	}
	else if(threshold<0)
	{
     cvFindHomography(point1,point2,P,CV_LMEDS,threshold,status);
	}
	else
    {
     cvFindHomography(point1,point2,P,0,threshold,status);
    }

		
	for(int i=0;i<N;i++)
	{
		if(cvGet1D(status,i).val[0]>0)
			SetMA(out[1],0,i,1,1,N);
		else
			SetMA(out[1],0,i,0,1,N);
		
	}
	
	
	
	
	
	for(int iy=0;iy<3;iy++)
	{
		for(int ix=0;ix<3;ix++)
		{
			SetMA(out[0],iy,ix,cvGet2D(P,iy,ix).val[0],3,3);
		}
	}
	
	cvReleaseMat(&point1);
	cvReleaseMat(&point2);
	cvReleaseMat(&P);    
	cvReleaseMat(&status);
}




double GetMA(const mxArray *in,int y,int x,int h,int w)
{
	double* pTmp=mxGetPr(in);	
	return pTmp[h*x+y];
}


void SetMA(mxArray *in,int y,int x,double val,int h,int w)
{
	double* pTmp=mxGetPr(in);	
	pTmp[h*x+y]=val;
}


void SetMC(mxArray *in,int y,int x,mxArray* val,int h,int w)
{
	mxArray* pTmp=GetMC(in,y,x);
	if(pTmp==NULL)
		mxSetCell(in,h*x+y,mxDuplicateArray(val));	
	else
	{
		mxDestroyArray(pTmp);
		mxSetCell(in,h*x+y,mxDuplicateArray(val));	
	}
}

mxArray* GetMC(const mxArray *in,int y,int x)
{
	int h=(int)mxGetM(in);
	int w=(int)mxGetN(in);
	mxArray* pTmp=mxGetCell(in,h*x+y);
	return pTmp;
}