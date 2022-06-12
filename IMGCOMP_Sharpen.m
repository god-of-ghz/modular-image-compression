function [new_img] = IMGCOMP_Sharpen(old_img,varargin)
% function to sharpen an image

%% VERSION HISTORY
% CREATED 7/13/20 BY SS

%% PROCESS PARAMETERS
disp(nargin)
if mod(nargin,2) ~= 1       % we expect an even number + 1 arguments
    error(['Check number of input arguments. Parameters must be input as pairs.']);
end

radius = [];
amount = [];
threshold = [];
arg1 = [];
arg2 = [];
arg3 = [];

for i = 1:2:nargin-1
    if strcmp(varargin{i},'Radius') && isdouble(varargin{i+1})
        radius = varargin{i+1};
        arg1 = varargin{i};
    elseif strcmp(varargin{i},'Amount') && isdouble(varargin{i+1})
        amount = varargin{i+1};
        arg2 = varargin{i};
    elseif strcmp(varargin{i},'Threshold') && isdouble(varargin{i+1})
        threshold = varargin{i+1};
        arg3 = varargin{i};
    else
        warning([varargin{i} ' is not a supported argument, will ignore.']);
    end
end

%% PROCESS AND RETURN IMAGE
new_img = imsharpen(old_img,arg1,radius,arg2,amount,arg3,threshold);