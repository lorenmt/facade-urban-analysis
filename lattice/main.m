% City Classification on Facades from High Resolution Aerial Images
% Author: Shikun Liu
% Date: May 16, 2016

%% Start Clean
clc
clear
close all


%% Facades Extraction
addpath('functions', 'lattice')
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
clear sfimages nycimages romeimages

% Extract facades and its information
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

% Build Lattice Network
OpenCVCompile;

% Compute entropy and area ratio
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
%     for imID = 1:20
%         D = dir([sprintf('facades/%s/%s_%03d', city, city, patch(cityID, imID)), '\*.jpg']);
%         PatchNum = length(D(not([D.isdir])));
%         Info = zeros(PatchNum, 2);
%         for i = 1: PatchNum
%             im = imread(sprintf('facades/%s/%s_%03d/%d.jpg', city, city, patch(cityID, imID), i));
%             imblur = imgaussfilt(im,8);
%             J = entropy(imblur);
%             Info(i,1) = J;
%             Info(i,2) = size(im,1)/size(im,2);
%             Info(i,3) = cityID;
%             Info(i,4) = patch(cityID, imID);
%             Info(i,5) = i;
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
        facadesmat(:,3:7) = Info;
     
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

%% Binary Classiciation (True/False) Facades
Iterations = 1;      % Total iterations time
Dimension =  4;        % Dimension of the features
AccuracyTrain = zeros(3, Iterations);  
AccuracyTest  = zeros(3, Iterations); 
PrecisionTrain = zeros(3, Iterations); 
PrecisionTest  = zeros(3, Iterations);
FacadesLabel = [zeros(size(facadesdata, 1),1), facadesdata(:,5:7)];
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
    
    % Extract feature infomation
    FacadesInfo(:,:) = TestMat(:,5:7);
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

% ROC Curve
% Training
x = 0:0.001:1;
y1 =  1.002175 * x.^0.3854964; % SVM
y2 =  1.001126 * x.^0.4279887; % LSE
y3 =  2.391853 + (-2.391853)./((1+(x./342783200).^0.017307)); % DT

plot(x, y1, x, y2, x, y3)
legend('SVM','LSE','DT')
axis([0 1 0 1])
set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

% Testing
z1 =  1.00138 * x.^0.4592002; % SVM
z2 =  0.9996168 * x.^0.5108678; % LSE
z3 =  1.003848 * x.^0.4921107; % DT

plot(x, z1, x, z2, x, z3)
legend('SVM','LSE','DT')
axis([0 1 0 1])
set(gca,'fontsize', 12)
set(gca,'fontname','Charter')

%% Multiclass Classification
truefacadepath = 'facades/%s/%s_%03d/%d.jpg';
citypath = 'city/%s';

% Find highest ranking facades
% SFLabels = FacadesLabel(:,2) == 1;
% SFLabels = sortrows(FacadesLabel(SFLabels,:),-1);
% 
% NYCLabels = FacadesLabel(:,2) == 2;
% NYCLabels = sortrows(FacadesLabel(NYCLabels,:),-1);
% 
% ROMELabels = FacadesLabel(:,2) == 3;
% ROMELabels = sortrows(FacadesLabel(ROMELabels,:),-1);
% 
% for i = 1:400
%     sfim = imread(sprintf(truefacadepath,'sf','sf',SFLabels(i,3),SFLabels(i,4)));
%     nycim = imread(sprintf(truefacadepath,'nyc','nyc',NYCLabels(i,3),NYCLabels(i,4)));
%     romeim = imread(sprintf(truefacadepath,'rome','rome',ROMELabels(i,3),ROMELabels(i,4)));
%     
%     imwrite(sfim, fullfile(sprintf(citypath, 'sf'), sprintf('%d.png',i)));
%     imwrite(nycim, fullfile(sprintf(citypath, 'nyc'), sprintf('%d.png',i)));
%     imwrite(romeim, fullfile(sprintf(citypath, 'rome'), sprintf('%d.png',i)));
% end
    
for i = 1:1
    setDir  = 'city';
    imgSets = imageSet(setDir,'recursive');
    [trainingSets,testSets] = partition(imgSets,0.8,'randomize');

    bag = bagOfFeatures(trainingSets);
    classifier = trainImageCategoryClassifier(trainingSets,bag);
    confMatrix{1,i} = evaluate(classifier, testSets);
    confMatrix{2,i} = evaluate(classifier, trainingSets);
end



