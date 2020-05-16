%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: PCM
RGB = imread('lena512color.tiff');  %load the video and converts to double
 
%Y component of the Image
R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);
Y = 0.299 * R + 0.587 * G + 0.114 * B;
U = -0.14713 * R - 0.28886 * G + 0.436 * B;
V = 0.615 * R - 0.51499 * G - 0.10001 * B;
YUV = cat(3,Y,U,V);         %Concatenate Arrays 3x512x512
YUV1= Y;

p = Y;
p = double(p);
[m,n] = size(p(:,:));
%ALL pixel values in one row
X(:,:) = reshape(p(:,:),[1,(m*n)]);

%Quantization
inputSignal = X;                 %Assign input sign
L = 16;                         %Assign L level
sig_pmax =max(inputSignal) ;     %Finds positive peak of input signal
sig_nmax =min( inputSignal ) ;   %finding the negative peak of input signal
Delta = ( sig_pmax- sig_nmax )/L; %quantization interval 
q_level =sig_nmax+Delta/2 : Delta: sig_pmax-Delta/2 ; %defines Q-levels
L_sig=length( inputSignal ) ;    %find signal length
sigpeak= ( inputSignal- sig_nmax ) / Delta+1/2 ; % convert period into 1/2 to L+l/2 range
qindex=round( sigpeak ) ; % round to 1, 2, ... L levels
qindex=min( qindex , L ) ; % eleminate L+l as a rare possibility
q_out =q_level( qindex ) ; % use index vector to generate output
eOut = inputSignal-q_out;
eOut = round(eOut);
%SNR Calculation
SQNR=20 * log10( norm(inputSignal )/norm (eOut)); %actual SQNR value 
%Plot Histogram
figure; 
histogram(q_out);
title('PCM_Y');
ylabel('Number of Elements');
xlabel('Range of Values');
%Reshape back to 512 by 512 image matrix
Y_PCM(:,:) = reshape(q_out(:,:),[m,n]);
%Converts variable type back to uint8
PCM_Image = uint8(Y_PCM);
%Display image after quantization
figure;
imshow(PCM_Image);
title('PCM Y');
