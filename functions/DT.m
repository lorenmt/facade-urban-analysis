function [CMTrain, CMTest] = DT(TrainMat,TestMat, LabelTrain, LabelTest)

B = TreeBagger(15, TrainMat, LabelTrain);
[labeltrain,~] = B.predict(TrainMat);
[labeltest,~] = B.predict(TestMat);
labeltrain = str2double(labeltrain);
labeltest = str2double(labeltest);

% Accuracy on Train Data
M = size(labeltrain,1);
CMTrain = zeros(2,2);
for j = 1:M
    CMTrain(labeltrain(j)+1,LabelTrain(j)+1) = CMTrain(labeltrain(j)+1,LabelTrain(j)+1)+1;   
end

% Accuracy on Test Data
N = size(labeltest,1); 
CMTest = zeros(2,2);
for j = 1:N
    CMTest(labeltest(j)+1,LabelTest(j)+1) = CMTest(labeltest(j)+1,LabelTest(j)+1)+1;   
end

