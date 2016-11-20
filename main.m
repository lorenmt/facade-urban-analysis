% Building Facade-based City Classification from Aerial View Images
% Author: Shikun Liu
% Date: May 16, 2016

%% Start Clean
clc
clear
close all


%% Facades Extraction
addpath('functions', 'lattice',genpath('vlfeat'),genpath('drtoolbox'))
facadepath = 'facades/%s/facades_%s_%08d.mat';
truelabelpath = 'facades/%s/%s_%03d/truelabel.mat';
imageinfopath = 'facades/%s/%s_%03d/info.mat';

% Define the top 20 choices for aerial images in each city
sfids   = [  2,  11,  14,  15,  17,  18,  20,  24,  40,  43, ...
            47,  57,  60,  79,  82,  86,  87,  95,  97, 100];
nycids  = [  0,   1,   2,   6,  41,  64,  76,  79,  83,  84, ...
            85, 101, 104, 106, 109, 115, 164, 172, 320, 322];
romeids = [444, 448, 449, 450 ,451, 454, 455, 462, 464, 465, ...
           475, 476, 755, 758, 781, 785, 790, 807, 808, 814];

patch = [sfids; nycids; romeids];
clear sfids nycids romeids

% Extract facades and its information (I' have did that for you.)
% for cityID = 1:3
%     if cityID == 1
%         city = 'sf';
%     end
%     if cityID == 2
%         city = 'nyc';
%     end
%     if cityID == 3
%         city = 'rome';
%     end
%     for imID = 1:20
%         if ~exist(sprintf(facadepath, city,city, patch(cityID, imID)),'file')
%             fprintf('Detecting facades on image %03d in city %s...\n', patch(cityID, imID), city);
%             facades = DetectionMain(city, patch(cityID, imID));
%             generate_patches(city, patch(cityID, imID), facades);
%             parsave(sprintf(facadepath, city, city, patch(cityID, imID)), facades);
%             fprintf('Detection image %03d in city %s completed \n\n', patch(cityID, imID), city);
%         else
%             fprintf('Facades on image %03d in city %s has already been detected.\n', patch(cityID, imID), city);
%             continue
%         end
%     end
%     fprintf('All images in %s detection completed.\n\n', city);
% end


%% Facades Input Data Rebuild
% Compute entropy and lattice features (I have did that for you..)
% TotalTime = 0;
% for cityID = 1:3
%     if cityID == 1
%         city = 'sf';
%     end
%     if cityID == 2
%         city = 'nyc';
%     end
%     if cityID == 3
%         city = 'rome';
%     end
%     
%     for imID = 12:20
%         D = dir([sprintf('facades/%s/%s_%03d', city, city, patch(cityID, imID)), '\*.jpg']);
%         PatchNum = length(D(not([D.isdir])));
%         Info = zeros(PatchNum, 7);
%         for i = 1: PatchNum
%             tic;
%             impath = sprintf('facades/%s/%s_%03d/%d.jpg', city, city, patch(cityID, imID), i);
%             im = imread(impath);            
%             [Ascore, Tile, occupancy] = LatticeDetection(impath, i);            
%             imblur = imgaussfilt(im,8);
%             J = entropy(imblur);
%             Info(i,1) = J;  % Entropy
%             Info(i,2) = Ascore;
%             Info(i,3) = Tile; 
%             Info(i,4) = occupancy;
%             Info(i,5) = cityID;
%             Info(i,6) = patch(cityID, imID);
%             Info(i,7) = i;
%             t = toc;
%             TotalTime = TotalTime + t;
%             fprintf('* Finished: %f second on id:%03d, patch:%03d.\n', TotalTime, patch(cityID, imID), i); 
%             fprintf('*******************************************************\n\n'); 
%         end
%     parsave(sprintf(imageinfopath, city, city, patch(cityID, imID)), Info);    
%     end
% end

% Combine all the features and features info to our input dataset
for cityID = 1:3
    if cityID == 1
        city = 'sf';
    end
    if cityID == 2
        city = 'nyc';
    end
    if cityID == 3
        city = 'rome';
    end
    for imID = 1:20
        load(sprintf(facadepath, city, city, patch(cityID, imID)));
        load(sprintf(truelabelpath, city, city, patch(cityID, imID)));
        load(sprintf(imageinfopath, city, city, patch(cityID, imID)));

        % Construct facades data: 
        % score|area|entropy|arearatio|cityid|imageid|number|-|truelabel|
        facades = struct2cell(facades);  
        facadesmat(:,1) = cell2mat(facades(1,:))'; 
        facadesmat(:,2) = cell2mat(facades(7,:))';
        facadesmat(:,3:9) = Info;
     
        if imID == 1 && cityID == 1
            facadesdata  = facadesmat;
            facadeslabel = TrueLabel;
        else
            facadesdata  = [facadesdata; facadesmat];
            facadeslabel = [facadeslabel; TrueLabel];
        end
        clear facadesmat
    end
end


%% Find top 2000 true/nontrue facade
[index1, ~] = find(facadeslabel(:) == 1);
[index2, ~] = find(facadeslabel(:) == 0);

alltrue = facadesdata(index1,:);
allfalse = facadesdata(index2, :);
    
alltrue = sortrows(alltrue,-2);
allfalse = sortrows(allfalse,-2);

N = [500, 800, 1000, 2000, 3000, 4000]; Dimension = 6;
FacadesLabel = [zeros(size(facadesdata, 1),1), facadesdata(:,7:9)];

% tSNE plot fot true and nontrue plots
[mappedTrue,~] = compute_mapping(alltrue(1:500,1:6),'tSNE');
[mappedFalse,~] = compute_mapping(allfalse(1:500,1:6),'tSNE');

scatter(mappedTrue(:,1),mappedTrue(:,2), 'filled', 'MarkerFaceColor','blue'); 
hold on;
scatter(mappedFalse(:,1),mappedFalse(:,2), 'filled', 'MarkerFaceColor','red');

legend('Facades', 'Non-Facades')

set(gca,'fontsize', 12)
set(gca,'fontname','Charter')


for i = 2:6
    clear FacadesInfo
    for k = 1:50
        % Random divide 80/20 ratio for traning and testing data
        [TrainMat, LabelTrain, TestMat, LabelTest] = RandomDivide([[ones(N(i),1);zeros(N(i),1)],[alltrue(1:N(i),:);allfalse(1:N(i),:)]]);

        % Normalize the features [0 to 1]
        for j = 1:Dimension
            maxfeature = max(TrainMat(:,j));          
            minfeature = min(TrainMat(:,j));
            range = maxfeature - minfeature;
            TrainMat(:,j) = (TrainMat(:,j) - minfeature)./range;  
            TestMat(:,j) = (TestMat(:,j) - minfeature)./range;  
        end

        % Extract feature infomation
        FacadesInfo(:,:) = TestMat(:,7:9);
        TrainMat = TrainMat(:, 1:Dimension);
        TestMat = TestMat(:, 1:Dimension);    

        % Training with SVM
        [CMTrain, CMTest, LT] = SVM(TrainMat,TestMat, LabelTrain, LabelTest);

        AccuracyTrain(k,i) = trace(CMTrain)/size(TrainMat,1);
        AccuracyTest(k,i)  = trace(CMTest)/size(TestMat,1);
        RecallTrain(k,i) =  CMTrain(2,2)/sum(CMTrain(:,2));
        RecallTest(k,i) =  CMTest(2,2)/sum(CMTest(:,2));
        PrecisionTrain(k,i) = CMTrain(2,2)/sum(CMTrain(2,:));
        PrecisionTest(k,i) = CMTest(2,2)/sum(CMTest(2,:)); 

        % Mark true facades
        DetectedLabels = find(LT == 1);
        [~,TrueLabels] = ismember(FacadesInfo(DetectedLabels,:),FacadesLabel(:,2:4),'rows');
        FacadesLabel(TrueLabels,1) = FacadesLabel(TrueLabels,1) + 1;
    end

    % Find highest ranking facades
    SFLabels = FacadesLabel(:,2) == 1;
    SFLabels = sortrows(FacadesLabel(SFLabels,:),-1);

    NYCLabels = FacadesLabel(:,2) == 2;
    NYCLabels = sortrows(FacadesLabel(NYCLabels,:),-1);

    ROMELabels = FacadesLabel(:,2) == 3;
    ROMELabels = sortrows(FacadesLabel(ROMELabels,:),-1);

    truefacadepath = 'facades/%s/%s_%03d/%d.jpg';
    citypath = 'cityjc/%s';

    for z = 1:100*i
        sfim = imread(sprintf(truefacadepath,'sf','sf',SFLabels(z,3),SFLabels(z,4)));
        nycim = imread(sprintf(truefacadepath,'nyc','nyc',NYCLabels(z,3),NYCLabels(z,4)));
        romeim = imread(sprintf(truefacadepath,'rome','rome',ROMELabels(z,3),ROMELabels(z,4)));

        imwrite(sfim, fullfile(sprintf(citypath, 'sf'), sprintf('%d.png',z)));
        imwrite(nycim, fullfile(sprintf(citypath, 'nyc'), sprintf('%d.png',z)));
        imwrite(romeim, fullfile(sprintf(citypath, 'rome'), sprintf('%d.png',z)));
    end
    
    % JC raw algorithms
    setDir  = 'cityjc';
    imgSets = imageSet(setDir,'recursive');
    [trainingSets,testSets] = partition(imgSets,0.6,'randomize');

    bag = bagOfFeatures(trainingSets);
    classifier = trainImageCategoryClassifier(trainingSets,bag);
    confMatrix{1,i} = evaluate(classifier, testSets);
    confMatrix{2,i} = evaluate(classifier, trainingSets);
end

for i = 1:6
    PTestNYC(i) = confMatrix{1,i}(1,1) / sum(confMatrix{1,i}(:,1));
    RTestNYC(i) = confMatrix{1,i}(1,1);
end

%% Feature Visualization

index = facadesdata(:,4) > 1;
facadesdata(index, 4) = 1;

[index1, ~] = find(facadeslabel(:) == 1);
[index2, ~] = find(facadeslabel(:) == 0);

alltrue = facadesdata(index1,:);
allfalse = facadesdata(index2, :);
    
alltrue = sortrows(alltrue,-2);
allfalse = sortrows(allfalse,-2);

M = 500;

% Normalize the features [0 to 1]
for j = 1:6
    maxfeature = max(alltrue(:,j));          
    minfeature = min(alltrue(:,j));
    range = maxfeature - minfeature;
    alltrue(:,j) = (alltrue(:,j) - minfeature)./range;  
end

for j = 1:6
    maxfeature = max(allfalse(:,j));          
    minfeature = min(allfalse(:,j));
    range = maxfeature - minfeature;
    allfalse(:,j) = (allfalse(:,j) - minfeature)./range;  
end

[TrainMat, LabelTrain, TestMat, LabelTest] = RandomDivide([[ones(M,1);zeros(M,1)],[alltrue(1:M,:);allfalse(1:M,:)]]);

Labels{1} = 'Facade Probability';
Labels{2} = 'Area';
Labels{3} = 'Entropy';
Labels{4} = 'A-Score';
Labels{5} = 'Texel';
Labels{6} = 'Occupancy';

C1 = 4; C2 = 5; C3 = 6;

x1 = TrainMat(LabelTrain == 1,C1);
y1 = TrainMat(LabelTrain == 1,C2);
z1 = TrainMat(LabelTrain == 1,C3);
scatter3(x1,y1,z1,'o','MarkerEdgeColor','blue')
hold on;

x1 = TestMat(LabelTest == 1,C1);
y1 = TestMat(LabelTest == 1,C2);
z1 = TestMat(LabelTest == 1,C3);
scatter3(x1,y1,z1,'filled','MarkerFaceColor','blue')
hold on;

x1 = TrainMat(LabelTrain == 0,C1);
y1 = TrainMat(LabelTrain == 0,C2);
z1 = TrainMat(LabelTrain == 0,C3);
scatter3(x1,y1,z1,'o','MarkerEdgeColor','red')
hold on;

x1 = TestMat(LabelTest == 0,C1);
y1 = TestMat(LabelTest == 0,C2);
z1 = TestMat(LabelTest == 0,C3);
scatter3(x1,y1,z1,'filled','MarkerFaceColor','red')
hold on;

axis([0 1 0 1 0 1])
set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

hold off

xlabel(Labels{C1})
ylabel(Labels{C2})
zlabel(Labels{C3})

legend({'Training Data (Facade)', 'Testing Data (Facade)','Training Data (Non-Facade)', 'Testing Data (Non-Facade)'});
title('Facade/Non-Facade Classification (1000 points)')    
    

%% Binary Classiciation (True/False) Facades
Iterations = 10;      % Total iterations time
Dimension =  6;        % Dimension of the features
AccuracyTrain = zeros(3, Iterations);  
AccuracyTest  = zeros(3, Iterations); 
PrecisionTrain = zeros(3, Iterations); 
PrecisionTest  = zeros(3, Iterations);
FacadesLabel = [zeros(size(facadesdata, 1),1), facadesdata(:,7:9)];
for i = 1:Iterations
    % Random divide 80/20 ratio for traning and testing data
    [TrainMat, LabelTrain, TestMat, LabelTest] = RandomDivide([facadeslabel,facadesdata]);
    
    % Normalize the features [0 to 1]
    for j = 1:Dimension
        maxfeature = max(TrainMat(:,j));          
        minfeature = min(TrainMat(:,j));
        range = maxfeature - minfeature;
        TrainMat(:,j) = (TrainMat(:,j) - minfeature)./range;  
        TestMat(:,j) = (TestMat(:,j) - minfeature)./range;  
    end
    
    [~, AVR] = RankingFeat(TrainMat, LabelTrain);
    
    % Extract feature infomation
    FacadesInfo(:,:) = TestMat(:,7:9);
    TrainMat = TrainMat(:, 1:Dimension);
    TestMat = TestMat(:, 1:Dimension);    
    
    % Training with SVM
    [CMTrain, CMTest, LT] = SVM(TrainMat,TestMat, LabelTrain, LabelTest);
    AccuracyTrain(1,i) = trace(CMTrain)/size(TrainMat,1);
    AccuracyTest(1,i)  = trace(CMTest)/size(TestMat,1);
    PrecisionTrain(1,i) = CMTrain(2,2)/sum(CMTrain(2,:));
    PrecisionTest(1,i) = CMTest(2,2)/sum(CMTest(2,:));    

    % Training with LSE
    [CMTrain, CMTest] = LSE(TrainMat,TestMat, LabelTrain, LabelTest);
    AccuracyTrain(2,i) = trace(CMTrain)/size(TrainMat,1);
    AccuracyTest(2,i)  = trace(CMTest)/size(TestMat,1);
    PrecisionTrain(2,i) = CMTrain(2,2)/sum(CMTrain(2,:));
    PrecisionTest(2,i) = CMTest(2,2)/sum(CMTest(2,:));
  
    
    % Training with DT
    [CMTrain, CMTest] = DT(TrainMat,TestMat, LabelTrain, LabelTest);
    AccuracyTrain(3,i) = trace(CMTrain)/size(TrainMat,1);
    AccuracyTest(3,i)  = trace(CMTest)/size(TestMat,1);
    PrecisionTrain(3,i) = CMTrain(2,2)/sum(CMTrain(2,:));
    PrecisionTest(3,i) = CMTest(2,2)/sum(CMTest(2,:));   
    
    % Record all detected facades
    DetectedLabels = find(LT == 1);
    [~,TrueLabels] = ismember(FacadesInfo(DetectedLabels,:),FacadesLabel(:,2:4),'rows');
    FacadesLabel(TrueLabels,1) = FacadesLabel(TrueLabels,1) + 1;
end

for j = 1:6
    maxfeature = max(facadesdata(:,j));          
    minfeature = min(facadesdata(:,j));
    range = maxfeature - minfeature;
    NFacade(:,j) = (facadesdata(:,j) - minfeature)./range;  
end


% ROC Curve
% Training
x = 0:0.001:1;
y1 =  0.9996817 * x.^0.2862557; % SVM
y2 =  0.9989687 * x.^0.3202113; % LSE
y3 =  2.391853 + (-2.391853)./((1+(x./342783200).^0.017307)); % DT

plot(x, y1, x, y2, x, y3)
legend('SVM','LSE','DT')
axis([0 1 0 1])
set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

% Testing
z1 =  0.9999957 * x.^0.2891528; % SVM
z2 =  0.9990223 * x.^0.3671623; % LSE
z3 =  1.001515 * x.^0.3080732; % DT

plot(x, z1, x, z2, x, z3)
legend('SVM','LSE','DT')
axis([0 1 0 1])
set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

%% Multiclass Classification
truefacadepath = 'facades/%s/%s_%03d/%d.jpg';
citypath = 'city2/%s';

% Find highest ranking facades
SFLabels = FacadesLabel(:,2) == 1;
SFLabels = sortrows(FacadesLabel(SFLabels,:),-1);

NYCLabels = FacadesLabel(:,2) == 2;
NYCLabels = sortrows(FacadesLabel(NYCLabels,:),-1);

ROMELabels = FacadesLabel(:,2) == 3;
ROMELabels = sortrows(FacadesLabel(ROMELabels,:),-1);

for i = 1:400
    sfim = imread(sprintf(truefacadepath,'sf','sf',SFLabels(i,3),SFLabels(i,4)));
    nycim = imread(sprintf(truefacadepath,'nyc','nyc',NYCLabels(i,3),NYCLabels(i,4)));
    romeim = imread(sprintf(truefacadepath,'rome','rome',ROMELabels(i,3),ROMELabels(i,4)));
    
    imwrite(sfim, fullfile(sprintf(citypath, 'sf'), sprintf('%d.png',i)));
    imwrite(nycim, fullfile(sprintf(citypath, 'nyc'), sprintf('%d.png',i)));
    imwrite(romeim, fullfile(sprintf(citypath, 'rome'), sprintf('%d.png',i)));
end

% Unsupervised learning
idx = kmeans(facadesdata(:,4:6),2);
idx = idx - ones(length(idx),1) ;

CM = zeros(2,2);
for i = 1:length(idx)
    CM(idx(i)+1,facadeslabel(i)+1) = CM(idx(i)+1,facadeslabel(i)+1) + 1;
end


N = 100;

SFLabelsU = facadesdata(:,7) == 1;
SFLabelsT = facadeslabel(SFLabelsU);
SFLabelsD = idx(SFLabelsU);
[~, index] = sortrows(facadesdata(SFLabelsU,:),-6);
SFLabelsT = SFLabelsT(index);
SFLabelsD = SFLabelsD(index);


NYCLabelsU = facadesdata(:,7) == 2;
NYCLabelsT = facadeslabel(NYCLabelsU);
NYCLabelsD = idx(NYCLabelsU);
[~, index] = sortrows(facadesdata(NYCLabelsU,:),-6);
NYCLabelsT = NYCLabelsT(index);
NYCLabelsD = NYCLabelsD(index);


ROMELabelsU = facadesdata(:,7) == 3;
ROMELabelsT = facadeslabel(ROMELabelsU);
ROMELabelsD = idx(ROMELabelsU);
[~, index] = sortrows(facadesdata(ROMELabelsU,:),-6);
ROMELabelsT = ROMELabelsT(index);
AccuracyROME = sum(ROMELabelsT(1:N))/N;
ROMELabelsD = ROMELabelsD(index);

SFCount = 0; NYCCount = 0; ROMECount = 0;
for i = 1:N
    %sfim = imread(sprintf(truefacadepath,'sf','sf',SFLabelsU(i,8),SFLabelsU(i,9)));
    %nycim = imread(sprintf(truefacadepath,'nyc','nyc',NYCLabelsU(i,8),NYCLabelsU(i,9)));
    %romeim = imread(sprintf(truefacadepath,'rome','rome',ROMELabelsU(i,8),ROMELabelsU(i,9)));
    
    %imwrite(sfim, fullfile(sprintf(citypath, 'sf'), sprintf('%d.png',i)));
    %imwrite(nycim, fullfile(sprintf(citypath, 'nyc'), sprintf('%d.png',i)));
    %imwrite(romeim, fullfile(sprintf(citypath, 'rome'), sprintf('%d.png',i)));
    
    if SFLabelsD(i) == SFLabelsT(i)
        SFCount = SFCount + 1;
    end
    if ROMELabelsD(i) == ROMELabelsT(i)
        ROMECount = ROMECount + 1;
    end
    if NYCLabelsD(i) == NYCLabelsT(i)
        NYCCount = NYCCount + 1;
    end

end
AccuracySF = SFCount / N;
AccuracyNYC = NYCCount / N;
AccuracyROME = ROMECount / N;


% City classification
for i = 1:10
    setDir  = 'city2';
    imgSets = imageSet(setDir,'recursive');
    [trainingSets,testSets] = partition(imgSets,0.6,'randomize');

    bag = bagOfFeatures(trainingSets);
    classifier = trainImageCategoryClassifier(trainingSets,bag);
    confMatrix{1,i} = evaluate(classifier, testSets);
    confMatrix{2,i} = evaluate(classifier, trainingSets);
end

CMTrain = zeros(3,3);
CMTest = zeros(3,3);
for i = 1:10
    %CMTrain = confMatrix{2,i} + CMTrain;
    %CMTest = confMatrix{1,i} + CMTest;
    A(i) = confMatrix{1,i}(1,1);
end
std(A)

CMTrain = CMTrain./10;
CMTest = CMTest./10;

%% Gound Truth facade city classification
citypath2 = 'citygt/%s';

SFGTindex = find(alltrue(:,7) == 1);
SFGTindex2 = find(allfalse(:,7) == 1);

SFGTinfo = alltrue(SFGTindex,:);
SFGTinfo2= allfalse(SFGTindex2,:);

SFGTlabel= alltrue(SFGTindex);

NYCGTindex = find(alltrue(:,7) == 2);
NYCGTindex2 = find(allfalse(:,7) == 2);

NYCGTinfo = alltrue(NYCGTindex,:);
NYCGTinfo2= allfalse(NYCGTindex2,:);

ROMEGTindex = find(alltrue(:,7) == 3);
ROMEGTindex2 = find(allfalse(:,7) == 3);

ROMEGTinfo = alltrue(ROMEGTindex,:);
ROMEGTinfo2= allfalse(ROMEGTindex2,:);

ROMEGTlabel= alltrue(ROMEGTindex);

A = [1000, 500, 200, 100, 50, 20, 10];
for i = 1: 7
    a1(i) = length(find(SFGTinfo(:,2) > A(i))) / (length(find(SFGTinfo2(:,2) > A(i))) + length(find(SFGTinfo(:,2) > A(i))));
    a2(i) = length(find(NYCGTinfo(:,2) > A(i))) / (length(find(NYCGTinfo2(:,2) > A(i))) + length(find(NYCGTinfo(:,2) > A(i))));
    a3(i) = length(find(ROMEGTinfo(:,2) > A(i))) / (length(find(ROMEGTinfo2(:,2) > A(i))) + length(find(ROMEGTinfo(:,2) > A(i))));
end

for i = 1:7
    L1 = length(find(ROMEGTinfo(:,2) > A(i)));
    L2 = length(find(ROMEGTinfo2(:,2) > A(i)));
  % Random divide 80/20 ratio for traning and testing data
    [TrainMat, LabelTrain, TestMat, LabelTest] = RandomDivide([[ones(L1,1);zeros(L2,1)],[ROMEGTinfo(1:L1,:);ROMEGTinfo2(1:L2,:)]]);

    % Normalize the features [0 to 1]
    for j = 1:Dimension
        maxfeature = max(TrainMat(:,j));          
        minfeature = min(TrainMat(:,j));
        range = maxfeature - minfeature;
        TrainMat(:,j) = (TrainMat(:,j) - minfeature)./range;  
        TestMat(:,j) = (TestMat(:,j) - minfeature)./range;  
    end

    % Extract feature infomation
    TrainMat = TrainMat(:, 1:Dimension);
    TestMat = TestMat(:, 1:Dimension);    
    % Training with SVM

    [CMTrain, CMTest, LT] = SVM(TrainMat,TestMat, LabelTrain, LabelTest);

    a4(i) = CMTest(2,2)/sum(CMTest(2,:)); 
end

N = [500, 800, 1000, 2000, 3000, 4000];
for j = 1:6
    for i = 1:j*100
        sfim = imread(sprintf(truefacadepath,'sf','sf',SFGTinfo(i,8),SFGTinfo(i,9)));   
        imwrite(sfim, fullfile(sprintf(citypath2, 'sf'), sprintf('%d.png',i)));
    end

    for i = 1:j*100
        nycim = imread(sprintf(truefacadepath,'nyc','nyc',NYCGTinfo(i,8),NYCGTinfo(i,9)));   
        imwrite(nycim, fullfile(sprintf(citypath2, 'nyc'), sprintf('%d.png',i)));
    end

    for i = 1:j*100
        romeim = imread(sprintf(truefacadepath,'rome','rome',ROMEGTinfo(i,8),ROMEGTinfo(i,9)));   
        imwrite(romeim, fullfile(sprintf(citypath2, 'rome'), sprintf('%d.png',i)));
    end

    setDir  = 'citygt';
    imgSets = imageSet(setDir,'recursive');
    [trainingSets,testSets] = partition(imgSets,0.8,'randomize');

    bag = bagOfFeatures(trainingSets);
    classifier = trainImageCategoryClassifier(trainingSets,bag);
    confMatrix{1,j} = evaluate(classifier, testSets);
    confMatrix{2,j} = evaluate(classifier, trainingSets);   

    save('gtfacde', 'confMatrix');
end

for i = 1: length(confMatrix)
    ROCNYCTrain(1,i) = confMatrix{1,i}(1,1);
    ROCNYCTrain(2,i) = (confMatrix{1,i}(2,1)+confMatrix{1,i}(3,1))/2;
    ROCNYCTrain(3,i) = confMatrix{1,i}(1,1)/sum(confMatrix{1,i}(:,1));    
end

%% 3-city visualization
listing = dir('citygt/rome');
listing(1:2) = [];

for i = 1:length(listing)
    im = imread(sprintf('citygt/rome/%s', listing(i,1).name)); 
    fVROME(i,:) = encode(bag, im);
end

im = imread('nyc1.png');
fV(1,:) = encode(bag, im);
im = imread('rome1.png');
fV(2,:) = encode(bag, im);
im = imread('sf1.png');
fV(3,:) = encode(bag, im);

bar(fV(1,:))
axis([0 500 0 0.5])

I1 = 173; I2 = 87; I3= 317;

scatter3(fVNYC(:,I1), fVNYC(:,I2), fVNYC(:,I3),'filled') 
hold on
scatter3(fVSF(:,I1), fVSF(:,I2), fVSF(:,I3),'filled') 
hold on
scatter3(fVROME(:,I1), fVROME(:,I2), fVROME(:,I3),'filled') 

axis([0 0.3 0 0.1 0 0.25])


scatter(mappedNYC(:,1),mappedNYC(:,2), 'filled','MarkerFaceColor','red')
hold on;
scatter(mappedSF(:,1),mappedSF(:,2), 'filled','MarkerFaceColor','blue')
hold on;
scatter(mappedROME(:,1),mappedROME(:,2), 'filled','MarkerFaceColor','yellow')
hold on;

legend('NYC','SF','ROME')

set(gca,'fontsize', 12)
set(gca,'fontname','Charter')


% Finding most discriminative features
listing = dir('citygt/rome');
listing(1:2) = [];

for i = 1:length(listing)
    im = imread(sprintf('citygt/rome/%s', listing(i,1).name)); 
    [label(i), ROMEscore(i,:)] = predict(classifier, im);
end

scatter3(SFscore(:,1),SFscore(:,2), SFscore(:,3),'filled','MarkerFaceColor','blue') 
hold on; 
scatter3(NYCscore(:,1),NYCscore(:,2),NYCscore(:,3), 'filled','MarkerFaceColor','red') 
hold on; 
scatter3(ROMEscore(:,1),ROMEscore(:,2), ROMEscore(:,3),'filled','MarkerFaceColor','yellow') 
hold on;

legend('SF','NYC','ROME')

set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

axis([-1.5 0 -1.5 0 -1.5 0])

grid off
hold off

xlabel('NYC')
ylabel('ROME')
zlabel('SF')




