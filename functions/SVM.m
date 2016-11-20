function [CMTrain, CMTest, labeltest] = SVM(TrainMat,TestMat, LabelTrain, LabelTest)

% Training with SVM / Accuracy on Train and Test data
SVMModel = fitcsvm(TrainMat, LabelTrain ,'KernelFunction','rbf');
[labeltrain,~] = predict(SVMModel,TrainMat);
[labeltest ,~] = predict(SVMModel,TestMat);

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



