close all;
clear all;

addpath('J:\Breast Imaging\Restricted-Data\Partridge\Yifan\Radiomics\radiomics-master\radiomics-master-all');
addpath('J:\Breast Imaging\Restricted-Data\Partridge\Yifan\BPE\3D code');
sequence_path = uigetdir('J:\Breast Imaging\Restricted-Data\Partridge\Yifan\Radiomics','Select the patient & sequence');
addpath(sequence_path);
cd(sequence_path);
% [filename, pathname] = uigetfile('*.dcm', 'Choose a representative image for thresholding');% only image DICOM

%--------------------------------------------------------------------------
%%% charge et lecture de l'image %%%
%--------------------------------------------------------------------------
if isequal(sequence_path, 0)%isequal(filename, 0) || isequal(pathname, 0)
    disp('Image input canceled.');
    X = [];    map = [];
% else
%     info = dicominfo(filename);
%     [X,MAP]=dicomread(fullfile(pathname, filename));%Lecture d'image.
end
% lsz=length(size(X));
% if lsz==3
%     X=rgb2gray(X);
% end

% read images into stack
d = dir('*.dcm');
[path,name,ext] = fileparts(d(1).name);
prompt = {'Please enter filename:'};
dlg_title = 'filename';
num_lines = 1;
def = {strcat(name,'.dcm')};
Name = inputdlg(prompt,dlg_title,num_lines,def);
Name = Name{1};
dim = size(dicomread(sprintf(Name,1)));
info = dicominfo(sprintf(Name,1));
stack1 = repmat(uint16(0),[dim length(d)]);
for i = 1:length(d)
%     stack1(:,:,1,i) = dicomread(sprintf('CAD_REGdyneTHRIVE_i%d.dcm',i));
    stack1(:,:,i) = dicomread(sprintf(Name,i));
end

stack = figure('name','Scroll through and type the image range for texture measurement');
imshow3D(stack1,[]);

Begin = [];
while(isempty(Begin))
Begin = input('Beginning slice number of texture measurement: ');
end
End = [];
while(isempty(End))
End = input('Ending slice number of texture measurement: ');
end
close(stack);
%% Apply ROI and threshold on a representative image
%%Same threshold will be applied on 3D ROI
replyYes = true;
while (replyYes)
    close all;
    
    %% Region of interest extraction by free hand
    
%     X(X<0) = 0; %CT images contain negative values
    X = stack1(:,:,round((Begin+End)/2));
    im0=X;
    X=double(X);
    figure('name','Original Lesion DICOM file'), h_im = imshow(im0,[]),title('Choose ROI from the figure');
    h = imfreehand;
    position = wait(h);
    e = impoly(gca,position);
    BW = createMask(e,h_im);
    ROI=X.*BW;
    figure('name','initial ROI'),imshow(ROI,[]);
    %ROI=uint8(ROI);im_DIF=uint8(im_DIF);
    %ROI=uint16(ROI);im_DIF=uint16(im_DIF);
    
    %% Apply threshold on ROI
    
    [im_thr,n,m,M] = threshold(ROI,'1');
    threshROI = im_thr;
    type = 'canny'; %original 'sobel'
    [BWs, THRESH] = edge(threshROI, type, [.001 .05]);
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BWsdil = imdilate(BWs, [se90 se0]); %figure, imshow(BWsdil), title('dilated gradient mask');
    BWdfill = imfill(BWsdil, 'holes'); %figure, imshow(BWdfill), title('binary image with filled holes');
    seD = strel('diamond',1);
    BWfinal = imerode(BWdfill,seD);
    BWfinal = imerode(BWfinal,seD);
    figure('name', 'Segment Image'), imshow(BWfinal), title('Segment Image');
    
    %% Generate colormap on thresholded ROI
    
    figure('name', 'Lesion Colormap'),title('Lesion Colormap');
    ax1 = axes;
    imagesc(X);
    colormap(ax1,'gray');
    ax2 = axes;
    imagesc(ax2,im_thr,'alphadata',threshROI>0);
    colormap(ax2,'jet');
    caxis(ax2,[min(nonzeros(threshROI)) max(nonzeros(threshROI))]);
    ax2.Visible = 'off';
    linkprop([ax1 ax2],'Position');
    colorbar;
    
    
    replyYes = lower(input('Segmentation ok? (y/n): ','s'));
    if replyYes == 'y'
        %warning('if file exists (Texture_features_2D.csv) Results will auto append')
        replyYes = false;
    end
       
end

idcs = strfind(sequence_path,filesep);
save_path = sequence_path(1:idcs(end)-1);
cd(save_path);
saveas(gcf,strcat('ColorMap', '_',info.PatientName.FamilyName,'_', info.PatientName.GivenName, '.tif'));
mkdir Outline;
cd('Outline');

%% Draw ROI and apply the same threshold on all images contain lesion
im_thr_stack = repmat(double(0),[size(ROI) (End-Begin+1)]);
ROI_mask_stack = repmat(double(0),[size(ROI) (End-Begin+1)]);
for i = 1:(End-Begin+1)
    X = stack1(:,:,i+Begin-1);
    X = double(X);
    slice = figure('name','Original Lesion Slice'), h_im = imshow(stack1(:,:,i+Begin-1),[]);title('Draw ROI on the Slice');
    h = imfreehand;
    position = wait(h);
    e = impoly(gca,position);
    BW = createMask(e,h_im);
    ROI=X.*BW;
    im_thr_stack(:,:,i) = threshold_grayscale_image(ROI,m,M);
    close(slice) ;
    
    Redraw = 0;
    type = 'canny'; %original 'sobel'
    [BWs, THRESH] = edge(im_thr_stack(:,:,i), type, [.001 .05]);
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BWsdil = imdilate(BWs, [se90 se0]);
    BWdfill = imfill(BWsdil, 'holes');
    seD = strel('diamond',1);
    BWfinal = imerode(BWdfill,seD);
    BWfinal = imerode(BWfinal,seD);
    ROI_mask_stack(:,:,i) = ROI & BWfinal;
    outline = figure('name', 'Lesion Outline'), imshow(X,[]), title('Outlined the lesion');
    hold on;
    boundaries = bwboundaries(ROI_mask_stack(:,:,i));
    numberOfBoundaries = size(boundaries);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2),thisBoundary(:,1), 'r', 'LineWidth', 2);
    end
    hold off;
    
    pause(1.5)
    info = dicominfo(sprintf(Name,i+Begin-1));
    saveas(gcf,strcat('Outline','_',info.PatientName.FamilyName,'_', info.PatientName.GivenName,'_',num2str(info.InstanceNumber),'.tif'));
    close(outline);
end

%figure, imshow3D(im_thr_stack,[]);


%% save images with boudaries
% idcs = strfind(path,filesep);
% save_path = path(1:idcs(end)-1);
% cd(save_path);
% saveas(gcf,strcat('ColorMap', '_',info.PatientName.FamilyName,'_', info.PatientName.GivenName, '.tif'));

% ROI_mask = ROI & BWfinal;
% figure('name', 'Lesion Outline'), imshow(X,[]), title('Outlined the lesion');
% hold on;
% boundaries = bwboundaries(ROI_mask);	
% numberOfBoundaries = size(boundaries);
% for k = 1 : numberOfBoundaries
% 	thisBoundary = boundaries{k};
%  	plot(thisBoundary(:,2),thisBoundary(:,1), 'r', 'LineWidth', 2);
% %    plot(thisBoundary(:,2),thisBoundary(:,1), 'y', 'LineWidth', 2);
% end
% 
% saveas(gcf,strcat('Outline','_',info.PatientName.FamilyName,'_', info.PatientName.GivenName, '.tif'));
% hold off;

%% Compute Texture Feature based on multiple models

volume = stack1;
mask = ROI_mask_stack;

scanType = [];
while(isempty(scanType))
    scanType = input('Is it a PETscan/MRscan/Other: ','s');
end

pixelW = info.PixelSpacing(1);%in mm
sliceS = info.SliceThickness;%in mm
scale = pixelW; %isotropic voxel size...see prepareVolume.m

textType = ["Global" "Matrix"];
quantAlgo = [];
while(isempty(quantAlgo))
    quantAlgo = input('Which quantization algorithm for Matrix type texture? Equal/Lloyd/Uniform: ','s');
end
Ng = [];
while(isempty(Ng))
    Ng = input('Number of gray levels? 8/16/32: ');
end

[ROIonly] = prepareVolume(volume,mask,scanType,pixelW,sliceS,1,'pixelW',textType(1));%copied from Github web
[globalTextures] = getGlobalTextures(ROIonly,100); % Here, using 100 bins in the histogram

global_names = string(fieldnames(globalTextures)');
global_values = struct2array(globalTextures);

[ROIonly,levels] = prepareVolume(volume,mask,scanType,pixelW,sliceS,1,scale,textType(2),quantAlgo,Ng);

GLCM= getGLCM(ROIonly,levels); 
glcmTextures = getGLCMtextures(GLCM);
glcm_names = string(fieldnames(glcmTextures)');
glcm_values = struct2array(glcmTextures);

GLRLM = getGLRLM(ROIonly,levels); 
glrlmTextures = getGLRLMtextures(GLRLM);
glrlm_names = string(fieldnames(glrlmTextures)');
glrlm_values = struct2array(glrlmTextures);

GLSZM = getGLSZM(ROIonly,levels); 
glszmTextures = getGLSZMtextures(GLSZM);
glszm_names = string(fieldnames(glszmTextures)');
glszm_values = struct2array(glszmTextures);

[NGTDM,countValid] = getNGTDM(ROIonly,levels); 
ngtdmTextures = getNGTDMtextures(NGTDM,countValid);
ngtdm_names = string(fieldnames(ngtdmTextures)');
ngtdm_values = struct2array(ngtdmTextures);

texture_names = [global_names,glcm_names,glrlm_names,glszm_names,ngtdm_names];
texture_values = [global_values,glcm_values,glrlm_values,glszm_values,ngtdm_values];

%% Save measurements to an Excel file

cd('J:\Breast Imaging\Restricted-Data\Partridge\Yifan\Radiomics')
saveFilename = 'Texture_features_3D.xlsx';
if exist(saveFilename,'file')
    Results = {info.PatientName.FamilyName, info.PatientName.GivenName, info.PatientID, info.StudyDate, info.PixelSpacing(1), info.SliceThickness};
    for i = 1:length(texture_values)
        Results{6+i} = texture_values(i);
    end
    xlsappend(saveFilename,Results)
else
    [saveFilename,path,indx] = uiputfile('Texture_features_2D.xlsx');
    Tags = ['Last Name','Given Name', 'MRN',  'Study Date','PixelSpacing','SliceThickness',texture_names];
    Results = {info.PatientName.FamilyName, info.PatientName.GivenName, info.PatientID, info.StudyDate, info.PixelSpacing(1), info.SliceThickness};
    for i = 1:length(texture_values)
        Results{6+i} = texture_values(i);
    end
    xlswrite(saveFilename,Tags)
    xlsappend(saveFilename,Results)
end

disp(['Results saved to: ' path saveFilename])
