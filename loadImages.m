%--------------------------------------------------------------------------
% Daniel Burkat
% Plasma Processing Laboratory
% McGill Universtiy, 2015
% Started on       : December 16, 2015
% Last modified on : January 06, 2016
%--------------------------------------------------------------------------

%This function imports all the images in the targeted folder and returns
%them in a single array. The array was chosen to be of data type uint8
%because it makes it easy to put into a video with the implay() function.

function [images] = loadImages(target)
tic

    prefix = target;
    
    d = dir([target, '/*.png']);
    numFiles = length(d);


    %This while cleanes up the '._' files that are added by the OS due to
    %whatever reason they are needed. In this case they are garbage that
    %cause bugs to my code so I needed to filter them out.
    k = 1; 
    while k < numFiles
        temp = d(k).name;
        if temp(1) == '.'
            d(k) = [];
            numFiles = length(d);
        end
        k = k+1;
    end
    
    %import the first image to verify the dimensions for prealocation of 
    %a matrix.
    targetFile = strcat(prefix, '/', d(1).name);
    img = imread(targetFile);
    dim = size(img);
    
    images = zeros(dim(1), dim(2), numFiles);
    images = uint8(images);
    
    for i = 1:numFiles
        targetFile = strcat(prefix, '/',d(i).name);
        img = imread(targetFile);
        images(:,:,i) = img(:,:);
        
    end
fprintf('loadImages: ');    
toc
end
