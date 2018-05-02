%Script to load all the necessary data and to use the findArcPathV1 and to
%vizualize the data.


%As an example the image data from two experiments are supplied in the 
%folders named 160309_12 (short arcs) and 160309_15 (long arcs).

%Location of images to load in the current folder
date = '160309';
index = '15';
targetDir = strcat(date, '_', index);
addpath(genpath(targetDir))

%Location of the information for the image regions of interest (ROI)
%The roi is a structure containing 4 fields. The valies in the field
%are 1x4 arrays with informaiton [x,y,w,h] that delimit the region on the
%image. For example roiC1 is the region of interest of cathode 1.
loadFilename  = strcat(targetDir, '/', date, '_', index, '_roi.mat');
roi = load(loadFilename);

%Load the images
images = loadImages(targetDir);
s = size(images);
len = s(3);

%The attSpots contain the location data for attachment spots. These are
%the location of the left cathode spot, the right cathode spot, and the one
%or many anode spots. These will be used as the source and target locations
%for the algorithm that will trace the arc path.
attSpotsFilename = strcat(targetDir,'/',date, '_', index, '_attSpots.mat');
attSpotsStruct = load(attSpotsFilename);
attSpots = attSpotsStruct.attSpots;
clear arcSpotsStruct

roiCrop = roi.roiCrop;
roiCrop1 = roiCrop(1);
roiCrop2 = roiCrop(2);
roiCrop3 = roiCrop(3);
roiCrop4 = roiCrop(4);

clear crop;
crop(1:roiCrop(4),1:roiCrop(3),len) = uint8(0); 
arcPathCell = cell(len,2);
arcLengthArr = zeros(len,2);

target1Arr = zeros(2,len);
target2Arr = zeros(2,len);
source1Arr = zeros(2,len);
source2Arr = zeros(2,len);

target1Arr(:,:) = attSpots(1,:,:);
target2Arr(:,:) = attSpots(2,:,:);
source1Arr(:,:) = attSpots(3,:,:);
source2Arr(:,:) = attSpots(4,:,:);


%NOTE that this can take very long (A few hours). Change len to a smaller 
%value (such as 100) if you don't want to wait until it looped through 
%the 10000 images.
for i = 1:len

    gateS1 = true;
    gateS2 = true;
    gateT1 = true;
    gateT2 = true;
    img = images(:,:,i);
    crop(:,:,i) = img(roiCrop2:roiCrop2+roiCrop4-1, roiCrop1:roiCrop1+roiCrop3-1);

    target1 = target1Arr(:,i);  %Cathode 1 (left)
    target2 = target2Arr(:,i);  %Cathode 2 (right)
    source1 = source1Arr(:,i);  %Anode spot that is left most
    source2 = source2Arr(:,i);  %Anode spot that is right most

    if source1(1,1) == 1
        gateS1 = false;
    end
    
    if source2(1,1) == 1
        gateS2 = false;
    end
    
    if target1(1,1) == 1
        gateT1 = false;
    end
    
    if target2(1,1) == 1
        gateT2 = false;
    end
    
    %prevent the adjustment from happening because it would lead to an out
    %of bound error
    if gateS1
        source1(1,1) = source1(1,1) - roiCrop2+1;
        source1(2,1) = source1(2,1) - roiCrop1+1;
    end
    
    if gateT1
        target1(1,1) = target1(1,1) - roiCrop2+1;
        target1(2,1) = target1(2,1) - roiCrop1+1;
    end
    
    if gateS2
        source2(1,1) = source2(1,1) - roiCrop2+1;
        source2(2,1) = source2(2,1) - roiCrop1+1;
    end
    
    if gateT2
        target2(1,1) = target2(1,1) - roiCrop2+1;
        target2(2,1) = target2(2,1) - roiCrop1+1;
    end
    
    
    if gateT1 && gateT2
        %There are two cathodes that are live
        if gateS1 && gateS2
            %Two sources
            arcPath1 = findArcPathV1(crop(:,:,i),source1,target1);
            arcPath2 = findArcPathV1(crop(:,:,i),source2,target2);
        elseif gateS1 && ~gateS2
            %One source S1
            arcPath1 = findArcPathV1(crop(:,:,i),source1,target1);
            arcPath2 = findArcPathV1(crop(:,:,i),source1,target2);
        elseif gateS2 && ~gateS1
            %One source S2 (unlikely in my opinion)
            arcPath1 = findArcPathV1(crop(:,:,i),source2,target1);
            arcPath2 = findArcPathV1(crop(:,:,i),source2,target2);
        else
            %No sources
            arcPath1 = [];
            arcPath2 = [];
        end
        
    elseif gateT2 && ~gateT1
        %Cathode 1 is out
        arcPath1 = [];
        if gateS1
            arcPath2 = findArcPathV1(crop(:,:,i),source1,target2);
        elseif gateS2
            arcPath2 = findArcPathV1(crop(:,:,i),source2,target2);
        else
            arcPath2 = [];
        end
    elseif gateT1 && ~gateT2
        %Cathode 2 is out
        arcPath2 = [];
        if gateS1
            arcPath1 = findArcPathV1(crop(:,:,i),source1,target1);
        elseif gateS2
            arcPath1 = findArcPathV1(crop(:,:,i),source2,target1);
        else
            arcPath1 = [];
        end
    else
        arcPath1 = [];
        arcPath2 = [];
        
    end
    
    arcPathCell(i,:) = {arcPath1, arcPath2};    
    
end



%Can't do this in the parfor loop so do it after.
for i = 1:len

    arcPath1 = arcPathCell{i,1};
    arcPath2 = arcPathCell{i,2};
    
    %Draw out the arcPath on the crop
    for k = 1:length(arcPath1)
        crop(arcPath1(k,1), arcPath1(k,2),i) = 255;
    end
    
    for k = 1:length(arcPath2)
        crop(arcPath2(k,1), arcPath2(k,2),i) = 255;
    end

    %Calculate the length from the arc path
    if ~isempty(arcPath1)
        arcLengthArr(i,1) = getArcLengthV1(arcPath1);
    end
    
    if ~isempty(arcPath2)
        arcLengthArr(i,2) = getArcLengthV1(arcPath2);
    end
    
    if ~isempty(arcPathCell{i,1})
        arcLengthArr(i,1) = getArcLengthV1(arcPathCell{i,1});
    end
    
    if ~isempty(arcPathCell{i,2})
        arcLengthArr(i,2) = getArcLengthV1(arcPathCell{i,2});
    end


end

%Used when you need to save the arcPaths and acrLengths.
% save(saveArcPathCellFilename,'arcPathCell')
% save(saveArcLengthFilename, 'arcLengthArr')

fprintf('Runtime was: ');
toc

load handel;
sound(y,Fs);
%Clean up workspace since this is a script.
clear arcPath1
clear arcPath2
clear gateS1
clear gateS2
clear gateT1
clear gateT2
clear i
clear roiCrop
clear source1
clear source2
clear target1
clear target2
clear target1Arr
clear target2Arr
clear source1Arr
clear source2Arr
clear roiCrop1
clear roiCrop2
clear roiCrop3
clear roiCrop4
clear y
clear Fs
% implay(crop)


%Play a video of the arc path reconstruction
toDisplay = playArcPathEAF_V2(images,arcPathCell,1,roi);
