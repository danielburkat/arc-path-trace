%--------------------------------------------------------------------------
% Daniel Burkat
% Plasma Processing Laboratory
% McGill Universtiy, 2015
% Started on       : February 4 , 2016
% Last modified on : November 7 , 2017
%--------------------------------------------------------------------------

%This function will play a RGB movies from grayscale images at various speeds. 
%The dimension of IMAGES matrix must be rows*columns*numberOfImages. The 
%IMAGES and SPEED are passed to the function, then they are displayed 
%in the play movie function. The SPEED value means that 1 image will be 
%displayed for SPEED number of images.
%ARCPATHCELL is a cell matrix containing the data necessary to draw out the
%arcPaths
%ROI contains the regions of interest, use it to crop out the undesired
%black space in the images.


function todisplay = playArcPathEAF_V2(images, arcPathCell, speed, roi)

dim = size(images);
num = dim(3)/speed;

temp = uint8(0);
crop = roi.roiCrop;
todisplay(1:crop(4),1:crop(3),1:3, 1:num) = temp;

for i = 1:num
    
    subImage = images(crop(2):crop(2)+crop(4)-1 ,  crop(1):crop(1)+crop(3)-1 , i*speed);
    todisplay(:,:,:,i) = cat(3, subImage, subImage, subImage);
    arcPath1 = arcPathCell{i,1};
    arcPath2 = arcPathCell{i,2};
    
    %Draw out the arcPath on TODISPLAY
    for k = 1:length(arcPath1)
        todisplay(arcPath1(k,1), arcPath1(k,2),1,i) = 255;
        todisplay(arcPath1(k,1), arcPath1(k,2),2,i) = 0;
        todisplay(arcPath1(k,1), arcPath1(k,2),3,i) = 0;
    end
    
    for k = 1:length(arcPath2)
        todisplay(arcPath2(k,1), arcPath2(k,2),1,i) = 255;
        todisplay(arcPath2(k,1), arcPath2(k,2),2,i) = 0;
        todisplay(arcPath2(k,1), arcPath2(k,2),3,i) = 0;
    end
    
end

implay(todisplay);
end