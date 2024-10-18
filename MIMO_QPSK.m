clc;
clear all; close all;

Mt=2; Mr=2; % Mt : 송신 안테나의 개수, %Mr : 수신 안테나의 개수
N = 1; % BPSK 변조 방식의 사용
% N = 2; % QPSK 변조 방식의 사용

num = 1000;
iter = 1000;
p = 0 : 2 : 16; % 가로축의 범위 (dB)
kk = 1;

for dB = p  
    error_ZF = 0;
    error_MMSE = 0;
    error_ML = 0;

    for i = 1 : num
        Noise_power = 10^(-dB/10); % 신호 잡음 전력

        n = sqrt(Noise_power) * randn(Mr, iter); % BPSK Noise
        % n = sqrt(Noise_power/2)*(randn(Mr,iter) +1j*randn(Mr,iter)); % QPSK Noise
        
        H = randn(Mr,Mt); % BPSK 채널
        % H = (randn(Mr,Mt)+1j*randn(Mr,Mt))/sqrt(2); % QPSK 채널
        
        s = (2*randi([0,1],Mt,iter)-1)/sqrt(Mt); % BPSK 송신 신호
        % s = (2*randi([0,1],Mt,iter)-1+1j*(2*randi([0,1],Mt,iter)-1))/sqrt(Mt); % QPSK 송신 신호
        r = H*s +n; % 송신 데이터
        
        % ZF 검출 알고리즘의 구현
        G_zf = pinv(H); % ZF 방식의 가중치OP
        % G_zf = ctranspose(H) * inv(H * ctranspose(H))
        % G_zf = inv(H)
        z_zf = G_zf * r;

        % MMSE 검출 알고리즘의 구현
        G_MMSE = ctranspose(H) * inv(H * ctranspose(H) + Noise_power * eye(Mt)); % MMSE 방식의 가중치
        z_mmse = G_MMSE * r;

        % ML 검출 알고리즘의 구현
        % BPSK 심볼 리스트
        s_comp = [1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt), -1/sqrt(Mt);
                  1/sqrt(Mt), -1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt)];

        % QPSK 심볼 리스트
        % s_comp = [(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2);
        %     (1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2)];

        for ii = 1:iter
            list = repmat(r(:, ii), 1, 2^(N*Mt)) - H * s_comp; % 행렬 연산의 수행을 위해 repmat 함수를 이용해 배열 2*1의 행렬 r을 이어 붙힘
            comp = sqrt(sum(list.^2, 1)); % 변수 comp에 프로비니우스 놈 결과값 넣기
            [~, idx] = min(comp); % 프로비니우스 놈 결과값이 가장 작은 인덱스 출력
            z_ml(:, ii) = s_comp(:, idx); % s_comp에서 해당하는 인덱스의 심볼을 검출 값으로써 사용
        end
         
        % 비교하는 비트열
        data = sign(s); %sign : s와 동일한 크기의 배열 반환; 대응 요소가 0보다 크면 1, 작으면 -1, 같으면 0
        dec_data = reshape(data,1,Mt*iter);
       
        % ZF error sum
        dec_ZF = reshape(sign(z_zf),1,Mt*iter);
        error_ZF = error_ZF + sum(abs((dec_data-dec_ZF)/2));

        % MMSE error sum
        dec_mmse = reshape(sign(z_mmse),1,Mt*iter);
        error_MMSE = error_MMSE + sum(abs((dec_data-dec_mmse)/2));

        % ML error sum
        dec_ML = reshape(sign(z_ml),1,Mt*iter);
        error_ML = error_ML + sum(abs((dec_data-dec_ML)/2));
    end
    
    % ZF BER
    tot_zf_error(kk) = error_ZF;
    zf_ber(kk) = tot_zf_error(kk)/(Mt*iter*num);

    % MMSE BER
    tot_mmse_error(kk) = error_MMSE;
    mmse_ber(kk) = tot_mmse_error(kk)/(Mt*iter*num);

    % ML BER
    tot_ml_error(kk) = error_ML;
    ml_ber(kk) = tot_ml_error(kk)/(Mt*iter*num);

    kk = kk +1;
end

% plot
figure;
semilogy(p, zf_ber, '+-', p, mmse_ber, 'o-', p, ml_ber, 'x-');
hold on; grid on;
xlabel('Eb/N0') % X축 단위 표현
ylabel('BER')
legend('ZF', 'MMSE', 'ML');