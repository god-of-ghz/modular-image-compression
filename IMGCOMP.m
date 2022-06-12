% a script to coordinate image processing with automated modular processing steps
%% VERSION HISTORY
% CREATED 7/9/21 BY SS

%% PREPARATION
close all;

path = 'C:\Users\Sameer\Downloads\img_pop';
i_ftype = 'jpg';
o_ftype = 'jpg';
px_target = 3.5e6;
output_sizes = [700];   % desired sizes

% params for mass compression
% sharpen1 = 2;
% sharpen2 = 0.5;
% sharpen3 = 0.25;
% 
% smooth1 = 0.5;

% sharpening params
sharpen1 = [10 10 10 10 10];       % radius, in pixels
sharpen2 = [2 2 2 2 2];     % sharpening amount
sharpen3 = [0.80 0.80 0.50 0.80 0.80];    % if contrast is below this level, ignore
    
% contrast boost
cont1 = [0.05 0.05 0.05 0.10 0.01];       % edge threshold
cont2 = [0.50 0.30 1.00 0.50 1.00];        % amount

% smoothing
smooth1 = [0.80 0.80 0.80 0.80 0.80];     % sigma for gaussian blur

brightness = [1.025 1.05 1.05 1.025 1.025];  % simple multiplier
sat_fac = [1.35 1.35 1.30 1.30 1.30];     % simple multiplier

steps{1} = 'bilinear';
steps{2} = 'sharpen';
steps{3} = 'jpeg';

pos1 = [-1280 1900 1535 1620];
pos2 = [260 1900 1535 1620];
%pos1 = [0 40 1040 960];
%pos2 = [540 40 1040 960];

to_show = 0;
pause off
warning('off');

%% SAFETY & DIRECTORIES
n_step = size(steps,2);
n_size = size(output_sizes,2);

if ~exist(path,'dir')
    error('The selected directory does not exist! Try again...')
end

for i = 1:n_size
    folder_name = [path '\output - ' num2str(output_sizes(i)) ' kb'];
    if ~exist(folder_name,'dir')
        mkdir (folder_name)
    end
end

%% POPULATE TARGETS
info = dir(path);
info = struct2cell(info);
[~,n_file] = size(info);
file_names = cell(1,n_file);
n_img = 0;
to_process = zeros(1,n_file);

for i = 1:n_file
    temp = info{1,i};       
    if size(temp,2) >= 4 && strcmp(temp(end-2:end),i_ftype)
        file_names{i} = temp;
        n_img = n_img + 1;
        to_process(i) = 1;
    end
end

process_ind = zeros(1,n_img);
ind_itr = 1;
for i = 1:n_file
    if to_process(i)
        process_ind(ind_itr) = i;
        ind_itr = ind_itr + 1;
    end
end

img_names(1,:) = file_names(1,process_ind);

%% IMPORT AND PROCESS EACH IMAGE
parfor i = 1:n_img
    img = imread([path '\' img_names{1,i}]);
    for j = 1:n_size
        disp(['Running image: ' img_names{i}])
        if to_show
            figure, imshow(img),title(['original image'])
            set(gcf,'Renderer','painters','Position',pos1)
        end
        
        new_img = img;
        %new_img = IMGCOMP_Helper(new_img,'bright',brightness(i));
        %new_img = IMGCOMP_Helper(new_img,'satboost',sat_fac(i));
        new_img = IMGCOMP_Helper(new_img,'smooth',smooth1(i));
        %new_img = IMGCOMP_Helper(new_img,'contrast','Threshold',cont1(i),'Amount',cont2(i));
        new_img = IMGCOMP_Helper(new_img,'sharpen','Radius',sharpen1(i),'Amount',sharpen2(i),'Threshold',sharpen3(i)');
        
        
        imwrite(new_img, [path '\output - ' num2str(output_sizes(j)) ' kb\' img_names{i}(1:end-4) '_pop.' o_ftype], o_ftype);
        
        new_img = IMGCOMP_Helper(new_img,'bilinear','MP',px_target*(1+(j-1)/1.2));
        
        
        if to_show
            figure, imshow(new_img), title(['final image']);
            set(gcf,'Renderer','painters','Position',pos2)
        end
        
        imwrite(new_img, [path '\output - ' num2str(output_sizes(j)) ' kb\' img_names{i}(1:end-4) '_pop_small.' o_ftype], o_ftype);
        
        %pause
    end
end

%data = ifftshift(ifftn(ksp(:,:,enc,frame)));
%figure, imagesc(sqrt(sum(abs(data).^2, 4))), axis square off, colorbar, title('reconstructed from k-space')