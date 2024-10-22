clc;
clear;
close all;

%Basic settings
Iteration = 100;
p=1; %power
FFT_Size = 128;
GI_Size = FFT_Size / 4;
tot_Size = FFT_Size + GI_Size;
Multi_Path = 7;
Tx = 2; %송신단 안테나의 개수
Rx = 2; %수신단 안테나의 개수

%bits settings
bits_order=4; % 1 for BPSK, 2 for QPSK, 4 for 16_QAM, 6 for 64_QAM, 8 for 256_QAM
bits_size=FFT_Size*bits_order; %비트의 크기
bits_with_CPF = zeros(Tx,tot_Size);
bits_demod = zeros(5,FFT_Size*bits_order); %1행 = SISO기법, 2행 = SC기법, 3행 = EGC기법, 4행 = MRC 기법, 5행 = STBC 기법
error = zeros(5,11); %1행 = SISO기법, 2행 = SC기법, 3행 = EGC기법, 4행 = MRC 기법, 5행 = STBC 기법
ber = zeros(5,11); %1행 = SISO기법, 2행 = SC기법, 3행 = EGC기법, 4행 = MRC 기법, 5행 = STBC 기법
signal = zeros(Rx,tot_Size+Multi_Path-1); %1행 = Tx1->Rx1, 2행 = Tx1->Rx2 (Tx = 송신 안테나, Rx = 수신 안테나) 
TimeSlot_signal = zeros(Tx,tot_Size+Multi_Path-1); %STBC에서 1행 = TimeSlot 1에 온 신호, 2행 = TimeSlot 2에 온 신호
signal_removed_CPF = zeros(Rx,FFT_Size); 
TimeSlot_removed_CPF = zeros(Tx,FFT_Size);
removed_CPF_foreach = zeros(4,FFT_Size); %1행 = SISO기법, 2행 = SC기법, 3행 = EGC기법, 4행 = MRC 기법

for repeat = 1:1:Iteration
    for i = 0:1:10
        snr = i*3;
        data=randi([0,1],2,bits_size); %데이터 비트열 생성, 1행 = Tx1에서 나오는 비트열, 2행 = Tx2에서 나오는 비트열
        Modulation=base_mod(data,bits_order); %변조 수행, 1행 = Tx1에서 나오는 비트열, 2행 = Tx2에서 나오는 비트열
        
        %Rayleigh Channel (Time Domain)
        %1행 = Tx1->Rx1, 2행 = Tx1->Rx2, 3행 = Tx2->Rx1 (Tx = 송신 안테나, Rx = 수신 안테나)
        h = Rayleigh_channel([Multi_Path,3]);

        %Rayleigh Channel (Frequency Domain)
        %1행 = Tx1->Rx1, 2행 = Tx1->Rx2, 3행 = Tx2->Rx1 (Tx = 송신 안테나, Rx = 수신 안테나)
        H = zeros(3,FFT_Size);
        for ii = 1:1:3
            H(ii,:) = fft(h(ii,:),FFT_Size);
        end

        H1 = fft(h,FFT_Size,1);
        H3 = fft(h,FFT_Size,2);
        %IFFT 수행 및 CPF 붙히기, 1행 = Tx1에서 나오는 비트열, 2행 = Tx2에서 나오는 비트열
        CPF = zeros(2,GI_Size);
        for ii = 1:1:Tx
            Modulation_done(ii,:) = ifft(Modulation(ii,:), FFT_Size) * sqrt(FFT_Size); %IFFT
            CPF(ii,:) = Modulation_done(ii,FFT_Size-GI_Size+1:FFT_Size); %CPF 얻어내기
            bits_with_CPF(ii,1:GI_Size) = CPF(ii,:);
            bits_with_CPF(ii,GI_Size+1:tot_Size) = Modulation_done(ii,:);
        end

        IFFT1 = ifft(Modulation,FFT_Size,2) *sqrt(FFT_Size);
        CPF1 = [ IFFT1(:,FFT_Size-GI_Size+1:FFT_Size),IFFT1];

        %hx+n 구하기
        %1행 = Tx1->Rx1, 2행 = Tx1->Rx2 (Tx = 송신 안테나, Rx = 수신 안테나)
        for ii = 1:1:Rx
            [signal(ii,:),signal_np1] = awgn_noise(conv(bits_with_CPF(1,:),h(ii,:)),snr);
        end

        %STBC 기법의 송신단 구현
        [signal1,signal_T1np1] = awgn_noise(conv(bits_with_CPF(1,:),h(1,:)),snr);
        [signal2,signal_T1np2] = awgn_noise(conv(bits_with_CPF(1,:),h(3,:)),snr);
        TimeSlot_signal(1,:) = signal1 + signal2;

        [signal1,signal_T2np1] = awgn_noise(conv(-1*conj(bits_with_CPF(1,:)),h(1,:)),snr);
        [signal2,signal_T2np2] = awgn_noise(conv(conj(bits_with_CPF(1,:)),h(3,:)),snr);
        TimeSlot_signal(2,:) = -signal1 + signal2;

        %Remove Cyclic Prefix
        for ii = 1:1:Rx
            signal_removed_CPF(ii,:) = signal(ii,GI_Size+1:tot_Size); %1행 = Tx1->Rx1, 2행 = Tx1->Rx2 (Tx = 송신 안테나, Rx = 수신 안테나)
            TimeSlot_removed_CPF(ii,:) = TimeSlot_signal(ii,GI_Size+1:tot_Size); %1행 = Tx1->Rx1, 2행 = Tx2->Rx1 (Tx = 송신 안테나, Rx = 수신 안테나)
        end

        %FFT
        for ii = 1:1:Rx
            signal_removed_CPF(ii,:) = fft(signal_removed_CPF(ii,:), FFT_Size) / sqrt(FFT_Size); %1행 = Tx1->Rx1, 2행 = Tx1->Rx2 (Tx = 송신 안테나, Rx = 수신 안테나)
            TimeSlot_removed_CPF(ii,:) = fft(TimeSlot_removed_CPF(ii,:), FFT_Size) / sqrt(FFT_Size); %1행 = Tx1->Rx1, 2행 = Tx2->Rx1 (Tx = 송신 안테나, Rx = 수신 안테나)
        end

        %Equalization for SISO
        removed_CPF_foreach(1,:) = signal_removed_CPF(1,:) ./ H(1,:);
        
        %SC 기법의 구현
        for ii = 1:1:FFT_Size
            if abs(H(1,ii))^2 > abs(H(2,ii))^2
                removed_CPF_foreach(2,ii) = signal_removed_CPF(1,ii) / H(1,ii);
            else
                removed_CPF_foreach(2,ii) = signal_removed_CPF(2,ii) / H(2,ii);
            end
        end        

        %EGC 기법의 구현
        for ii = 1:1:FFT_Size
            angle1 = atan(imag(H(1,ii))/real(H(1,ii))); angle2 = atan(imag(H(2,ii))/real(H(2,ii)));
            removed_CPF_foreach(3,ii) = signal_removed_CPF(1,ii)*conj(exp(j*angle1))+signal_removed_CPF(2,ii)*conj(exp(j*angle2));
            removed_CPF_foreach(3,ii) = removed_CPF_foreach(3,ii) / (H(1,ii)*conj(exp(j*angle1))+H(2,ii)*conj(exp(j*angle2))); %Equalization for EGC
        end

        H_conj_1 = H(1,:)./abs(H(1,:));
        H_conj_2 = H(2,:)./abs(H(2,:));
        
        egc1 =signal_removed_CPF(1,:).*conj(H_conj_1) + signal_removed_CPF(2,:) .*conj(H_conj_2) ;
        equl_egc = egc1 ./ (abs(H(1,:))+abs(H(2,:)));
        demod_egc = base_demod(equl_egc,bits_order);


        %MRC 기법의 구현
        for ii = 1:1:FFT_Size
            angle1 = atan(imag(H(1,ii))/real(H(1,ii))); angle2 = atan(imag(H(2,ii))/real(H(2,ii)));
            removed_CPF_foreach(4,ii) = signal_removed_CPF(1,ii)*conj(H(1,ii))+signal_removed_CPF(2,ii)*conj(H(2,ii));
            removed_CPF_foreach(4,ii) = removed_CPF_foreach(4,ii) / ((H(1,ii)*exp(-j*angle1))^2+(H(2,ii)*exp(-j*angle2))^2); %Equalization for MRC
        end

        %STBC 기법의 수신단 구현
        bits1 = zeros(1,FFT_Size); bits2 = zeros(1,FFT_Size);
        for ii = 1:1:FFT_Size
            angle1 = atan(imag(H(1,ii))/real(H(1,ii))); angle2 = atan(imag(H(3,ii))/real(H(3,ii)));
            bits1(1,ii) = conj(H(1,ii))*TimeSlot_removed_CPF(1,ii)+H(3,ii)*conj(TimeSlot_removed_CPF(2,ii));
            bits1(1,ii) = bits1(1,ii) / (abs(H(1,ii)*exp(-j*angle1))^2+abs(H(3,ii)*exp(-j*angle2))^2);
            bits2(1,ii) = conj(H(3,ii))*TimeSlot_removed_CPF(1,ii)-H(1,ii)*conj(TimeSlot_removed_CPF(2,ii));
            bits2(1,ii) = bits2(1,ii) / (abs(H(1,ii)*exp(-j*angle1))^2+abs(H(3,ii)*exp(-j*angle2))^2);
        end

        %Demodulation
        for ii = 1:1:4
            bits_demod(ii,:)=base_demod(removed_CPF_foreach(ii,:),bits_order);
        end
        
        bits1_demod = base_demod(bits1,bits_order);
        bits2_demod = base_demod(bits2,bits_order);

        %bits1_demod=


        for ii = 1:1:4
            for iii=1:1:bits_size
                if bits_demod(ii,iii) ~= data(1,iii)
                    error(ii,i+1) = error(ii,i+1)+1;
                end
            end
        end
        for ii = 1:1:bits_size
            if bits1_demod(ii) ~= data(1,ii)
                error(5,i+1) = error(5,i+1)+1;
            end
            if bits2_demod(ii) ~= data(2,ii)
                error(5,i+1) = error(5,i+1)+1;
            end
        end
    end
end

for i=1:1:4
    for ii=1:1:11
        ber(i,ii) = ber(i,ii) + error(i,ii)/(bits_size*Iteration);
    end
end
for ii = 1:1:11
    ber(5,ii) = ber(5,ii) + error(5,ii)/(2*bits_size*Iteration);
end

SNR = 0:3:30;

semilogy(SNR,ber(1,:),'*-r',SNR,ber(2,:),'*-g',SNR,ber(3,:),'*-b',SNR,ber(4,:),'*-k',SNR,ber(5,:),'*-m');
grid;
axis([0 30 10^-5 1]);
xlabel('SNR(db)');
ylabel('BER');
legend('SISO','SC','EGC','MRC','STBC','Location','Northeast');
title('BER Performance');

