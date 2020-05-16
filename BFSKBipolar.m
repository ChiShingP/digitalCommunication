%CHI SHING POON
%1001082535
%EE4330 PROJECT
%TASK: BFSK BIPOLAR
%CHANGE NOISE VARIANCE TO ADJUST SNR
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

C = reshape(Ebin',1,numel(Ebin)); % converted into bits
%D = str2bin(C);
D=num2str(C)-'0';

F = bin2dec(Ebin);

lineOut = zeros(size(D));
toggle = 0;
for j=1:length(D)
    if D(j) == 1
        if toggle == 0
            lineOut(j) = 1;
            toggle = 1;
        else
            if toggle == 1
                lineOut(j) = -1;
                toggle = 0;
            end
        end
    else
        if D(j) == 0
            lineOut(j) = 0;
        end
    end
end
bit_stream = lineOut;
figure;
% Enter the two frequencies 
% Frequency component for 0 bit
f1 = 1*10^6; 
% Frequency component for 1 bit
Rb = 1000;
Tb = 1/Rb; %Rb = 1kHz
df = 1*((2*pi*Tb));
% f2 = f1*df;
f2 = 16;
f3 = 9;
% Sampling rate - This will define the resoultion
fs = 100;

% Time for one bit
t = 0: Tb : 1;
% This time variable is just for plot
time = [];
FSK = [];
bits = [];
for ii = 1: 1: 20
    
    % The FSK Signal
    FSK = [FSK (bit_stream(ii)==0)*sin(2*pi*f1*t)+...
        (bit_stream(ii)==1)*sin(2*pi*f2*t)+(bit_stream(ii)==-1)*sin(2*pi*9*t)];
    
    % The Original Digital Signal
    bits = [bits (bit_stream(ii)==0)*...
        zeros(1,length(t)) + (bit_stream(ii)==1)*ones(1,length(t))+(bit_stream(ii)==-1)*ones(1*length(t))*-1];
    
    time = [time t];
    t =  t + 1;
   
end

% Plot the FSK Signal
subplot(2,1,1);
plot(time,FSK);
xlabel('Time (bit period)');
ylabel('Amplitude');
title('FSK Signal with two Frequencies');
axis([0 time(end) -1.5 1.5]);
grid  on;
% Plot the Original Digital Signal
subplot(2,1,2);
plot(time,bits,'r','LineWidth',2);
xlabel('Time (bit period)');
ylabel('Amplitude');
title('Original Digital Signal');
axis([0 time(end) -1.5 1.5]);
grid on;



%-------------------------------------------
%Adding Channel Noise
%-------------------------------------------

noiseVariance = .0016; %Noise variance of AWGN channel
noise = sqrt(noiseVariance)*randn(1,length(FSK));
noisySignal = FSK + noise;
figure;
plot(time,noisySignal);
xlabel('Time');
ylabel('Amplitude');
title('BPSK Modulated Data with AWGN noise (-20dB)');
% ylim([-1.5 1.5]);
Rb = 1000;
Fs=16*Rb;
% Fs = fs;
Tb =1/Rb;

%SNR 20log
X1 = FSK;
magX = norm(X1(:,:));
magError = norm(X1(:,:)- noisySignal(:,:));
SNR = 20*log10 (norm(magX)/norm(magError));

%BER Calculation
%____RCFILTER
FSKr = round(FSK);
for n = 1: length(FSKr)
    if FSKr(1,n) > 0
        FSK_BER(1,n) = FSKr(1,n);
    else
        FSK_BER(1,n) = -1*FSKr(1,n);
    end 
end
nS_R = round(noisySignal);
for n = 1: length(nS_R)
    if nS_R(1,n) > 0
        nS_BER(1,n) = nS_R(1,n);
    else
        nS_BER(1,n) = -1*nS_R(1,n);
    end 
end
%Bit Error
[num, ratio] = biterr(FSK_BER ,nS_BER)

% %Demodulation Using th Envelope Method
% % deFSK = [];
% % for ii = 1: 1: length(FSK)
% %     
% %     % The FSK Signal
% %     deFSK = [deFSK (FSK(ii)==0)*sin(2*pi*f1*t)+...
% %         (FSK(ii)==1)*sin(2*pi*f2*t+df)];
% %     
% % %     time = [time t];
% % %     t =  t + 1;
% %    
% % end
% [up, low] = envelope(FSK());
% % 
% % figure;
% % title('Envelope Detection');
% % xlabel('Time');
% % ylabel('Amplitude');
% % hold on;
% % plot(time, up,time, low);
% % hold off;
% 
% figure;
% title('Envelope Detection with half wave rectifier');
% xlabel('Time');
% ylabel('Amplitude');
% hold on;
% plot(time, up,time,low);
% hold off;
% % dem = FSK.*sin(2*pi*f2*time);
% % z1=trapz(time, dem);
% % zz1=round(2*z1/1);
% % figure;
% % plot(zz1);
% % dem = [];
% % for i = 1 :length(up)
% %     if up(i) >= 1       %Threshold for a positive pulse
% %         dem(i) = 1;
% %     else dem(i) = 0;
% %     end
% end
% % 
% % figure;
% % stairs(dem);
