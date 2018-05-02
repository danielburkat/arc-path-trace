function arcPath = findArcPathV1(roi, source, target)
%This code is an implementation of the Dijkstra's shortest path algorithm 
%that I adapted to find the path of the electric arc.

%The inputs are:
%ROI: Image of the region of interest (ROI) that contains the arc. 
%SOURCE: coordinates of the source on the ROI (x,y)
%TARGET: coordinates of the target (x,y)

%The output is:
%ARCPATH: the arc path on the ROI as an nx2 array of coordinates


%tic
S = size(roi);
roi = double(roi);
roi = roi+1;
unvisited = ones(S(1), S(2));

timeNprev = zeros(S(1),S(2), 3);
timeNprev(:,:,1) = Inf;
timeNprev(:,:,2) = NaN;
timeNprev(:,:,3) = NaN;
timeNprev(source(1),source(2),1) = 0;

while any(any(unvisited))
    a = timeNprev(:,:,1);
    a = double(unvisited).*a;
    [timeU, I] = min(a(:));
    [rU, cU] = ind2sub(S,I);
    if rU == target(1) && cU == target(2)
        break;
    end
    unvisited(rU,cU) = NaN;
    
    %Each node has at most 8 connections
    %Make sure:
    % 1 - the index values are in range
    % 2 - the index values have not been visited yet
    %So the vertex set to check is:
    % { rU+1,cU; rU,cU-1; rU-1,cU; rU,cU+1; rU+1,cU-1; rU-1,cU-1; rU-1,cU+1; rU+1,cU+1 }       
    setNESW = [rU+1,cU; rU,cU-1; rU-1,cU; rU,cU+1];
    setDiag = [rU+1,cU-1; rU-1,cU-1; rU-1,cU+1; rU+1,cU+1];
    
    %for each one in setNESW (North, East, South, West connections)
    for i = 1:4
        %first check if in range, if not then skip it
        rV = setNESW(i,1);
        cV = setNESW(i,2);
        if rV>S(1) || rV < 1 || cV > S(2) || cV < 1
            continue;
        end
        
        %then if it has not been visited yet then check it out
        if ~isnan(unvisited(rV, cV))
            timeV = 1/(roi(rV,cV)^2);
            temp = timeU + timeV;
            if temp < timeNprev(rV,cV,1)
                timeNprev(rV,cV,1) = temp;
                timeNprev(rV,cV,2) = rU;
                timeNprev(rV,cV,3) = cU;
            end
        end
        
    end
    
    %for each one in setDiag (the diagonal connections)
    for i = 1:4
        rV = setDiag(i,1);
        cV = setDiag(i,2);
        if rV>S(1) || rV < 1 || cV > S(2) || cV < 1
            continue;
        end
        
        %then if it has not been visited yet check it out
        if ~isnan(unvisited(rV, cV))
            timeV = sqrt(2)/(roi(rV,cV)^2);
            temp = timeU + timeV;
            if temp < timeNprev(rV,cV,1)
                timeNprev(rV,cV,1) = temp;
                timeNprev(rV,cV,2) = rU;
                timeNprev(rV,cV,3) = cU;            
            end
        end
    end
    

    
end


arcPath = zeros(S(1)*S(2),2);
rU = target(1);
cU = target(2);
prevrU = timeNprev(rU,cU,2);
prevcU = timeNprev(rU,cU,3);

%Get the arc path by popping the stack from the target to the source
j = 1;
while ~isnan(prevrU)
    arcPath(j,1) = rU;
    arcPath(j,2) = cU;
    j = j + 1;
    
    rU = prevrU;
    cU = prevcU;
    prevrU = timeNprev(rU,cU,2);
    prevcU = timeNprev(rU,cU,3);
end
arcPath(j,1) = rU;
arcPath(j,2) = cU;

arcPath(j+1:end,:) = [];
%toc
end