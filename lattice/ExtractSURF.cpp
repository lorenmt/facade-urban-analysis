// ProposalTvectors.cpp : mex-function interface implentation file


#include "mex.h"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/nonfree/features2d.hpp"    
#include "opencv2/nonfree/nonfree.hpp"
#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/legacy/legacy.hpp"
#include "opencv2/legacy/compat.hpp"
#include "opencv2/flann/flann.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "MatlabToOpenCV.h"

#include "matrix.h"

#define min(a,b) a>=b?b:a


mxArray* GetMC(const mxArray *in,int y,int x);
void SetMC(mxArray *in,int y,int x,mxArray* val,int h,int w);
void SetMA(mxArray *in,int y,int x,double val,int h,int w);

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  	
    const mxArray* mxStrImpath=in[0];//This should be input gray image.......
    int bExtended=mxGetScalar(in[1]);//1 for 128, 0 for 64....
    double dStrength=mxGetScalar(in[2]);
	char strImgPath[1024];
    int nElement=64;
    if(bExtended==1)
        nElement=128;
	mxGetString(mxStrImpath,strImgPath,1024);
    
	IplImage* iplGray=cvLoadImage(strImgPath,0);
    
    CvSeq *imageKeypoints = 0, *imageDescriptors = 0;
    CvMemStorage* storage = cvCreateMemStorage(0);

    
    cv::initModule_nonfree(); 
    CvSURFParams params = cvSURFParams(dStrength, bExtended);
    
    cvExtractSURF( iplGray, 0, &imageKeypoints, &imageDescriptors, storage, params );

    CvSeqReader dreader,kreader;
    cvStartReadSeq(imageKeypoints,&kreader);
    cvStartReadSeq(imageDescriptors,&dreader);
    out[0]=mxCreateDoubleMatrix(6,imageDescriptors->total,mxREAL);
    out[1]=mxCreateDoubleMatrix(nElement,imageDescriptors->total,mxREAL);
    
    for(int i=0;i< imageDescriptors->total;i++)
    {
        const CvSURFPoint* kp=(const CvSURFPoint*)kreader.ptr;
        const float* desc=(const float*)dreader.ptr;//this is either 128 or 64.....
        CV_NEXT_SEQ_ELEM(kreader.seq->elem_size,kreader);
        CV_NEXT_SEQ_ELEM(dreader.seq->elem_size,dreader);
        
        SetMA(out[0],0,i,kp->pt.x,6,imageDescriptors->total);
        SetMA(out[0],1,i,kp->pt.y,6,imageDescriptors->total);
        SetMA(out[0],2,i,kp->laplacian,6,imageDescriptors->total);
        SetMA(out[0],3,i,kp->size,6,imageDescriptors->total);
        SetMA(out[0],4,i,kp->dir,6,imageDescriptors->total);
        SetMA(out[0],5,i,kp->hessian,6,imageDescriptors->total);
        
        for(int k=0;k<nElement;k++)
        {
            SetMA(out[1],k,i,desc[k],nElement,imageDescriptors->total);
        }
    }
  
	cvReleaseImage(&iplGray);
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