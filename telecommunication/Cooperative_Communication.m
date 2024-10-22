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
bits_SISO_ber = zeros(1,11);
bits_SISO_error = zeros(1,11);
bits_AF_ber = zeros(1,11);
bits_AF_error = zeros(1,11);
bits_AF_combf2 = zeros(1,FFT_Size);
bits_DF_ber = zeros(1,11);
bits_DF_error = zeros(1,11);
bits_CPF = zeros(1,GI_Size);
bits_with_CPF = zeros(1,tot_Size);
rebitssr_with_CPF = zeros(1,FFT_Size+GI_Size);
bitsrd_with_CPF = zeros(1,FFT_Size+GI_Size);
rebitsrd_with_CPF = zeros(1,FFT_Size+GI_Size);
bits_sdsent_signal = zeros(1,FFT_Size+GI_Size+Multi_Path-1);
bits_srsent_signal = zeros(1,FFT_Size+GI_Size+Multi_Path-1);
bits_srcomb_signal = zeros(1,FFT_Size);
bits_sdremoved_CPF = zeros(1,FFT_Size);
bits_srremoved_CPF = zeros(1,FFT_Size);
bits_rdremoved_CPF = zeros(1,FFT_Size);
rebits_rdremoved_CPF = zeros(1,FFT_Size);
bits_SISOtot_signal = zeros(1,FFT_Size);
bits_AFtot_signal = zeros(1,FFT_Size);
bits_DFtot_signal = zeros(1,FFT_Size);

bits_order=4; % 1 for BPSK, 2 for QPSK, 4 for 16_QAM, 6 for 64_QAM, 8 for 256_QAM
bits_size=FFT_Size*bits_order;

for repeat = 1:1:Iteration
    for i = 0:1:10
        snr = i*3;
        bits_data=randi([0,1],1,bits_size); %데이터 비트열 생성
        bits_Mod=base_mod(bits_data,bits_order); %Modulation
        bits_Mod = ifft(bits_Mod, FFT_Size) * sqrt(FFT_Size); %IFFT
        bits_CPF = bits_Mod(FFT_Size-GI_Size+1:FFT_Size); %CPF 얻어내기

        %CPF 붙히기
        bits_with_CPF(1:GI_Size) = bits_CPF;
        bits_with_CPF(GI_Size+1:tot_Size) = bits_Mod; 

        %Rayleigh Channel (Time Domain)
        h_sd = Rayleigh_channel(Multi_Path); %channel for sender to destination
        h_sr = Rayleigh_channel(Multi_Path); %channel for sender to relay
        h_rd = Rayleigh_channel(Multi_Path); %channel for relay to destination

        %Rayleigh Channel (Frequency Domain)
        H_sd = fft(h_sd,FFT_Size); %channel for sender to destination
        H_sr = fft(h_sr,FFT_Size); %channel for sender to relay
        H_rd = fft(h_rd,FFT_Size); %channel for relay to destination

        %Channel passed signal
        [bits_sdsent_signal,bits_sdnoise_power] = awgn_noise(sqrt(p)*conv(bits_with_CPF,h_sd),snr); %signals from source to destination
        [bits_srsent_signal,bits_srnoise_power] = awgn_noise(sqrt(p)*conv(bits_with_CPF,h_sr),snr); %signals from source to relay

        %Remove Cyclic Prefix
        bits_sdremoved_CPF = bits_sdsent_signal(GI_Size+1:tot_Size); %signals from source to destination
        bits_srremoved_CPF = bits_srsent_signal(GI_Size+1:tot_Size); %signals from source to relay

        %FFT
        bits_srremoved_CPF = fft(bits_srremoved_CPF, FFT_Size) / sqrt(FFT_Size); %signals from source to relay
        
        %multiply amplify factors and resend for AF Method
        bits_amplify_factor = sqrt(p)./sqrt(p*abs(H_sr).^2+bits_srnoise_power);
        bits_srcomb_signal = bits_amplify_factor .* bits_srremoved_CPF;

        bits_srcomb_signal = ifft(bits_srcomb_signal, FFT_Size) * sqrt(FFT_Size); %IFFT
        bits_CPF = bits_srcomb_signal(FFT_Size-GI_Size+1:FFT_Size); %CPF 얻어내기 (relay to destination)

        %CPF 붙히기 (relay to destination)
        bits_with_CPF(1:GI_Size) = bits_CPF;
        bits_with_CPF(GI_Size+1:tot_Size) = bits_srcomb_signal;

        %Channel passed signal
        [bits_rdsent_signal,bits_rdnoise_power] = awgn_noise(sqrt(p)*conv(bits_with_CPF,h_rd),snr); %signals from relay to destination

        %Demodulate and Remodulate for DF Method
        bits_srremoved_CPF = bits_srremoved_CPF ./ H_sr; %Demodulation을 위해 relay에서 Equalization 수행
        bits_srdemod = base_demod(bits_srremoved_CPF,bits_order); %Demodulation
        bits_srremod = base_mod(bits_srdemod,bits_order); %Remodulation
        bits_Mod = ifft(bits_srremod, FFT_Size) * sqrt(FFT_Size); %IFFT
        bits_CPF(1:GI_Size) = bits_Mod(FFT_Size-GI_Size+1:FFT_Size); %CPF 얻어내기

        %CPF 붙히기 (relay to destination)
        rebitssr_with_CPF(1:GI_Size) = bits_CPF;
        rebitssr_with_CPF(GI_Size+1:tot_Size) = bits_Mod;

        %Channel passed signal
        [rebits_rdsent_signal,rebits_rdnoise_power] = awgn_noise(sqrt(p)*conv(rebitssr_with_CPF,h_rd),snr); %signals from relay to destination

        %Remove Cyclic Prefix
        bits_rdremoved_CPF = bits_rdsent_signal(GI_Size+1:tot_Size); %AF
        rebits_rdremoved_CPF = rebits_rdsent_signal(GI_Size+1:tot_Size); %DF
        
        %FFT
        bits_sdremoved_CPF = fft(bits_sdremoved_CPF, FFT_Size) / sqrt(FFT_Size); %signals from source to destination
        bits_rdremoved_CPF = fft(bits_rdremoved_CPF, FFT_Size) / sqrt(FFT_Size); %signals from relay to destination (AF)
        rebits_rdremoved_CPF = fft(rebits_rdremoved_CPF, FFT_Size) / sqrt(FFT_Size); %signals from relay to destination (DF)
        
        %combination factors for AF
        bits_AF_combf1 = sqrt(p)*conj(H_sd)/bits_sdnoise_power;
        for ii=1:1:FFT_Size
            bits_AF_combf2(ii) = (bits_amplify_factor(ii)*sqrt(p)*conj(H_sr(ii))*conj(H_rd(ii)))/(((bits_amplify_factor(ii)^2*abs(H_rd(ii))^2)+1)*bits_rdnoise_power);
        end

        %combination factors for DF
        bits_DF_combf1 = sqrt(p)*conj(H_sd)/bits_sdnoise_power;
        bits_DF_combf2 = sqrt(p)*conj(H_rd)/bits_rdnoise_power;
        
        %y = a1ys,d+a2yr,d
        bits_AFtot_signal = bits_AF_combf1.*bits_sdremoved_CPF + bits_AF_combf2.*bits_rdremoved_CPF;
        bits_DFtot_signal = bits_DF_combf1.*bits_sdremoved_CPF + bits_DF_combf2.*rebits_rdremoved_CPF;
        
        %Equalization for SISO, AF and DF
        for ii=1:1:FFT_Size
            bits_SISOtot_signal(ii) = bits_sdremoved_CPF(ii) / H_sd(ii);
            bits_AFtot_signal(ii) = bits_AFtot_signal(ii) / (sqrt(p)*(bits_AF_combf1(ii)*H_sd(ii)+bits_AF_combf2(ii)*bits_amplify_factor(ii)*H_rd(ii)*H_sr(ii)));
            bits_DFtot_signal(ii) = bits_DFtot_signal(ii) / (sqrt(p)*(bits_DF_combf1(ii)*H_sd(ii)+bits_DF_combf2(ii)*H_rd(ii)));
        end

        %Demodulation
        bits_SISOdemod = base_demod(bits_SISOtot_signal,bits_order);
        bits_AFdemod = base_demod(bits_AFtot_signal,bits_order);
        bits_DFdemod = base_demod(bits_DFtot_signal,bits_order);

        for ii=1:1:bits_size
            if bits_SISOdemod(ii) ~= bits_data(ii)
                bits_SISO_error(i+1) = bits_SISO_error(i+1)+1;
            end
            if bits_AFdemod(ii) ~= bits_data(ii)
                bits_AF_error(i+1) = bits_AF_error(i+1)+1;
            end
            if bits_DFdemod(ii) ~= bits_data(ii)
                bits_DF_error(i+1) = bits_DF_error(i+1)+1;
            end
        end
    end
end

for i=1:1:11
    bits_SISO_ber(i) = bits_SISO_ber(i) + bits_SISO_error(i)/(bits_size*Iteration);
    bits_AF_ber(i) = bits_AF_ber(i) + bits_AF_error(i)/(bits_size*Iteration);
    bits_DF_ber(i) = bits_DF_ber(i) + bits_DF_error(i)/(bits_size*Iteration);
end

SNR = 0:3:30;
semilogy(SNR,bits_SISO_ber,'*-r',SNR,bits_AF_ber,'*-b',SNR,bits_DF_ber,'*-g');
grid;
axis([0 30 10^-5 1]);
xlabel('SNR');
ylabel('BER');
legend('SISO-OFDM','AF-OFDM','DF-OFDM','Location','Northeast');
title('BER Performance');