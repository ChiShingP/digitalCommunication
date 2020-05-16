%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: DPCM Third Order
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
%Third Order Predictor
%Store the next values of X in Y
%X shifted Once to the right 
for count = 1:((m*n)-1)
    y1(1,count) = X(1,count+1);
end
y1(1,262144) = X(1,1);    %Set the last value of Y1 = X(1)

%Y2 is the pixel diagonnally left(n -1, m - 1) of the current pixel 
%values are stored in a form of 512x512 then converted to row vector
y1m(:,:) = reshape(y1(:,:),[m,n]);
for rCount = 512:-1: 2
    for mCount = 1: 512
        y2m(rCount,mCount) = y1m(rCount-1, mCount);
    end
end
for mCount = 1:512
    y2m(1,mCount) = y1m(512,mCount);
end
y2 = zeros(size(X));
y2(:,:) = reshape(y2m(:,:),[1,(262144)]);

%y3 is the pixel directly above the current pixel.
%values are stored in a form of 512x512 then converted to row vector
for rCount = 512:-1: 2
    for mCount = 1: 512
        y3m(rCount,mCount) = p(rCount-1, mCount);
    end
end
for mCount = 1:512
    y3m(1,mCount) = p(512,mCount);
end
y3 = zeros(size(X));
y3(:,:) = reshape(y3m(:,:),[1,(262144)]);

% Gets the determinant to find the a,b,c values
D  = (mean2(y1.^2) .*mean2(y2.^2) .*mean2(y3.^2))-(mean2(y1.^2) .*mean2(y2.*y3).*mean2(y2.*y3))...
    -(mean2(y1.*y2).*mean2(y1.*y2).*mean2(y3.^2))+2*(mean2(y1.*y2).*mean2(y2.*y3).*mean2(y1.*y3))...
    -(mean2(y1.*y3).*mean2(y2.^2) .*mean2(y1.*y3));

Da = (mean2(X.*y1) .*mean2(y2.^2) .*mean2(y3.^2))-(mean2(X.*y1) .*mean2(y2.*y3).*mean2(y2.*y3))-...
    (mean2(y1.*y2).*mean2(X.*y2) .*mean2(y3.^2))+(mean2(y1.*y2).*mean2(y2.*y3).*mean2(X.*y3))+...
    (mean2(y1.*y3).*mean2(X.*y2) .*mean2(y2.*y3))-(mean2(y1.*y3).*mean2(y2.^2) .*mean2(X.*y3));

Db = (mean2(y1.^2) .*mean2(X.*y2) .*mean2(y3.^2))-(mean2(y1.^2) .*mean2(X.*y3) .*mean2(y2.*y3))-...
    (mean2(X.*y1) .*mean2(y1.*y2).*mean2(y3.^2))+(mean2(X.*y1) .*mean2(y1.*y3).*mean2(y2.*y3))+...
    (mean2(y1.*y3).*mean2(y1.*y2).*mean2(X.*y3))-(mean2(y1.*y3).*mean2(X.*y2) .*mean2(y1.*y3));

Dc = (mean2(y1.^2) .*mean2(y2.^2) .*mean2(X.*y3))-(mean2(y1.^2) .*mean2(X.*y2) .*mean2(y2.*y3))-...
    (mean2(y1.*y2).*mean2(y1.*y2).*mean2(X.*y3))+(mean2(y1.*y2).*mean2(X.*y2) .*mean2(y1.*y3))+...
    (mean2(X.*y1) .*mean2(y1.*y2).*mean2(y2.*y3))-(mean2(y2.^2) .*mean2(y1.*y3).*mean2(X.*y1));


%Gets a, b, and c values from cramer's rule
a=Da./D;
b=Db./D;
c=Dc./D;
 
%Xhat equation 
%This X_HAT IS MARGINALLY lower than the Xhat from 1st Order
Xhat3=a.*y1+b.*y2+c.*y3;
e3 = X - Xhat3;
e4= e3;

%Quantization
sigal_in3 = e4;
L = 16;
sig_pmax3 =max(sigal_in3) ;
sig_nmax3 =min( sigal_in3 ) ; % finding the negative peak
Delta3 = ( sig_pmax3- sig_nmax3 ) /L; % quantization interval 
q_level3 =sig_nmax3+Delta3/2 : Delta3: sig_pmax3-Delta3/2 ; % de f ine Q-levels
L_sig =length( sigal_in3 ) ; % find signal l ength
sigpeak3 = ( sigal_in3- sig_nmax3 ) / Delta3 +1/2 ; % convert into 1/2 to L+ l/2 range
qindex3=round( sigpeak3 ) ; % round to 1, 2, ... L levels
qindex3=min( qindex3 , L ) ; % eleminate L+l as a rare possibility
q_out3 =q_level3( qindex3 ) ; % use index vec tor to generate output


%Histograms
figure;
histogram(q_out3);
title('Quantized Error Signal (3rd Order)');
xlabel('Range of Values');
ylabel('Amount of Values');



Xq3S = q_out3 + Xhat3;

%SNR
% magError3 = norm(X(:,:)- Xq3(:,:));
% SNR_DCPM3 = 20*log10 (norm(magX)/norm(magError3));
magError3S = norm(X(:,:)- Xq3S(:,:));
SNR_DCPM3S = 20*log10 (norm(magX)/norm(magError3S));

%Step yields a smaller value which makes sense
X_ReStep3(:,:) = reshape(Xq3S(:,:),[m,n]);
X_ReStep3 = uint8(X_ReStep3);
%display Image
figure;
imshow(X_ReStep3);
title("Reconstructed after DPCM (3rd Order)");


%SNR IMPROVEMENT 
(norm(X).^2)/(norm(q_out).^2)

