clear all;
close all;
clc;

%% image read in 


%imdata = imread('lena.jpg');
%imdata = im2double( imdata );
%imdataRaw = imdata;
%imdataRaw = imrotate(imdataRaw,90);
%imshow(imdataRaw);

I = dicomread('Z02');
%M = I(450:750, 600:1200);
%M = M(60:301,1:301);
%M = imrotate(M, 270);TICTTI
%imshow(M);
%imhist(I);
 
imdata = I ;
imshow(imdata);impixelinfo;
%imhist(imdata);
%dicomwrite(imdata, 'Knee_cut.dcm');

%imdataRaw = 65535 - I;
%imshow(imdataRaw);
%imhist(imdataRaw);


%imdataRaw = histeq(imdataRaw);
%imshow(imdataRaw);


%imdataRaw = 65535-imdataRaw;

%imhist(imdataRaw);

fprintf('file read-in complete.\n');

%imdataRaw = ~imdataRaw;
%imshow(imdataRaw);
%imhist(imdataRaw);
%dicomwrite(imdataRaw, 'knee_histeq.dcm');


%% get basic parameters

width = size(imdata, 2);
height = size(imdata, 1);

%% process -> equivalent pyramidFilter
MIN_SIZE = 4;
runLevel = -1;
alpha = 2.0;
beta = 1.0;
sigma = 50;
range = 1;
lambda = 1;

%    finalOut = zeros(height, width);

    pixLevel = floor(log(min([width height])/MIN_SIZE)/log(2));

    if (runLevel > 0 && pixLevel > runLevel)
        finalLevel = runLevel;
    else
        finalLevel = pixLevel;
    end

    pyr = cell(finalLevel, 1);
    pyr{1} = imdata(:, :);

    for i = 2 : finalLevel
        pyr{i} = downSampleBy2(pyr{i-1});
        
       %figure(i);
      %imshow(pyr{i});
       %pause;
    end

    output = cell(finalLevel, 1);
    lastLayer = pyr{length(pyr)};

    avg = mean(mean(lastLayer(:, :)));
    output{length(output)} = avg + beta*(lastLayer(:, :) - avg);
%    output{length(output)} = output{length(output)}/max(max(output{length(output)}));
%     imshow(output{length(output)});
%     output{length(output)}
%     pause;

    for i = finalLevel-1 : -1 : 1
        % real process
        fprintf('processing layer: #%d, total: %d, remaining: %d\n', i, finalLevel, i);
        
        upIm = upSampleBy2(output{i+1});
        
         output{i} = mixedDomainFilter(pyr{i}, upIm, alpha, beta, sigma, range, lambda);
%        output{i} = output{i} ./ max(max(output{i}));
         
%         subplot(1, 2, 1);imshow(output{i});
%         subplot(1, 2, 2);imshow(pyr{i});
%         subplot(1, 3, 3);imshow(upIm);
       % figure(i);
      %  imshow(output{i});
      %  pause;

        
    end
    
  %  figure(1);
  %  imshow(output{1});
    %finalOut(:, :) = output{1};
  % output_new = output{1} - min(min(output{1})) ;  %∞—∂ØÃ¨∑∂Œßµ˜µΩ¥”0ø™ º
 %  output_new = im2uint16(output_new);
   % dicomwrite(output_16bit, 'Z03_MDF_0.7.dcm');
 %  figure(2);
 %  imshow(imdata);
   %imshow(output_new);
  %imwrite(output{1}, '1_1.5_sigma_0.02.png');
    %imshow(output{1});impixelinfo;
     q = uint16(output{1}); 
     dicomwrite(q, '2_1_50.dcm');
   

%subplot(2, 1, 1); imshow(imdataRaw); title('before');
%subplot(2, 1, 2); imshow(output{1}); title('after');


%% 
%for i = 1 : length(output)
%    imshow(output{i});
%     pause;
% end
