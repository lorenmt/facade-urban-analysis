function OpenCVCompile()
OCVRoot = 'D:\Program\OpenCV2\opencv\build\include';
LibRoot = 'D:\Program\OpenCV2\opencv\build\x86\vc12';
IPath = ['-I', fullfile(OCVRoot)];
OPENCVPath = ['-I',fullfile(OCVRoot,'opencv')];
OPENCV2Path = ['-I',fullfile(OCVRoot,'opencv2')];

lib1 = fullfile(LibRoot,'lib\opencv_highgui2410.lib');
lib2 = fullfile(LibRoot,'lib\opencv_core2410.lib');
lib3 = fullfile(LibRoot,'lib\opencv_legacy2410.lib');
lib4 = fullfile(LibRoot,'lib\opencv_imgproc2410.lib');
lib5 = fullfile(LibRoot,'lib\opencv_calib3d2410.lib');
lib7 = fullfile(LibRoot,'lib\opencv_nonfree2410.lib');
lib8 = fullfile(LibRoot,'lib\opencv_features2d2410.lib');
lib9 = fullfile(LibRoot,'lib\opencv_flann2410.lib');

mex('MeXExtractPatch.cpp')
mex('-c', 'MexAndCpp.cpp')
mex('-c', IPath, 'MatlabToOpenCV.cpp')
mex('ExtractKLT.cpp', IPath, lib1, lib2, lib4);
mex('FindHomography.cpp', IPath, lib5, lib4, lib1, lib2, lib3);
mex('ExtractSURF.cpp', IPath, lib7, lib8, lib9, lib4, lib1, lib2, lib3, lib5)
mex('OSX_CPPMeanShiftCluster.cpp', 'MexAndCpp.obj')
mex('TemplateMatching.cpp', IPath, lib4, lib1, lib2, lib3, lib5, 'MexAndCpp.obj', 'MatlabToOpenCV.obj')

end

