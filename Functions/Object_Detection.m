function [Domino_Locations, Circle_Locations ] = Object_Detection(image)
%Object_Detection Summary of this function goes here
%   Detailed explanation goes here

x = input('Press enter to begin object detction: ');

originalImage = step(colorDevice);
originalImage = originalImage(100:840, 640:1500, :);
gray = (rgb2gray(originalImage));
warp = imadjust(gray, [],[], 4);
% tform = estimateGeometricTransform([307,513,1408,1614; 649,205,205,649]', [124,550,1157,1797; 721,200,200,721]', 'projective');
% warp = imwarp(warp, tform);

%Detect FEATURES
points = detectMSERFeatures(warp, 'MaxAreaVariation', 0.25);

%Display first frame
figure; 
h = imshow(warp);
hold on;
%Binarise
% I = imwarp(gray, tform);
% I = adapthisteq(I); 
I = adapthisteq(gray);
I = imbinarize(I, 0.6);
%Compute imfindcircles 
[centers,radii] = imfindcircles(I, [12, 13],'ObjectPolarity','dark','Sensitivity',0.94,'EdgeThreshold',0.1, 'Method', 'twostage');

%Loop through features
a = size(points);
LineInfo = [];
serfCenters = [];
serfRadii = [];
for n = 1:a(1)
    axe = points(n).Axes;
    pos = points(n).Location;
    orient = points(n).Orientation;
    if((axe(1) > 5*axe(2)))
        if((axe(1) < 140) & (axe(1) > 30) & (axe(2) <30) & (axe(2) > 1))
            if( I(round(pos(2)), round(pos(1))) == 0 )
                LineInfo = [LineInfo; n pos orient axe];
            end
        end
    end
    if( (axe(1) <= 1.1* axe(2)) | (axe(2) <= 1.1*axe(1)) )
        if( (axe(1)< 30) & (axe(2) < 30) & (axe(1) > 10) & (axe(2) > 10) ) 
             serfCenters = [serfCenters; pos];
             serfRadii = [serfRadii; mean(axe)];
        end
    end
end

%prevent duplicates
a = size(LineInfo);
NoDuplicates = [];
DuplicateArray = [];

for i = 1:(a(1)-1)
    dup = 1;
    b = size(DuplicateArray);
    for j = 1:b(1)
        %Check if exist in Duplicate array
        if(DuplicateArray(j) == LineInfo(i))
            dup = 0;
            break
        end
    end
    if(dup == 1)
        for k = (i+1):a(1)
            %Check distance is less than axes
            pos1 = LineInfo(i, 2:3);
            pos2 = LineInfo(k, 2:3);
            vect = pos2-pos1;
            dist =sqrt(vect(1)^2+vect(2)^2);
            if(dist <= 30)
                DuplicateArray = [DuplicateArray; LineInfo(k,:)];
            end
        end
        NoDuplicates = [NoDuplicates; LineInfo(i, :)];
    end
end

% Draw lines and Circles
a = size(NoDuplicates);
for i = 1:a(1)
    n = NoDuplicates(i, 1);
    plot(points(n), 'showPixelList', false, 'showEllipses', true);
end

allCenters = [centers; serfCenters];
allRadii = [radii; serfRadii];
a = size(allCenters);
b = size(allRadii);

NoDuplicatesC = [];
NoDuplicatesR = [];
DuplicateArrayC = [];
DuplicateArrayR = [];

for i = 1:(a(1)-1)
    dup = 1;
    b = size(DuplicateArrayC);
    for j = 1:b(1)
        %Check if exist in Duplicate array
        if(DuplicateArrayC(j) == allCenters(i))
            dup = 0;
            break
        end
    end
    if(dup == 1)
        for k = (i+1):a(1)
            %Check distance is less than axes
            pos1 = allCenters(i, 1:2);
            pos2 = allCenters(k, 1:2);
            vect = pos2-pos1;
            dist =sqrt(vect(1)^2+vect(2)^2);
            if(dist <= 20)
                DuplicateArrayC = [DuplicateArrayC; allCenters(k,:)];
                DuplicateArrayR = [DuplicateArrayR; allRadii(k,:)];
            end
        end
        NoDuplicatesC = [NoDuplicatesC; allCenters(i, :)];
        NoDuplicatesR = [NoDuplicatesR; allRadii(i, :)];
    end
end

viscircles(NoDuplicatesC, NoDuplicatesR,'EdgeColor','r');

%Draw Rectangles
a = size(NoDuplicates);
RectangleInfo = [];
for n = 1:a(1)
  B = NoDuplicates(n,:);
  height = 2*B(5);
  width = B(5)*1;
  point1_x = B(2)-0.5*width*cos(B(4))-0.5*height*sin(B(4));
  point1_y = B(3)+0.5*width*sin(B(4))-0.5*height*cos(B(4));
  point2_x = B(2)+0.5*width*cos(B(4))-0.5*height*sin(B(4));
  point2_y = B(3)-0.5*width*sin(B(4))-0.5*height*cos(B(4)); 
  point3_x = B(2)+0.5*width*cos(B(4))-0.05*height*sin(B(4));
  point3_y = B(3)-0.5*width*sin(B(4))-0.05*height*cos(B(4));
  point4_x = B(2)-0.5*width*cos(B(4))-0.05*height*sin(B(4));
  point4_y = B(3)+0.5*width*sin(B(4))-0.05*height*cos(B(4));
  
  point5_x = B(2)-0.5*width*cos(B(4))+0.05*height*sin(B(4));
  point5_y = B(3)+0.5*width*sin(B(4))+0.05*height*cos(B(4));
  point6_x = B(2)+0.5*width*cos(B(4))+0.05*height*sin(B(4));
  point6_y = B(3)-0.5*width*sin(B(4))+0.05*height*cos(B(4));
  point7_x = B(2)+0.5*width*cos(B(4))+0.5*height*sin(B(4));
  point7_y = B(3)-0.5*width*sin(B(4))+0.5*height*cos(B(4));
  point8_x = B(2)-0.5*width*cos(B(4))+0.5*height*sin(B(4));
  point8_y = B(3)+0.5*width*sin(B(4))+0.5*height*cos(B(4));

  x1 = [point1_x, point2_x, point3_x, point4_x, point1_x];
  y1 = [point1_y, point2_y, point3_y, point4_y, point1_y];
  
  x2 = [point5_x, point6_x, point7_x, point8_x, point5_x];
  y2 = [point5_y, point6_y, point7_y, point8_y, point5_y];
  
  RectangleInfo = [RectangleInfo; x1, y1, x2, y2];
  
  plot(x1, y1)
  plot(x2, y2)
end

sz = size(RectangleInfo);
Within = 0;
for k = 1:sz(1)
    for i = 1:size(NoDuplicatesC)
        [in,on] = inpolygon(NoDuplicatesC(i, 1),NoDuplicatesC(i, 2),RectangleInfo(k, 1:5),RectangleInfo(k, 6:10));
        if ((in) || (on))
            Within = Within + 1;
        end
    end
    text(double(RectangleInfo(k, 1)),double(RectangleInfo(k, 6)),sprintf('%d', Within), 'Color', 'blue', 'FontSize', 14);
    Within = 0;
    
    for i = 1:size(NoDuplicatesC)
        in = inpolygon(NoDuplicatesC(i, 1),NoDuplicatesC(i, 2),RectangleInfo(k, 11:15),RectangleInfo(k, 16:20));
        if (in)
            Within = Within + 1;
        end
    end
    text(double(RectangleInfo(k, 11)),double(RectangleInfo(k, 16)),sprintf('%d', Within), 'Color', 'blue', 'FontSize', 14);
    Within = 0;
end

end
