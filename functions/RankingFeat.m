function [TopFeatures, AVR] = RankingFeat(TrainMat, LabelTrain)
% input: TrainMat - a N x M matrix that contains the full list of features
%        of training data. N is the number of training samples and M is the
%        dimension of the feature. So each row of this matrix is the face
%        features of a single person.
%
%        LabelTrain - a N x 1 vector of the class labels of training data
%
% output: topfeatures - a K x 2 matrix that contains the information of the
%         top 1% features of the highest variance ratio. K is the number of
%         selected feature (K = ceil(M * 0.01)). The first column of this 
%         matrix is the index of the selected features in the original 
%         feature list. So the range of topfeatures(:,1) is between 1 and M.
%         The second column of this matrix is the variance ratio of the 
%         selected features.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dimension   = size(TrainMat,2);      % Dimension of the feature
Number      = size(TrainMat,1);      % Number of the feature
Class       = unique(LabelTrain);    % Class labels
ClassSize   = size(Class,1);         % Number of class
ClassLabel  = [1;find(diff(LabelTrain)>0);Number]; % Index of each class

AVR = zeros(Number,2); % Preallocate AVR
C   = {0,0,0};         % Preallocate C
MAX = max(max(TrainMat));

for i = 1:Dimension
    WithinVar = 0; WithinMean = MAX;
    for j = 1:ClassSize
        C{j} = TrainMat(ClassLabel(j):ClassLabel(j+1),i);
    end
    while j > 0
        WithinVar  = var(C{j}) + WithinVar;
        for k = 1:j-1
            WithinMean = min(abs(mean(C{j})-mean(C{j-k})),WithinMean);
        end
        j = j - 1;
    end
    BetweenVar = var(TrainMat(:,i));
    AVR(i,1) = i;
    AVR(i,2) = BetweenVar /(1/ClassSize * (WithinVar / WithinMean));
end

K   = ceil(Dimension * 0.01); % Number of 1% of total feature number
AVR = sortrows(AVR,-2);       % Rank Column 2 in a descending order  
TopFeatures = AVR(1:K,:);     % Pick Top K features


