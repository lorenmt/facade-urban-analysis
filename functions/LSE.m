function [CMTrain, CMTest] = LSE(TrainMat,TestMat, LabelTrain, LabelTest)
% data    = training data
% feature = number of feature
% k       = number of class

TrainSize = size(TrainMat,1); 
TestSize =  size(TestMat,1); 

% Two class, only need one discriminant line
for i = 1: TrainSize
    i1(i) = LabelTrain(i,1) == 0;
    i2(i) = LabelTrain(i,1) == 1;        
end
T(i1,1) = 1;  % First class maps to 1
T(i2,1) = -1; % Second class maps to -1

X1 = [ones(TrainSize,1),TrainMat]; % X = (1,x^T)^T
W = (X1'*X1)\(X1'*T);      % W = (X'X)^(-1)X'T

% Build Confusion Matrix
CMTrain = zeros(2,2);
d1 = zeros(TrainSize,1);
for i = 1:TrainSize
    d1(i) = X1(i,:)*W(:,1);
    if d1(i) > 0          % y_1(x) is the largest
        CMTrain(1,LabelTrain(i,1)+1) = CMTrain(1,LabelTrain(i,1)+1) + 1;
    else                  % y_2(x) is the largest
        CMTrain(2,LabelTrain(i,1)+1) = CMTrain(2,LabelTrain(i,1)+1) + 1;
    end
end

X2 = [ones(TestSize,1),TestMat]; % X = (1,x^T)^T
CMTest = zeros(2,2);
d2 = zeros(TestSize,1);
for i = 1:TestSize
    d2(i) = X2(i,:)*W(:,1);
    if d2(i) > 0          % y_1(x) is the largest
        CMTest(1,LabelTest(i,1)+1) = CMTest(1,LabelTest(i,1)+1) + 1;
    else                  % y_2(x) is the largest
        CMTest(2,LabelTest(i,1)+1) = CMTest(2,LabelTest(i,1)+1) + 1;
    end
end


