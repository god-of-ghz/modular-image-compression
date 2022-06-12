function [new_img] = IMGCOMP_Smooth(old_img,method,sigma)
% function to smooth an input image with various filters

%% SMOOTH AND RETURN IMAGE
if isempty(method) || strcmp(method,'gaussian') || strcmp(method,'gauss')
    new_img = imgaussfilt(old_img,sigma);
else
    error([method ' is not a support smoothing method.']);
end

