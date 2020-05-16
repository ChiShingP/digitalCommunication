%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: LineCode ON OFF
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
%Store the next values of X in Y
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

Xhat(1,:) = ((rho(1,1)*(Ylinear(1,:)-E_y(1,1))*sigX(1,1))/sigY(1,1)) + E_x(1,1);
bV = (1-rho)*E_y; %Checking Value of b 
 
Xhat = double(Xhat);
%Error Signal or d[k] = actual - predicted
err1 = X - Xhat;    


%%%%%%%%%Quantization%%%%%%%%%
sig_in3 = err1;
L = 16;
sig_pmax3 =max(sig_in3) ;
sig_nmax3 =min( sig_in3 ) ; % finding the negative peak
Delta3 = ( sig_pmax3- sig_nmax3 ) /L; % quantization interval 
q_level3 =sig_nmax3+Delta3/2 : Delta3: sig_pmax3-Delta3/2 ; % de f ine Q-levels
L_sig =length( sig_in3 ) ; % find signal l ength
sigp3 = ( sig_in3- sig_nmax3 ) / Delta3 +1/2 ; % convert into 1/2 to L+ l/2 range
qindex3=round( sigp3 ) ; % round to 1, 2, ... L levels
qindex3=min( qindex3 , L ) ; % eleminate L+l as a rare possibility
q_out3 =q_level3( qindex3 ) ; % use index vec tor to generate output
eOut3 = sig_in3-q_out3;
eOut3 = round(eOut3);


%____RCFILTER
A = round(q_out3); %Rounded all values to an integer
for n = 1: length(A)
    if A(1,n) > 0
        E(1,n) = A(1,n);
    else
        E(1,n) = -1*A(1,n);
    end 
end
Ebin = dec2bin(E(1:20));
%Reshape for input
C = reshape(Ebin',1,numel(Ebin)); % converted into bits
D=num2str(C)-'0';


%RCF Parameters
Nsym = 2;           % Filter span in symbol durations
beta = 0.4;         % Roll-off factor
sampsPerSym = 20;    % Upsampling factor
rctFilt = comm.RaisedCosineTransmitFilter(...
  'Shape',                  'Normal', ...
  'RolloffFactor',          beta, ...
  'FilterSpanInSymbols',    Nsym, ...
  'OutputSamplesPerSymbol', sampsPerSym);
% Normalize to obtain maximum filter tap value of 1
b = coeffs(rctFilt);
rctFilt.Gain = 1/max(b.Numerator);

% Visualize the impulse response
fvtool(rctFilt, 'Analysis', 'impulse')
% Visualize the impulse response
fvtool(rctFilt, 'Analysis', 'impulse')

% Parameters
DataL = 20;             % Data length in symbols
% DataL = length(Q4E);
R = 1000;               % Data rate
Fs = R * sampsPerSym;   % Sampling frequency

% Create a local random stream to be used by random number generators for
% repeatability
hStr = RandStream('mt19937ar', 'Seed', 0);

% Generate random data
%  x = 2*randi(hStr, [0 1], DataL, 1)-1;
%Bit stream of first twenty pulses
x = zeros(20,1);
for i = 1: 20
    x(i,1) = D(1,i);
end

% Time vector sampled at symbol rate in milliseconds
tx = 1000 * (0: DataL - 1) / R;

% Filter
yo = rctFilt([x; zeros(Nsym/2,1)]);
% Time vector sampled at sampling frequency in milliseconds
to = 1000 * (0: (DataL+Nsym/2)*sampsPerSym - 1) / Fs;
% Plot data

fig1 = figure;
subplot(2,1,2);
stem(tx, x, 'kx'); hold on;
% Plot filtered data
plot(to, yo, 'b-'); hold off;
% Set axes and labels
axis([0 30 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude'); title('On Off with RCFilter');
legend('Transmitted Data', 'Upsampled Data', 'Location', 'southeast')
subplot(2,1,1);
stairs(x)
title('On Off Pulse');
 xlabel('Time (ms)'); ylabel('Amplitude');
ylim([-0.5 1.5]);
xlim([0 30]);