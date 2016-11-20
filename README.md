## Building Facade-based City Classiﬁcation from Aerial-View Images

### Folders
1. facades - pre-detected facades in each city-pic_id; mat file contains all the information on each detected facades using JC's alogrithm. More details: [Local Regularity-driven City-scale Facade Detection from Aerial Images](https://pdfs.semanticscholar.org/f1e0/52914253ee5e7f60547bb4badcf819189024.pdf)

2. functions - all related matlab functions in main.m

3. poly - functions for ploting facades area

4. drtoolbox - toolbox for dimension reduction evaluation

5. lattice - finding lattices in detected facades. More details: [Translation-Symmetry-based Perceptual Grouping with Applications to Urban Scenes](http://vision.cse.psu.edu/publications/pdfs/2010park3.pdf)

### Main File *(required MATLAB Computer Vision ToolBox)*
1. facades extraction: extract facades features by JC's algorithm

2. facades input data rebuild: add other hand-crafted features: entropy, tile, etc...

3. find top 2000 true/nontrue facade: rank all facades by facade area; tsne plot for visualization; city-classification using JC's raw detected facade
4. feature visualization: 3-feature dimension visualization

5. binary classification: use SVM to classify true and nontrue facades; ROC curve for visualization

6. multiclass classification: city classification for true facades ranked by area

7. ground truth facade city classification: city classification using hand-labeled ground truth facades

Note: To prettify the results: please install **Charter** font.

More formation please see the attached paper and its supplement.

Enjoy. :D
