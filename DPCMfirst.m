%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: DPCM First Order
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

%DPCM 1st
%ORDER------------------------------------------------------
%Store the shifted values of X in Y
for count = 1:((m*n)-1)
    Ylinear(1,count) = X(1,count+1);
end
Ylinear(1,262144) = X(1,1);    %Set the last value of Y2 = X(1)

%Xhat Calculation
XY = double(X.*Ylinear);     %Multiplying the X and Y arrays together
%Expected Values
E_x(1,1) = mean(X(:,:));
E_y(1,1) = mean(Ylinear(:,:));
E_xy(1,1) = mean(XY(:,:));
 
%calculating the prediction coefficients
sigX(1,1) = std(X(:,:)); 
sigY(1,1) = std(Ylinear(:,:));
rho(1,1) = (E_xy(1,1) - (E_x(1,1) * E_y(1,1)))/((sigX(1,1) * sigY(1,1)));

%Calculating Xhat
Xhat(1,:) = ((rho(1,1)*(Ylinear(1,:)-E_y(1,1))*sigX(1,1))/sigY(1,1)) + E_x(1,1);
bV = (1-rho)*E_y; %Checking Value of b 
Xhat = double(Xhat);

%Error Signal or d[k] = actual - predicted
err = X - Xhat;    
err2 = err;
err1q = zeros(1,262144);


%%%%%Quantization 
sigal_in = err2;
L = 16;
sig_pmax =max(sigal_in) ;
sig_nmax =min( sigal_in ) ; % finding the negative peak
Delta = ( sig_pmax- sig_nmax ) /L; % quantization interval 
q_level =sig_nmax+Delta/2 : Delta: sig_pmax-Delta/2 ; % de f ine Q-levels
L_sig=length( sigal_in ) ; % find signal l ength
sigpeak= ( sigal_in- sig_nmax ) / Delta+1/2 ; % convert into 1/2 to L+ l/2 range
qindex=round( sigpeak ) ; % round to 1, 2, ... L levels
qindex=min( qindex , L ) ; % eleminate L+l as a rare possibility
q_out =q_level( qindex ) ; % use index vec tor to generate output


%plots histogram of quantized error
figure;
% subplot(1,2,1);
% histogram(err1q);
% title('For Loop Quantization DPCM');
% subplot(1,2,2);
histogram(q_out);
title('Quantized Error Signal (1st Order)');
xlabel('Range of Values');
ylabel('Amount of Values');



%Receiver
%From Quantization with better result
XqStep = q_out + Xhat;
X_ReStep(:,:) = reshape(XqStep(:,:),[m,n]);
X_ReStep = uint8(X_ReStep);

%Display Predicted Image
figure;
imshow(X_ReStep);
title('Recontructed after DPCM (1st Order)');
%SNR Calculation
magX = norm(X(:,:));
magErrorS = norm(X(:,:)- XqStep(:,:));
SNR_DCPM1S = 20*log10 (norm(magX)/norm(magErrorS));
