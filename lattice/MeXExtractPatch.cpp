// ProposalTvectors.cpp : mex-function interface implentation file


#include "mex.h"

#include "math.h"
#include "matrix.h"

#define min(a,b) a>=b?b:a
#define max(a,b) a>=b?a:b


mxArray* GetMC(const mxArray *in,int y,int x);
void SetMC(mxArray *in,int y,int x,mxArray* val,int h,int w);
void SetMA(mxArray *in,int y,int x,double val,int h,int w);
double GetMA(const mxArray *in,int y,int x,int h,int w);

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  	
	const mxArray* mIM=in[0];
    const mxArray* pPt=in[2];
    int nHWid=mxGetScalar(in[1]);
    int h=mxGetM(mIM);
    int w=mxGetN(mIM);
    int N=mxGetN(pPt);
    int nVecDim=(2*nHWid+1)*(2*nHWid+1);
    
    out[0]=mxCreateDoubleMatrix(nVecDim,N,mxREAL);
    out[1]=mxCreateDoubleMatrix(1,N,mxREAL);
    out[2]=mxCreateDoubleMatrix(1,1,mxREAL);
    int nCnt=0;
    for(int i=0;i<N;i++)
    {
        int x=(int)GetMA(pPt,0,i,2,N);
        int y=(int)GetMA(pPt,1,i,2,N);
        
        if(x>=nHWid && x< w-nHWid && y>=nHWid && y<h-nHWid)
        {
            SetMA(out[1],0,nCnt,i+1,1,N);
            double nSum=0;
            double nSqSum=0;
            int pos=0;
            for(int ix=-nHWid;ix<=nHWid;ix++)
            {
                for(int iy=-nHWid;iy<=nHWid;iy++)
                {
                    double dVal=GetMA(mIM,y+iy,x+ix,h,w);
                    nSum+=dVal;
                    nSqSum+=pow(dVal,2);
                }
            }
            double mean=nSum/nVecDim;
            double std=sqrt(nSqSum/nVecDim-pow(mean,2));
            pos=0;
            for(int ix=-nHWid;ix<=nHWid;ix++)
            {
                for(int iy=-nHWid;iy<=nHWid;iy++)
                {
                    double dVal=GetMA(mIM,y+iy,x+ix,h,w);
                    dVal-=mean;
                    dVal/=max(0.00000000000000000000001,std);
                    SetMA(out[0],pos++,nCnt,dVal,nVecDim,N);
                }
            }
            nCnt++;
        }
    }
    SetMA(out[2],0,0,nCnt,1,1);

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