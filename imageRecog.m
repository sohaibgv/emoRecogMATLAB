function [f, area]=imageRecog(im2)
im3=rgb2gray(im2);
level = graythresh(im2);
im4=imbinarize(im3,level);
im5=imcomplement(im4);
im6=imclose(im5,strel('disk',40));
[labels,numlabels]=bwlabel(im6);
disp(numlabels);
stats = regionprops(labels, 'all')
area = stats(1).Area;
f=4*pi*area/((stats(1).Perimeter)^2) 
end