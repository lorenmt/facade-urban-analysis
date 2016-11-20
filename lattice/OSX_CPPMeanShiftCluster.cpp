// CPPMeanShiftCluster.cpp : mex-function interface implentation file


#include "mex.h"

#include "MexAndCpp.h"
#include <vector>
#include <iostream>
#include <math.h>



using namespace std ;

typedef struct
{
	double* pData;
}DATA;



typedef vector<DATA> LIST;
typedef vector<int> intList;
typedef vector<double*> dbpList;
typedef vector<int*> intpList;



double AtoBNorm(double* A,double* B,int size);
void dbpPush(dbpList* list,double* data,int length);
void intpPush(intpList* list,int* data,int length);

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray	*in[])
{  	
	// TODO:  add your function code here


	const mxArray* mxDataPts=in[0];

	double bandWidth=mxGetScalar(in[1]);


	

	int numDim=mxGetM(mxDataPts);
	int numPts=mxGetN(mxDataPts);
	int numClust=-1;

	double* dbDataPts=(double*)mxMalloc(sizeof(double)*numDim*numPts);
	for(int y=0;y<numDim;y++)
	{
		for(int x=0;x<numPts;x++)
		{
			dbDataPts[y*numPts+x]=CMexAndCpp::GetMA(mxDataPts,y,x,numDim,numPts);
		}
	}


	int* initPtInds=(int*)mxMalloc(sizeof(int)*numPts);
	
	

	
	char* beenVisitedFlag=(char*)mxMalloc(sizeof(char)*numPts);
	dbpList clustCent;
	intpList clusterVotes;
	



	double* myMean=(double*)mxMalloc(sizeof(double)*numDim);
	double* myOldMean=(double*)mxMalloc(sizeof(double)*numDim);
	double* tmpSum=(double*)mxMalloc(sizeof(double)*numDim);
	int* thisClusterVotes=(int*)mxMalloc(sizeof(int)*numPts);
	double bandSq=pow(bandWidth,2);
	double stopThresh=1e-3*bandWidth;

	do
	{
		numClust=-1;
		bandSq=pow(bandWidth,2);
		stopThresh=1e-3*bandWidth;

		for(int i=0;i<(int)clustCent.size();i++)
		{
			mxFree(clustCent.at(i));
		}
		clustCent.clear();

		for(int i=0;i<(int)clusterVotes.size();i++)
		{
			mxFree(clusterVotes.at(i));
		}
		clusterVotes.clear();
		for(int k=0;k<numPts;k++)
		{
			initPtInds[k]=k;
		}
		int numInitPts=numPts;
		for(int k=0;k<numDim;k++)
		{
			myMean[k]=0;
			myOldMean[k]=0;
			tmpSum[k]=0;
		}
		//myMembers????

		for(int k=0;k<numPts;k++)
		{
			thisClusterVotes[k]=0;
			beenVisitedFlag[k]=0;
		}


		while(numInitPts)
		{
			//pick a random seed point
			int tempInd = 0;//((double) rand() / (double) RAND_MAX) * (numInitPts-1) ;
			//use this point as start of mean
			int stInd=initPtInds[tempInd];


			for(int k=0;k<numPts;k++)
			{
				thisClusterVotes[k]=0;
			}
			//intilize mean to this points location
			for(int k=0;k<numDim;k++)
			{
				myMean[k]=dbDataPts[k*numPts+stInd];
			}		
			intList myMembers;// points that will get added to this cluster                 
			myMembers.clear();


			while(1)
			{
				//dist squared from mean to all points still active
				int nCnt=0;
				for(int x=0;x<numPts;x++)
				{
					double sum=0;				
					for(int y=0;y<numDim;y++)
					{
						sum+=pow(myMean[y]-dbDataPts[y*numPts+x],2);
					}
					//sqDistToAll[x]=sum;
					if(sum<bandSq)
					{
						thisClusterVotes[x]++;
						nCnt++;
						myMembers.push_back(x);//add any point within bandWidth to the cluster
						beenVisitedFlag[x]=1;//mark that these points have been visited
						for(int y=0;y<numDim;y++)
						{
							tmpSum[y]+=dbDataPts[y*numPts+x];
						}					
					}
				}
				//save the old mean
				for(int k=0;k<numDim;k++)
				{
					myOldMean[k]=myMean[k];
				}		
				//compute the new mean
				if(nCnt!=0)
				{
					for(int k=0;k<numDim;k++)
					{
						myMean[k]=tmpSum[k]/nCnt;

					}
				}
				//init tmpSum
				for(int k=0;k<numDim;k++)
				{
					//init tmpSum
					tmpSum[k]=0;
				}

				// if mean doesn't move much stop this cluster 
				if (AtoBNorm(myMean,myOldMean,numDim) <stopThresh)
				{
					double mergeWith=-1;
					for(int cN=0;cN<numClust;cN++)
					{
						double* pDat=clustCent.at(cN);
						if( AtoBNorm(pDat,myMean,numDim) <bandWidth/2)
						{
							mergeWith=cN;
							break;
						}
					}
					if(mergeWith>=0)
					{
						double* pDat=clustCent.at(mergeWith);
						for(int t=0;t<numDim;t++)
						{
							pDat[t]=0.5*(pDat[t]+myMean[t]);
						}
						//clusterVotes[mergeWith]+=thisClusterVotes;
						int* pVotes=clusterVotes.at(mergeWith);
						for(int k=0;k<numPts;k++)
						{
							pVotes[k]+=thisClusterVotes[k];
						}
					}
					else
					{
						numClust++;
						dbpPush(&clustCent,myMean,numDim);
						intpPush(&clusterVotes,thisClusterVotes,numPts);
					}
					break;
				}						
			}
			//we can initialize with any of the points not yet visited
			numInitPts=0;
			for(int k=0;k<numPts;k++)
			{
				if(beenVisitedFlag[k]==0)
				{
					initPtInds[numInitPts]=k;
					numInitPts++;
				}
			}
		}
		
		bandWidth*=1.1;
		break;
	}
	while(numClust> numPts/3);

	//now record membership according to the maximum votes for cluster id.
	int nTmp=(int)clustCent.size();
	out[0]=mxCreateDoubleMatrix(numDim,nTmp,mxREAL);
	for(int x=0;x<nTmp;x++)
	{
		double* pVal=clustCent.at(x);
		for(int y=0;y<numDim;y++)
		{			
			CMexAndCpp::SetMA(out[0],y,x,pVal[y],numDim,nTmp);
		}
	}

	out[1]=mxCreateDoubleMatrix(1,numPts,mxREAL);
	for(int x=0;x<numPts;x++)
	{	
		int max=0;
		int maxidx=-1;
		for(int mm=0;mm<(int)clusterVotes.size();mm++)
		{
			int* tmp=clusterVotes.at(mm);
			if(tmp[x]>max)
			{
				maxidx=mm;
				max=tmp[x];
			}
		}
		CMexAndCpp::SetMA(out[1],0,x,maxidx+1,1,numPts);
	}
	out[2]=mxCreateDoubleMatrix(1,1,mxREAL);
	CMexAndCpp::SetMA(out[2],0,0,bandWidth);
	//free all memories....


	for(int i=0;i<(int)clustCent.size();i++)
	{
		mxFree(clustCent.at(i));
	}
	clustCent.clear();

	for(int i=0;i<(int)clusterVotes.size();i++)
	{
		mxFree(clusterVotes.at(i));
	}
	clusterVotes.clear();

	mxFree(myMean);
	mxFree(myOldMean);
	mxFree(initPtInds);
	mxFree(beenVisitedFlag);
	mxFree(tmpSum);
	mxFree(thisClusterVotes);
	mxFree(dbDataPts);

	return;
}

void dbpPush(dbpList* list,double* data,int length)
{
	double* tmp=(double*)mxMalloc(sizeof(double)*length);
	for(int i=0;i<length;i++)
	{
		tmp[i]=data[i];
	}
	list->push_back(tmp);
}


void intpPush(intpList* list,int* data,int length)
{
	int* tmp=(int*)mxMalloc(sizeof(int)*length);
	for(int i=0;i<length;i++)
	{
		tmp[i]=data[i];
	}
	list->push_back(tmp);
}

double AtoBNorm(double* A,double* B,int size)
{
	double retval=0;
	for(int k=0;k<size;k++)
	{
		retval+=pow(A[k]-B[k],2);
	}
	retval=sqrt(retval);
	return retval;
}
