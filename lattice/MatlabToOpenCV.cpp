#include "MatlabToOpenCV.h"
#include "MexAndCpp.h"

CMatlabToOpenCV::CMatlabToOpenCV(void)
{
}

CMatlabToOpenCV::~CMatlabToOpenCV(void)
{
}

/*
IplImage*  CMatlabToOpenCV::convert_matlabarray_toCpparray(const mxArray* mxIn)
{
	int h=mxGetM(mxIn);
	int w=mxGetN(mxIn);
	IplImage* iplRet=create_iplimage(h,w,8);
	int widthStep=iplRet->widthStep;
	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			iplRet->imageData[y*widthStep+x]=(char)CMexAndCpp::GetMA(mxIn,y,x,h,w);
		}
	}
	return iplRet;
}
*/


IplImage*  CMatlabToOpenCV::convert_copy(const mxArray* mxIn)
{
	int h=mxGetM(mxIn);
	int w=mxGetN(mxIn);
	/*IplImage* iplRet=create_iplimage(h,w,8);*/
	IplImage* iplRet=cvCreateImage(cvSize(w,h),8,1);
	int widthStep=iplRet->widthStep;
	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			CvScalar val;
			val.val[0]=CMexAndCpp::GetMA(mxIn,y,x,h,w);
			cvSet2D(iplRet,y,x,val);
		}
	}
	return iplRet;
}


void  CMatlabToOpenCV::DivS(IplImage* in,float scalar)
{
	int w=in->width;
	int h=in->height;
	int wstep=in->widthStep;
	if( in->depth==8)
	{
		for( int y=0;y<h;y++)
		{
			for(int x=0;x<w;x++)
			{
				in->imageData[y*wstep+x]/=scalar;
			}
		}
	}
	else
	{
		for( int y=0;y<h;y++)
		{
			for(int x=0;x<w;x++)
			{
				float* pVal=(float*)&(in->imageData[y*wstep+x*sizeof(float)]);
				(*pVal)/=scalar;
			}
		}
	}
	
}

IplImage*  CMatlabToOpenCV::convert_copy_DblTo32F(const mxArray* mxIn)
{
	int h=mxGetM(mxIn);
	int w=mxGetN(mxIn);
	IplImage* iplRet=cvCreateImage(cvSize(w,h),IPL_DEPTH_32F,1);
	/*IplImage* iplRet=create_iplimage(h,w,IPL_DEPTH_32F);*/
	int widthStep=iplRet->widthStep;
	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			CvScalar val;
			val.val[0]=CMexAndCpp::GetMA(mxIn,y,x,h,w);
			cvSet2D(iplRet,y,x,val);
		}
	}
	return iplRet;
}


IplImage*  CMatlabToOpenCV::convert_copy_DblTo8U(const mxArray* mxIn)
{
	int h=mxGetM(mxIn);
	int w=mxGetN(mxIn);
	IplImage* iplRet=cvCreateImage(cvSize(w,h),8,1);
	/*IplImage* iplRet=create_iplimage(h,w,IPL_DEPTH_32F);*/
	int widthStep=iplRet->widthStep;
	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			CvScalar val;
			val.val[0]=CMexAndCpp::GetMA(mxIn,y,x,h,w);
			cvSet2D(iplRet,y,x,val);
		}
	}
	return iplRet;
}


IplImage*  CMatlabToOpenCV::convert_copy_DblTo64F(const mxArray* mxIn)
{
	int h=mxGetM(mxIn);
	int w=mxGetN(mxIn);
	IplImage* iplRet=cvCreateImage(cvSize(w,h),IPL_DEPTH_32F,1);
	/*IplImage* iplRet=create_iplimage(h,w,IPL_DEPTH_64F);*/
	int widthStep=iplRet->widthStep;
	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			CvScalar val;
			val.val[0]=CMexAndCpp::GetMA(mxIn,y,x,h,w);
			cvSet2D(iplRet,y,x,val);
		}
	}
	return iplRet;
}




void  CMatlabToOpenCV::ipl_to_matlab(const IplImage* ipl, mxArray* mxOut)
{
	int h=ipl->height;
	int w=ipl->width;

	for( int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{	
			CMexAndCpp::SetMA(mxOut,y,x,cvGet2D(ipl,y,x).val[0]);
		}
	}
}
/*

IplImage*  CMatlabToOpenCV::create_iplheader_putinto_mxarray(int h,int w,int depth)
{
	mxArray* ret=mxCreateNumericMatrix(1,sizeof(IplImage),mxINT8_CLASS,mxREAL);

	IplImage* iplRet=(IplImage*)mxGetData(ret);
	iplRet->height=h;
	iplRet->width=w;
	iplRet->nChannels=1;
	iplRet->nSize=sizeof(IplImage);
	iplRet->ID=0;
	//iplRet->alphaChannel=0;
	iplRet->depth=depth;
	//iplRet->channelSeq[0]=71;
	//iplRet->channelSeq[1]=82;
	//iplRet->channelSeq[2]=65;
	//iplRet->channelSeq[3]=89;
	//iplRet->colorModel[0]=71;
	//iplRet->colorModel[1]=82;
	//iplRet->colorModel[2]=65;
	//iplRet->colorModel[3]=89;
	iplRet->dataOrder=0;
	iplRet->origin=0;
	//iplRet->align=4;
	iplRet->roi=NULL;
	iplRet->maskROI=NULL;
	iplRet->imageId=0;
	iplRet->tileInfo=0;
	iplRet->widthStep=(w+(4-w%4))*(depth/8);
	//iplRet->BorderConst[0]=0;
	//iplRet->BorderConst[1]=0;
	//iplRet->BorderConst[2]=0;
	//iplRet->BorderConst[3]=0;
	iplRet->imageSize=iplRet->widthStep*h;
	iplRet->imageData=NULL;
	iplRet->imageDataOrigin=NULL;

	return iplRet;
}

*/
IplImage*  CMatlabToOpenCV::create_iplimage(int h,int w,int depth)
{
	IplImage* iplRet=(IplImage*)mxMalloc(sizeof(IplImage));
	iplRet->height=h;
	iplRet->width=w;
	iplRet->nChannels=1;
	iplRet->nSize=sizeof(IplImage);
	iplRet->ID=0;
	//iplRet->alphaChannel=0;
	iplRet->depth=depth;
	//iplRet->channelSeq[0]=71;
	//iplRet->channelSeq[1]=82;
	//iplRet->channelSeq[2]=65;
	//iplRet->channelSeq[3]=89;
	//iplRet->colorModel[0]=71;
	//iplRet->colorModel[1]=82;
	//iplRet->colorModel[2]=65;
	//iplRet->colorModel[3]=89;
	iplRet->dataOrder=0;
	iplRet->origin=0;
	//iplRet->align=4;
	iplRet->roi=NULL;
	iplRet->maskROI=NULL;
	iplRet->imageId=0;
	iplRet->tileInfo=0;
	iplRet->widthStep=(w+(4-w%4))*(depth/8);
	//iplRet->BorderConst[0]=0;
	//iplRet->BorderConst[1]=0;
	//iplRet->BorderConst[2]=0;
	//iplRet->BorderConst[3]=0;
	iplRet->imageSize=iplRet->widthStep*h;
	iplRet->imageData=(char*)mxMalloc(sizeof(char)*(iplRet->imageSize));
	iplRet->imageDataOrigin=iplRet->imageData;

	return iplRet;
}


void  CMatlabToOpenCV::release_iplimage(IplImage* ipl)
{
	//mxFree(ipl->imageData);
	//mxFree(ipl);
	cvReleaseImage(&ipl);
}
