clear;
clc;

%Basic settings
Iteration = 10000;
p=1; 
FFT_Size = 128; 
GI_Size = FFT_Size / 4;
tot_Size = FFT_Size + GI_Size;
Multi_Path = 7;

%bits settings
bits_error = zeros(1,11);
bits_ber = zeros(1,11);
bits_CP = zeros(1,GI_Size);
bits_with_CP = zeros(1,tot_Size);
bits_sent_signal = zeros(1,tot_Size+Multi_Path-1);
bits_removed_CP = zeros(1,FFT_Size);

bits_order=4; % 1 for BPSK, 2 for QPSK, 4 for 16_QAM, 6 for 64_QAM, 8 for 256_QAM
bits_size=FFT_Size*bits_order;

for repeat = 1:1:Iteration
    for i = 0:1:10
        snr = i*3;
        bits_data=randi([0,1],1,bits_size); %데이터 비트열 생성
        bits_Mod=base_mod(bits_data,bits_order); %Modulation

        %IFFT
        bits_Mod = ifft(bits_Mod, FFT_Size) * sqrt(FFT_Size);

        %CP 얻어내기
        bits_CP(1:GI_Size) = bits_Mod(FFT_Size-GI_Size+1:FFT_Size); 
        
        %CP 붙히기
        bits_with_CP(1:GI_Size) = bits_CP;
        bits_with_CP(GI_Size+1:tot_Size) = bits_Mod(1:FFT_Size); 

        h = Rayleigh_channel(Multi_Path); %Rayleigh Channel (Time Domain)
        H = fft(h,FFT_Size); %Rayleigh Channel (Frequency Domain)
        
        %Channel passed signal
        [bits_sent_signal,bits_noise_power] = awgn_noise(conv(bits_with_CP,h),snr);

        %Remove Cyclic Prefix
        bits_removed_CP(1:FFT_Size) = bits_sent_signal(GI_Size+1:tot_Size);
        
        %FFT
        bits_removed_CP = fft(bits_removed_CP, FFT_Size) / sqrt(FFT_Size);

        %Equalization
        bits_removed_CP = bits_removed_CP./H;

        %Demodulation
        bits_demod=base_demod(bits_removed_CP,bits_order);

        for ii=1:1:bits_size
            if bits_demod(ii) ~= bits_data(ii)
                bits_error(i+1) = bits_error(i+1)+1;
            end
        end

    end
end

for i=1:1:11
    bits_ber(i) = bits_ber(i) + bits_error(i)/(bits_size*Iteration);
end

SNR = 0:3:30;
semilogy(SNR,bits_ber,'*-b');
grid;
axis([0 30 10^-6 1]);
xlabel('SNR(db)');
ylabel('BER');
legend('SISO-OFDM','Location','Northeast');
title('BER Performance');