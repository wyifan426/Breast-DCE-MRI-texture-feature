%                               431-400 Year Long Project 
%                           LA1 - Medical Image Processing 2003
%  Supervisor     :  Dr Lachlan Andrew
%  Group Members  :  Alister Fong    78629   a.fong1@ugrad.unimelb.edu.au
%                    Lee Siew Teng   102519  s.lee1@ugrad.unimelb.edu.au
%                    Loh Jien Mei    103650  j.loh1@ugrad.unimelb.edu.au
% 
%  The function without any numbers at the name of its name is the most up-to-date version intended
%  for use.
%  Current version in use : Version 6 - threshold_grayscale_image5
%
%  File and function name : threshold_grayscale_image
%  Version                : 6.0
%  Date of completion     : 2 May 2003   
%  Written by    :   Alister Fong    78629   a.fong1@ugrad.unimelb.edu.au
%
%  Inputs        :   original_image  - original grayscale image (0 - black, 255 - white)
%                    min_threshold   - minimum value that should be recognized as a feature.
%                    max_threshold   - maximum value that should be recoginized as a feature
%
%  Outputs       :   thresholded_image - binary thresholded image 
%                                (Feature = black(0) otherwise white(255) as indicated in Version 5)
%
%  Description   :   If the pixel in the original image has a value between the min_threshold 
%                    and max_threshold, then it will be assigned as a white pixel in the binary 
%                    image. Otherwise it will be a black pixel.
%
%  To Run >> thresholded_image = threshold_grayscale_image(original_image,min_threshold,max_threshold)
%            (0 <= min_threshold, max_threshold<= 255)

%                    Version 1
%                    The speed of this program is too slow
%
%                    Version 2
%                    This is a faster version of threshold_grayscale_image using vectorized methods
%                    instead of 'for' loops. The previous version took around 56 seconds to execute 
%                    on a 600 x 600 grayscale image, while this version takes about 4 seconds.
%                    Problem     :   This is still too slow for multiple usage as a 1924 x 2886 
%                                    image takes about 4 minutes to process.
%
%                    Version 3
%                    In this version, the use of vector form of pixel selection to assign the black
%                    pixel value has improved the speed of this program. 
%                    Problem     :   This is still too slow for multiple usage as a 1924 x 2886 
%                                    image takes about 4 minutes to process. However, the speed 
%                                    bottleneck is now the initialization of the thresholded_image 
%                                    to be all white pixels.
%
%                    Version 4
%                    This is a fastest version of threshold_grayscale_image using vectorized methods
%                    instead of 'for' loops. The initialization of the thresholded_image has been 
%                    changed to a more vectorized form using a faster 2 step method of initialization.
%                    Problem     :   This is still too slow for multiple usage as a 1924 x 2886 image 
%                                    takes about 2 minutes to process.
%
%                   Version 5
%                   To speed up the process by about twice the previous speed, we redefine the output
%                   If there is a feature, it will be represented by white(255) otherwise by black(0)
%                   Now there is a maximum processing time of about 3 minutes for a 1924 x 2886 image
%
%                   Version 6
%                   Change the resultant image to 0 for black(non-feature) and 1 for white(feature)

function thresholded_image = threshold_grayscale_image(original_image,min_threshold,max_threshold)
% Initialize the value of black and white pixels
%black_pixel = 0;
%white_pixel = 1;
% Ensure that the threshold inputs are acceptable
if min_threshold > max_threshold
    error('threshold_grayscale_image : min_threshold is greater than max_threshold');
end



%Generate the resulting image
%Initialize the image to be all black (non-feature)
%Method used here is optimized for speed
thresholded_image = zeros(size(original_image));
%Find all pixels which are the feature
selected = (min_threshold <= original_image) & (original_image <= max_threshold);
%Assign the white pixel value to all coordinates of features 
thresholded_image(selected) = original_image(selected);

%[m, n]=size(original_image);
%f_transform=fft2(original_image);
%f_shift=fftshift(f_transform);
%p=m/2;
%q=n/2;
%d0 = min_threshold;
%for i=1:m
%for j=1:n
%distance=sqrt((i-p)^2+(j-q)^2);
%low_filter(i,j)=1-exp(-(distance)^2/(2*(d0^2)));
%end
%end
%filter_apply=f_shift.*low_filter;
%image_orignal=ifftshift(filter_apply);
%thresholded_image = abs(ifft2(image_orignal));