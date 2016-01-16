__________
Quickstart

1. Extract code somewhere.

2. Install the vl_feat toolbox in your current path
   http://www.vlfeat.org/

3. If you don't have the videos already, run 'download_videos.m' (may take some time).

4. Run utility/compile.m to comile calcIIF.cpp and im2colstep.c. This compile files is tested with opencv3.0

5. "assignToBins1.c", "gradientMex.cpp", 'imResample.cpp' are from Pitor Dollar's toolbox. 
   If these compiled files do not work with your system, get it from
   http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html 


'run_tracker' without parameters to choose a video and test the tracker on it.

'run_lct2' is the interface for cvpr2013 benchmark

__________

The main interface function is 'run_tracker'. You can test several configurations (KCF,
DCF, MOSSE) by calling it with different commands:


 run_tracker
   Without any parameters, will ask you to choose a video, track using
   the Gaussian KCF on HOG, and show the results in an interactive
   figure. Press 'Esc' to stop the tracker early. You can navigate the
   video using the scrollbar at the bottom.

 run_tracker VIDEO
   Allows you to select a VIDEO by its name. 'all' will run all videos
   and show average statistics. 'choose' will select one interactively.



For the actual tracking code, check out the 'tracker_lct' function.


Though it's not required, the code will make use of the MATLAB Parallel Computing
Toolbox automatically if available.


__________
References

[1] J. F. Henriques, R. Caseiro, P. Martins, J. Batista, "High-Speed Tracking with
Kernelized Correlation Filters", TPAMI 2015.

[2] J. F. Henriques, R. Caseiro, P. Martins, J. Batista, "Exploiting the Circulant
Structure of Tracking-by-detection with Kernels", ECCV 2012.

[3] Y. Wu, J. Lim, M.-H. Yang, "Online Object Tracking: A Benchmark", CVPR 2013.
Website: http://visual-tracking.net/

[4] P. Dollar, "Piotr's Image and Video Matlab Toolbox (PMT)".
Website: http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html
