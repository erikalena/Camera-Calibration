# Camera-Calibration

This project implements [Zhang's procedure ](https://ieeexplore.ieee.org/document/888718) for camera calibration.

Camera calibration is an important procedure in Computer Vision; it aims to extract information from 2D images and use it to estimate the parameters of the camera model.
The main purpose is to estimate perspective projection matrix which provides a direct map between points in the image frame and those in the 3D camera frame.

It is split into three parts:
* implementation of Zhang method in order to find the intrinsic and extrinsic camera parameters;
* a second part in which the same steps are repeated on different images captured using a smartphone camera;
* a third part where compensation for radial distortion is added to see if there is an improvement in global reprojection error.

The whole project has been developed using Matlab. 
For each of the mentioned sections a Matlab Live Script is provided, which summarizes the steps done and shows how
to use the code functions which can be found in */utils* folder.
In order, the documents are: ZhangMethod.pdf, CalibratingPhoneCamera.pdf and CompensatingRadialDistortion.pdf.

