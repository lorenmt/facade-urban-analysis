// ProposalTvectors.cpp : mex-function interface implentation file


#include "mex.h"
#include "MatlabToOpenCV.h"

#include "matrix.h"

#define min(a,b) a>=b?b:a


mxArray* GetMC(const mxArray *in,int y,int x);
void SetMC(mxArray *in,int y,int x,mxArray* val,int h,int w);
void SetMA(mxArray *in,int y,int x,double val,int h,int w);

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  	
	const mxArray* str=in[0];
    double  mindistance=mxGetScalar(in[1]);
    double nBlockSize=mxGetScalar(in[2]);
	double qual=mxGetScalar(in[3]);
	int maxNum=mxGetScalar(in[4]);
	

	char strImgPath[1024];

	mxGetString(str,strImgPath,1024);
	IplImage* iplInput=cvLoadImage(strImgPath,0);



	IplImage* eig=cvCreateImage(cvSize(iplInput->width,iplInput->height),IPL_DEPTH_32F,1);
	IplImage* tmp=cvCreateImage(cvSize(iplInput->width,iplInput->height),IPL_DEPTH_32F,1);
	//We want nCnt number of corner to start with......
	
	int nCorner=maxNum;
	
	CvPoint2D32f* ptr=(CvPoint2D32f*)mxMalloc(sizeof(CvPoint2D32f)*maxNum);


	int nCornerFound=maxNum;
	int nPos=0;
	
    double tmpQual=qual;
    cvGoodFeaturesToTrack( iplInput, eig, tmp, ptr, &nCornerFound, tmpQual, mindistance, NULL, nBlockSize, 1, qual);
    
	out[0]=mxCreateDoubleMatrix(2,nCornerFound,mxREAL);

	for(int i=0;i<nCornerFound;i++)
	{		
		SetMA(out[0],0,i,ptr[i].x+1,2,nCornerFound);
		SetMA(out[0],1,i,ptr[i].y+1,2,nCornerFound);
	}
	mxFree(ptr);
	
	cvReleaseImage(&iplInput);
	cvReleaseImage(&eig);
	cvReleaseImage(&tmp);
	
    return;
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