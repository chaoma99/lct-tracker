# Long-Term Correlation Tracking (CVPR 2015)

Chao Ma, Xiakang Yang, Chongyang Zhang, and Ming-Hsuan Yang

https://sites.google.com/site/chaoma99/cvpr15_tracking

Note that we made partial improvements in this version, where the randn fern classifier is replaced by an SVM classifier, and the color channels are quantized as four bits for feature.

##Quickstart

1. Unzip code or clone it from https://github.com/chaoma99/lct-tracker.git

2. Add the vl_feat toolbox in your current path
   http://www.vlfeat.org/

3. If you don't have the object tracking benchmark (OTB) dataset yet, run 'download_videos.m' (it will automatically download the OTB-100 sequences)

4. Run utility/compile.m to comile calcIIF.cpp and im2colstep.c. These files are tested with opencv3.0. Notice the compatibility issue if your opencv version is earlier than 3.0

5. The source files "assignToBins1.c", "gradientMex.cpp", 'imResample.cpp' are from Pitor Dollar's toolbox. 
   If the compiled files do not work on your system, get it from
   http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html 

##Introduction

The script 'run_tracker' without parameters is to choose a video and test the proposed tracker. The start interface is 'run_tracker'.

We also provide the interface 'run_lct2' to reproduce our results on OBT tracking benchmark

 run_tracker
   Without any parameters, will ask you to choose a video, and track the objects, 
   and show the results in an interactive figure. Press 'Esc' to stop the tracker early. 
   You can navigate the video using the scrollbar at the bottom.

 run_tracker VIDEO
   Allows you to select a VIDEO by its name. 'all' will run all videos
   and show average statistics. 'choose' will select one interactively.

For the actual tracking code, check out the 'tracker_lct' function.

Though it's not required, the code will make use of the MATLAB Parallel Computing
Toolbox automatically if available.

##References

[1] J. F. Henriques, R. Caseiro, P. Martins, J. Batista, "High-Speed Tracking with
Kernelized Correlation Filters", TPAMI 2015.

[2] J. F. Henriques, R. Caseiro, P. Martins, J. Batista, "Exploiting the Circulant
Structure of Tracking-by-detection with Kernels", ECCV 2012.

[3] Y. Wu, J. Lim, M.-H. Yang, "Online Object Tracking: A Benchmark", CVPR 2013.
Website: http://visual-tracking.net/

[4] P. Dollar, "Piotr's Image and Video Matlab Toolbox (PMT)".
Website: http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html
