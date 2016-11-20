#include "mex.h"

#include "MatlabToOpenCV.h"
#include "MexAndCpp.h"
double fastNCC(double* buf1,double* buf2,int nLen);

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  	
    // TODO:  add your function code here
	const mxArray* mIn=in[0];
	const mxArray* mTmp=in[1];
	const mxArray* mROI=in[2];
	
	IplImage* ipl=CMatlabToOpenCV::convert_copy(mIn);
	double* roi=mxGetPr(mROI);
	if( roi[0]!=-1)
		cvSetImageROI(ipl,cvRect((int)roi[0]-1,(int)roi[1]-1,(int)roi[2],(int)roi[3]));
	
	IplImage* tmp=CMatlabToOpenCV::convert_copy(mTmp);
	IplImage* result=cvCreateImage(cvSize(ipl->width-tmp->width+1,ipl->height-tmp->height+1),IPL_DEPTH_32F,1);
	cvMatchTemplate(ipl,tmp,result,CV_TM_CCOEFF_NORMED);

	//CV_TM_CCOEFF_NORMED
	//CV_TM_CCORR_NORMED
	CMatlabToOpenCV::release_iplimage(ipl);
	CMatlabToOpenCV::release_iplimage(tmp);
	out[0]=mxCreateDoubleMatrix(ipl->height-tmp->height+1,ipl->width-tmp->width+1,mxREAL);


	
	CMatlabToOpenCV::ipl_to_matlab(result,out[0]);
	cvReleaseImage(&result);
	

	/*
	int h=mxGetM(in[0]);
	int w=mxGetN(in[0]);
	out[0]=mxCreateDoubleMatrix(h,w,mxREAL);
	int th=mxGetM(mTmp);
	int tw=mxGetN(mTmp);
	int dh=(int)(th/2);
	int dw=(int)(tw/2);
	
	double* pTmp=(double*)mxMalloc(sizeof(double)*th*tw);
	//building template into double array...
	for(int y=0;y<th;y++)
	{
		for(int x=0;x<tw;x++)
		{
			pTmp[y*tw+x]=CMexAndCpp::GetMA(mTmp,y,x);
		}
	}

	double* pROI=(double*)mxMalloc(sizeof(double)*th*tw);
	for(int y=dh;y<h-dh;y++)
	{
		for(int x=dw;x<w-dw;x++)
		{
			
			int yy=0;
			for(int ry=y-dh;ry<y+dh;ry++)
			{			
				int xx=0;
				for(int rx=x-dw;rx<x+dw;rx++)
				{
					pROI[yy*tw+xx]=CMexAndCpp::GetMA(mIn,ry,rx);
					xx++;
				}
				yy++;
			}
			//Now NCC
			CMexAndCpp::SetMA(out[0],y,x,fastNCC(pTmp,pROI,th*tw));
		}
	}
	mxFree(pROI);
	mxFree(pTmp);
	*/
    return;
}


double fastNCC(double* buf1,double* buf2,int nLen)
{
	//printf("Enter fastNCC\n");
	double A1=0;
	double B1=0;
	double C1=0;
	double D=0;
	double A2=0;
	double B2=0;
	double C2=0;
	int i=0;
	for(i=0;i<nLen;i++)
	{
		A1+=buf1[i];
		B1+=(buf1[i]*buf1[i]);
		A2+=buf2[i];
		B2+=(buf2[i]*buf2[i]);
		D+=(buf1[i]*buf2[i]);
	}
	C1=1/sqrt(nLen*B1-A1*A1);
	C2=1/sqrt(nLen*B2-A2*A2);
	//printf("Exit fastNCC\n");
	return ((nLen*D-A1*A2)*C1*C2);
}
