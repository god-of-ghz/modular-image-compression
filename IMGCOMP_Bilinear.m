function [new_img] = IMGCOMP_Bilinear(old_img,method,target)
% function that implements bilinear scaling for RGB images
%% VERSION HISTORY
% CREATED 7/9/21 BY SS

%% SAFETY & PREPARATION
[x,y,z] = size(old_img);
if z ~= 3
    error('Be sure input image is in RGB!')
end

if strcmp(method,'MP') || strcmp(method,'megapixels')
    o_MP = x*y;
    n_MP = target;
    scale = o_MP/n_MP;
    disp(['Input megapixels: ' num2str(o_MP/1e6)]);
    disp(['Desired megapixels: ' num2str(n_MP/1e6)]);
elseif strcmp(method,'npixels')
    scale = target;
else
    error([method ' is not a supported interpolation method!']);
end

% scaling factor is # of original pixels that will be used to make 1 pixel
% scaling of 16 means 16 pixels will now become 1 pixel (compression)
% scaling of 0.25 means 1 pixel will be used to generate 4 pixels (upscaling)
if scale == 1       % 1 pixel = 1 pixel, no scaling necessary
    new_img = old_img;
    return;
elseif scale <= 0   
    error('Be sure scaling factor is greater than 0!')
end

%% COMPUTE NEW IMAGE DIMENSIONS
% sizing factor, scale is expected to be number of pixels to turn into ONE pixel
% 16 scaling factor means 16 pixels will be averaged to make 1 pixel, which
% means x and y are divided by 4.5, and the mask will be a 5x5 grid
fac = sqrt(scale/pi)*2;     % DIAMETER of the averaging circle
nx = round(x/fac);          
ny = round(y/fac);

new_img = zeros(nx,ny,3);

%% COMPUTE MASK
dim = floor(fac)+1; % factor, rounded up, just the size of the mask matrix
if mod(dim,2) == 0  % if its even, just round up again
    dim = dim + 1;
end

% compute the max distance (at maximum distance, linear weighting factor will be 0)
md = floor(fac/2)+1;
% compute the base weighting factor, value at half the distance between center and max distance
bwf = 1/scale;
% compute linear weighting factor (slope or rise/run, also m in mx+b)
lwf = (0-bwf)/(md-fac/4);
% linear intercept (b in mx+b)
li = -lwf*md;
% compute mask
msk = zeros(dim);
cntr = floor(dim/2)+1;
for ii = 1:dim
    for jj = 1:dim
        d = distance(ii,jj,cntr,cntr);
        msk(ii,jj) = max(lwf*d+li,0);
    end
end

% normalize so it sums to 1
norm = 1/sum(msk(:));
msk = msk.*norm;



%% COMPUTE THE AVERAGE FOR EACH PIXEL
shift = floor(dim/2)+1;
for i = 1:nx
    for j = 1:ny
        % compute roughly in the original image where this pixel is centered
        ox = round((i/nx)*x);
        oy = round((j/ny)*y);
        % to handle corner cases
        if ox <= 0
            ox = 1;
        elseif ox > x
            ox = x;
        end
        if oy <= 0
            oy = 1;
        elseif oy > y
            oy = y;
        end
        
        for k = 1:3
            % total weight
            tw = 0;
            % running sum
            runsum = 0;
            for ii = 1:dim
                for jj = 1:dim
                    ix = ox-shift+ii;
                    iy = oy-shift+jj;
                    % check if its a valid pixel
                    if ix > 0 && ix <= x && iy > 0 && iy <= y
                        tw = tw + msk(ii,jj);
                        runsum = runsum + old_img(ix,iy,k).*msk(ii,jj);
                    end
                end
            end
            % corner case, normalize the sum in case we only used part of the mask
            runsum_norm = runsum/(tw/1);
            
            % assign the new pixels value
            new_img(i,j,k) = runsum_norm;
        end
    end
end

%% RETURN
new_img = uint8(new_img);

%% HELPER FUNCTION FOR DISTANCE
function d = distance(x1,y1,x2,y2)
    d = sqrt((x2-x1)^2 + (y2-y1)^2);