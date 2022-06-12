function [new_img] = IMGCOMP_Helper(old_img,method,varargin)
% helper script to add modular steps to image processing

%% VERSION HISTORY
% CREATED 7/11/21 BY SS


%% PERFORM MODIFICATION
if strcmp(method,'bilinear')
    disp('Scaling image...')
    [x,y,~] = size(old_img);
    scale = sqrt(varargin{2}/(x*y));
    new_img = imresize(old_img,scale,'bilinear');
    %new_img = IMGCOMP_Bilinear(old_img,varargin{1},varargin{2});
elseif strcmp(method,'bright') || strcmp(method,'brightness')
    disp('Adjusting brightness...')
    bright = varargin{1};
    n = max(size(bright));
    if n == 1
        bright = [bright bright bright];
    end
    [x,y,~] = size(old_img);
    new_img = zeros(x,y,3);
    for i = 1:3
        new_img(:,:,i) = old_img(:,:,i)*bright(i);
    end
    new_img = uint8(new_img);
elseif strcmp(method,'contrast')
    disp('Adjusting contrast...')
    if mod(nargin,2) ~= 0       % we expect an even number + 1 arguments
        error(['Check number of input arguments. Parameters must be input as pairs.']);
    end
    
    amount = [];
    threshold = [];

    for i = 1:2:nargin-2
        if strcmp(varargin{i},'Amount') && isnumeric(varargin{i+1})
            amount = varargin{i+1};
        elseif strcmp(varargin{i},'Threshold') && isnumeric(varargin{i+1})
            threshold = varargin{i+1};
        else
            warning([varargin{i} ' is not a supported argument, will ignore.']);
        end
    end
    
    new_img = localcontrast(uint8(old_img*255),threshold,amount);
elseif strcmp(method,'satboost')
    disp('Adjusting color saturation...')
    satboost = varargin{1};
    new_img = rgb2hsv(old_img);
    new_img(:,:,2) = new_img(:,:,2)*satboost;
    new_img(new_img > 1) = 1;
    new_img = hsv2rgb(new_img);
elseif strcmp(method,'sharpen')
    disp('Sharpening edges...')
    if mod(nargin,2) ~= 0       % we expect an even number + 1 arguments
        error(['Check number of input arguments. Parameters must be input as pairs.']);
    end

    radius = [];
    amount = [];
    threshold = [];
    arg1 = [];
    arg2 = [];
    arg3 = [];

    for i = 1:2:nargin-2
        if strcmp(varargin{i},'Radius') && isnumeric(varargin{i+1})
            radius = varargin{i+1};
            arg1 = varargin{i};
        elseif strcmp(varargin{i},'Amount') && isnumeric(varargin{i+1})
            amount = varargin{i+1};
            arg2 = varargin{i};
        elseif strcmp(varargin{i},'Threshold') && isnumeric(varargin{i+1})
            threshold = varargin{i+1};
            arg3 = varargin{i};
        else
            warning([varargin{i} ' is not a supported argument, will ignore.']);
        end
    end

    %% PROCESS AND RETURN IMAGE
    new_img = imsharpen(old_img,arg1,radius,arg2,amount,arg3,threshold);
elseif strcmp(method,'smooth')
    disp('Smoothing and denoising...')
    sigma = varargin{1};
    new_img = imgaussfilt(old_img,sigma);
else
    error([method ' isn''t a supported processing method.']);
end
   
