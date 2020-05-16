%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: Part A and PCM
%Note: Different Quantization method
RGB = imread('lena512color.tiff');  %load the video and converts to double
figure;
imshow(RGB);
title('Raw Image');
%Y component of the Image
R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);
Y = 0.299 * R + 0.587 * G + 0.114 * B;
U = -0.14713 * R - 0.28886 * G + 0.436 * B;
V = 0.615 * R - 0.51499 * G - 0.10001 * B;
YUV = cat(3,Y,U,V);         %Concatenate Arrays 3x512x512
YUV1= Y;
%PART A HISTOGRAM
%RGB denser due to having 3 dimen
figure;
histogram(Y);
title('Y Component Histogram');
ylabel('Number of Elements');
xlabel('Range of Values');
% figure;
% histogram(U);
% figure;
% histogram(V);
figure;
histogram(RGB);
title('RBG Component Histogram');
ylabel('Number of Elements');
xlabel('Range of Values');

p = Y;
p = double(p);
[m,n] = size(p(:,:));
%ALL pixel values in one row
X(:,:) = reshape(p(:,:),[1,(m*n)]);

%PCM Quantization
PCMSELF = X;
rowCount = 1;
for colCount = 1:length(PCMSELF)
     if PCMSELF(rowCount,colCount)>= 0 && PCMSELF(rowCount,colCount)<= 15
         PCMSELF(rowCount,colCount) = 8;
     elseif PCMSELF(rowCount,colCount)>= 17 && PCMSELF(rowCount,colCount)<= 32
         PCMSELF(rowCount,colCount) = 24;
     elseif PCMSELF(rowCount,colCount)>= 33 && PCMSELF(rowCount,colCount)<= 47
         PCMSELF(rowCount,colCount) = 40;
     elseif PCMSELF(rowCount,colCount)>= 49 && PCMSELF(rowCount,colCount)<= 64
         PCMSELF(rowCount,colCount) = 56;
     elseif PCMSELF(rowCount,colCount)>= 65 && PCMSELF(rowCount,colCount)<= 79
         PCMSELF(rowCount,colCount) = 72;
     elseif PCMSELF(rowCount,colCount)>= 81 && PCMSELF(rowCount,colCount)<= 96
         PCMSELF(rowCount,colCount) = 88;
     elseif PCMSELF(rowCount,colCount)>= 97 && PCMSELF(rowCount,colCount)<= 111
         PCMSELF(rowCount,colCount) = 104;
     elseif PCMSELF(rowCount,colCount)>= 113 && PCMSELF(rowCount,colCount)<= 128
         PCMSELF(rowCount,colCount) = 120;
     elseif PCMSELF(rowCount,colCount)>= 129 && PCMSELF(rowCount,colCount)<= 143
         PCMSELF(rowCount,colCount) = 136;
     elseif PCMSELF(rowCount,colCount)>= 145 && PCMSELF(rowCount,colCount)<= 160
         PCMSELF(rowCount,colCount) = 152;
     elseif PCMSELF(rowCount,colCount)>= 161 && PCMSELF(rowCount,colCount)<= 175
         PCMSELF(rowCount,colCount) = 168;
     elseif PCMSELF(rowCount,colCount)>= 177 && PCMSELF(rowCount,colCount)<= 191
         PCMSELF(rowCount,colCount) = 184;
     elseif PCMSELF(rowCount,colCount)>= 193 && PCMSELF(rowCount,colCount)<= 207
         PCMSELF(rowCount,colCount) = 200;
     elseif PCMSELF(rowCount,colCount)>= 209 && PCMSELF(rowCount,colCount)<= 223
         PCMSELF(rowCount,colCount) = 216;
     elseif PCMSELF(rowCount,colCount)>= 225 && PCMSELF(rowCount,colCount)<= 239
         PCMSELF(rowCount,colCount) = 232;
     elseif PCMSELF(rowCount,colCount)>= 241 && PCMSELF(rowCount,colCount)<= 255
         PCMSELF(rowCount,colCount) = 248;
     elseif PCMSELF(rowCount,colCount)<= 0 && PCMSELF(rowCount,colCount)>= -15
         PCMSELF(rowCount,colCount) = -8;
     elseif PCMSELF(rowCount,colCount)<= -17 && PCMSELF(rowCount,colCount)>= -32
         PCMSELF(rowCount,colCount) = -24;
     elseif PCMSELF(rowCount,colCount)<= -33 && PCMSELF(rowCount,colCount)>= -47
         PCMSELF(rowCount,colCount) = -40;
     elseif PCMSELF(rowCount,colCount)<= -49 && PCMSELF(rowCount,colCount)>= -64
         PCMSELF(rowCount,colCount) = -56;
     elseif PCMSELF(rowCount,colCount)<= -65 && PCMSELF(rowCount,colCount)>= -79
         PCMSELF(rowCount,colCount) = -72;
     elseif PCMSELF(rowCount,colCount)<= -81 && PCMSELF(rowCount,colCount)>= -96
         PCMSELF(rowCount,colCount) = -88;
     elseif PCMSELF(rowCount,colCount)<= -97 && PCMSELF(rowCount,colCount)>= -111
         PCMSELF(rowCount,colCount) = -104;
     elseif PCMSELF(rowCount,colCount)<= -113 && PCMSELF(rowCount,colCount)>= -128
         PCMSELF(rowCount,colCount) = -120;
     elseif PCMSELF(rowCount,colCount)<= -129 && PCMSELF(rowCount,colCount)>= -143
         PCMSELF(rowCount,colCount) = -136;
     elseif PCMSELF(rowCount,colCount)<= -145 && PCMSELF(rowCount,colCount)>= -160
         PCMSELF(rowCount,colCount) = -152;
     elseif PCMSELF(rowCount,colCount)<= -161 && PCMSELF(rowCount,colCount)>= -175
         PCMSELF(rowCount,colCount) = -168;
     elseif PCMSELF(rowCount,colCount)<= -177 && PCMSELF(rowCount,colCount)>= -191
         PCMSELF(rowCount,colCount) = -184;
     elseif PCMSELF(rowCount,colCount)<= -193 && PCMSELF(rowCount,colCount)>= -207
         PCMSELF(rowCount,colCount) = -200;
     elseif PCMSELF(rowCount,colCount)<= -209 && PCMSELF(rowCount,colCount)>= -223
         PCMSELF(rowCount,colCount) = -216;
     elseif PCMSELF(rowCount,colCount)<= -225 && PCMSELF(rowCount,colCount)>= -239
         PCMSELF(rowCount,colCount) = -232;
     elseif PCMSELF(rowCount,colCount)<= -241 && PCMSELF(rowCount,colCount)>= -255
         PCMSELF(rowCount,colCount) = -248;
         
     end
end

%SNR calculation
SQNR=20*log10( norm(X )/norm (X-PCMSELF));
%Histogram
figure; 
histogram(PCMSELF);
title('PCM_Y (First Method)')
ylabel('Number of Elements');
xlabel('Range of Values');

%Reshape back to 512 by 512 image matrix
Y_PCM(:,:) = reshape(PCMSELF(:,:),[m,n]);
%Converts variable type back to uint8
PCM_Image = uint8(Y_PCM);
%Display image after quantization
figure;
imshow(PCM_Image);
title('PCM Y');

