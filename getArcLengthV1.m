function arcLength = getArcLengthV1(arcPath)

S = size(arcPath);
arcLength = 0;
%Only need to go to l-1 because we have l-1 edges for l points (not cyclic)
for i = 1:S(1)-1
    r1 = arcPath(i,1);
    c1 = arcPath(i,2);
    
    r2 = arcPath(i+1,1);
    c2 = arcPath(i+1,2);
    
    dr = abs(r1-r2);
    dc = abs(c1-c2);
    
    if dr+dc == 1
        arcLength = arcLength + 1;
    else
        arcLength = arcLength + sqrt(2);
    end

end