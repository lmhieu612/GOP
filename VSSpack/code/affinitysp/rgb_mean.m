function [ rgbmean ] = rgb_mean( image,sp,seed )
%COLOR_HIST Summary of this function goes here
%   Detailed explanation goes here

%Split into RGB Channels
%     Red = image(:,:,1);
%     Red = Red(sp ==seed);
%     Green = image(:,:,2);
%     Green = Green(sp ==seed);
%     Blue = image(:,:,3);
%     Blue = Blue(sp ==seed);
%     %Get histValues for each channel
%     rgbmean = mean([Red,Green,Blue],1)/100;

    rgbmean = floor(mean(image(sp==seed)));
    
end

