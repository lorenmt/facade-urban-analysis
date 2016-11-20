/*
 *  MexAndCpp.h
 *
 *  Created by Minwoo Park on 2/13/07.
 *  Copyright 2007  All rights reserved.
 *
 *///
#include "mex.h"

typedef struct {
    double x;
    double y;
}PTR;



class CMexAndCpp 
{
public:
    CMexAndCpp(void);
    ~CMexAndCpp(void);
    static int findClosest(double meanx, double meany, mxArray* ptsx, mxArray* ptsy);
    static int findClosest(double meanx, double meany, double* ptsx, double* ptsy, int nLen);
    
    
    static void SetMC(mxArray *in, int y, int x, mxArray* val);
    static void SetMA(mxArray *in, int y, int x, double val);
    static void SetMA(const mxArray *in,int y,int x,int z,double val,int h,int w);
    static void SetMA(mxArray *in, int y, int x, double val, int h, int w);
    
    static mxArray* GetMC(const mxArray *in, int y, int x);
    static double GetMA(const mxArray *in, int y, int x);
    static double GetMA(const mxArray *in, int y, int x, int h, int w);
    static double GetMA(const mxArray *in,int y,int x,int z,int h,int w);
    static double GetMax(double* A, int nLen, int* index);
    static double GetMax(mxArray* mIn, int* pOutY, int* pOutX);
    static double GetSum(mxArray* mIn);
    static double GetSum(double* pIn, int nLen);
    static void Selfmultiplication(const double* A, double* C, int nLen);
    static void multiplication(const double* A, const double* B, double* C, int nLen);
    static mxArray* multiplication(const mxArray* A, const mxArray* B);
    static mxArray* division(mxArray* A, mxArray* B);
    static mxArray* division(mxArray* A, double B);
    static void division(double* A, double B, int nLen);
    static PTR ptminus(PTR pt1, PTR pt2){
        PTR ret;
        ret.x=pt1.x-pt2.x;
        ret.y=pt1.y-pt2.y;
        return ret;
    };
    static PTR ptplus(PTR pt1, PTR pt2){
        PTR ret;
        ret.x=pt1.x+pt2.x;
        ret.y=pt1.y+pt2.y;
        return ret;
    };
    //static PTR ptminus(PTR* pt1,PTR* pt2);
    //static PTR ptplus(PTR* pt1,PTR* pt2);
};