function [area, centroids] = Cell_Count(raw_image, threshold, minSize, maxSize, erosionSize)
    img_gray = raw_image;
    I_BW = imbinarize(img_gray, threshold);
    I_BW_m = medfilt2(I_BW, [3, 3]);
    se = strel('disk', erosionSize);
    I_BW_e = imerode(I_BW_m, se);
    BWnobord = imclearborder(I_BW_e, 4);

    D = -bwdist(~BWnobord);
    Ld = watershed(D);
    BWnobord(Ld == 0) = 0;
    L = bwlabeln(BWnobord, 8);
    S = regionprops(L, 'Area', 'Centroid');

    validAreas = ([S.Area] >= minSize) & ([S.Area] <= maxSize);
    if ~isempty(validAreas)
        validS = S(validAreas);
        area = [validS.Area];
        centroids = cat(1, validS.Centroid);
    else
        area = [];
        centroids = [];
    end
end
