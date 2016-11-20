% Building Facade-based City Classification from Aerial View Images
% Author: Shikun Liu
% Date: May 16, 2016

=====================folders======================
facades - pre-detected facades in each city-pic_id; mat file contains all the information on each detected facades using JC's alogrithm
more details: J. Liu and Y. Liu, 'Local Regularity-driven City-scale Facade Detection from Aerial Images', Computer Vision and Pattern Recognition 

functions - all related matlab functions in main.m

poly - functions for ploting facades area

drtoolbox - toolbox for dimension reduction evaluation

lattice - finding lattices in detected facades
more detials: M. Park, K. Brocklehurst, R.T. Collins and Y. Liu, 'Translation-Symmetry-based Perceptual Grouping with Applications to Urban Scenes', Asian Conference on Computer Vision (ACCV) 2010

=====================main.m=========================
main.m  ***required Computer Vision ToolBox*****
-facades extraction: extract facades features by JC's algorithm
-facades input data rebuild: add other hand-crafted features: entropy, tile, etc...
-find top 2000 true/nontrue facade: rank all facades by facade area; tsne plot for visualization; city-classification using JC's raw detected facade
-feature visualization: 3-feature dimension visualization
-binary classification: use SVM to classify true and nontrue facades; ROC curve for visualization
-multiclass classification: city classification for true facades ranked by area
-ground truth facade city classification: city classification using hand-labeled ground truth facades
-3-city visualization: cityclassificaiton visualization

=======================================================
To prettify the results: please install **Charter** font
more information please see the attached paper and its supplement..
Enjoy.

-SK <sk.lorenmt@gmail.com>