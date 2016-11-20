#include "MexAndCpp.h"
#include <float.h>
#include <math.h>


#ifndef isnan
#define isnan(x) _isnan(x)
#endif

CMexAndCpp::CMexAndCpp(void)
{

}

CMexAndCpp::~CMexAndCpp(void)
{

}


/*
PTR ptminus(PTR* pt1,PTR* pt2)
{
	PTR ret;
	ret.x=pt1->x-pt2->x;
	ret.y=pt1->y-pt2->y;
	return ret;
}

PTR ptplus(PTR* pt1,PTR* pt2)
{
	PTR ret;
	ret.x=pt1->x+pt2->x;
	ret.y=pt1->y+pt2->y;
	return ret;
}
*/




mxArray* CMexAndCpp::division(mxArray* A,mxArray* B)
{
	int h=mxGetM(A);
	int w=mxGetN(A);
	mxArray* mxOut=mxDuplicateArray(A);
	for(int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			double val=GetMA(A,y,x)/GetMA(B,y,x);
			SetMA(mxOut,y,x,val);
		}
	}
	return mxOut;
}

void CMexAndCpp::division(double* A,double B,int nLen)
{
	
	for(int i=0;i<nLen;i++)
	{
		A[i]=A[i]/B;	
	}
}


mxArray* CMexAndCpp::division(mxArray* A,double B)
{
	int h=mxGetM(A);
	int w=mxGetN(A);
	mxArray* mxOut=mxDuplicateArray(A);
	for(int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			double val=GetMA(A,y,x)/B;
			SetMA(mxOut,y,x,val);
		}
	}
	return mxOut;
}
mxArray* CMexAndCpp::multiplication(const mxArray* A,const mxArray* B)
{
	int h=mxGetM(A);
	int w=mxGetN(A);
	mxArray* mxOut=mxDuplicateArray(A);
	for(int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			double val=GetMA(A,y,x)*GetMA(B,y,x);
			SetMA(mxOut,y,x,val);
		}
	}
	return mxOut;
}

void CMexAndCpp::multiplication(const double* A,const double* B,double* C,int nLen)
{
	for(int i=0;i<nLen;i++)
	{
		C[i]=A[i]*B[i];
	}	
}


void CMexAndCpp::Selfmultiplication(const double* A,double* C,int nLen)
{
	for(int i=0;i<nLen;i++)
	{
		C[i]=A[i]*C[i];
	}	
}



double CMexAndCpp::GetMA(const mxArray *in,int y,int x)
{
	int h=(int)mxGetM(in);
	int w=(int)mxGetN(in);
	double* pTmp=mxGetPr(in);	
	if(isnan(pTmp[h*x+y]))
	{
		return 0.1;
	}
	else
		return pTmp[h*x+y];
}

double CMexAndCpp::GetMA(const mxArray *in,int y,int x,int z,int h,int w)
{
	double* pTmp=mxGetPr(in);
    if(isnan(pTmp[z*h*w+x*h+y]))
	{
		return 0.1;
	}
	else
		return pTmp[z*h*w+x*h+y];
}

void CMexAndCpp::SetMA(const mxArray *in,int y,int x,int z,double val,int h,int w)
{
    double* pTmp=mxGetPr(in);
	pTmp[z*h*w+x*h+y]=val;
}

double CMexAndCpp::GetMA(const mxArray *in,int y,int x,int h,int w)
{
	double* pTmp=mxGetPr(in);	
	if(isnan(pTmp[h*x+y]))
	{
		return 0.1;
	}
	else
		return pTmp[h*x+y];
}

mxArray* CMexAndCpp::GetMC(const mxArray *in,int y,int x)
{
	int h=(int)mxGetM(in);
	int w=(int)mxGetN(in);
	mxArray* pTmp=mxGetCell(in,h*x+y);
	return pTmp;
}

void CMexAndCpp::SetMA(mxArray *in,int y,int x,double val,int h,int w)
{
	double* pTmp=mxGetPr(in);	
	pTmp[h*x+y]=val;
}

void CMexAndCpp::SetMA(mxArray *in,int y,int x,double val)
{
	int h=(int)mxGetM(in);
	int w=(int)mxGetN(in);
	double* pTmp=mxGetPr(in);	
	pTmp[h*x+y]=val;
}

void CMexAndCpp::SetMC(mxArray *in,int y,int x,mxArray* val)
{
	int h=(int)mxGetM(in);
	int w=(int)mxGetN(in);	
	mxArray* pTmp=GetMC(in,y,x);
	if(pTmp==NULL)
		mxSetCell(in,h*x+y,mxDuplicateArray(val));	
	else
	{
		mxDestroyArray(pTmp);
		mxSetCell(in,h*x+y,mxDuplicateArray(val));	
	}
}

double CMexAndCpp::GetMax(mxArray* mIn,int* pOutY,int* pOutX)
{
	int h=(int)mxGetM(mIn);
	int w=(int)mxGetN(mIn);	
	double max=-1000000;
	for(int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			double tmp=GetMA(mIn,y,x,h,w);
			if(tmp>max)
			{
				max=tmp;
				pOutY[0]=y;
				pOutX[0]=x;
			}
		}
	}
	return max;
}


double CMexAndCpp::GetMax(double* A,int nLen,int* index)
{
	double max=-1000000;
	for(int i=0;i<nLen;i++)
	{

		if(A[i]>max)
		{
			max=A[i];
			index[0]=i;
		}
	}

return max;
}

int CMexAndCpp::findClosest(double meanx,double meany,mxArray* ptsx,mxArray* ptsy)
{
	double mindistance=100000;
	int len=mxGetN(ptsx);
	int minIdx=-1;
	for(int i=0;i<len;i++)
	{
		double tmp=sqrt(pow(meanx-GetMA(ptsx,0,i,1,len),2)+pow(meany-GetMA(ptsy,0,i,1,len),2));
		if(tmp<mindistance)
		{
			mindistance=tmp;
			minIdx=i;
		}
	}
	return minIdx;
}


int CMexAndCpp::findClosest(double meanx,double meany,double* ptsx,double* ptsy,int nLen)
{
	double mindistance=100000;
	
	int minIdx=-1;
	for(int i=0;i<nLen;i++)
	{
		double tmp=sqrt(pow(meanx-ptsx[i],2)+pow(meany-ptsy[i],2));
		if(tmp<mindistance)
		{
			mindistance=tmp;
			minIdx=i;
		}
	}
	return minIdx;
}


double CMexAndCpp::GetSum(mxArray* mIn)
{
	int h=mxGetM(mIn);
	int w=mxGetN(mIn);
	double total=0;
	for(int y=0;y<h;y++)
	{
		for(int x=0;x<w;x++)
		{
			total+=GetMA(mIn,y,x);	
		}
	}
	return total;
}

double CMexAndCpp::GetSum(double* pIn,int nLen)
{
	double total=0;
	for(int i=0;i<nLen;i++)
	{
		total+=pIn[i];	
	}
	return total;
}