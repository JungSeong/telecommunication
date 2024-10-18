clc;
clear all; close all;

Mt=2;Mr=2;

num = 1000;
iter = 1000;
p = 0 : 2 : 16;
kk = 1;

for dB = p  
    error_ZF = 0;
    error_MMSE = 0;
    error_ML = 0;

    for i = 1 : num
        Noise_power = 10^(-dB/10);
        n = sqrt(Noise_power)*(randn(Mr,iter));
        H = randn(Mr,Mt); %(randn(Mr,Mt)+1j*randn(Mr,Mt))/sqrt(2);
        s = (2*randi([0,1],Mt,iter)-1)/sqrt(Mt);
        r = H*s +n;
        
        %ZF
        G_zf = pinv(H);
        z_zf = G_zf * r;

        %MMSE
        G_MMSE = ctranspose(H) * inv(H * ctranspose(H) + Noise_power * eye(2));
        z_mmse = G_MMSE * r;
   
        %ML
        s_comp = [1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt), -1/sqrt(Mt);
                  1/sqrt(Mt), -1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt)];
        for k = 1:iter
            list = repmat(r(:, k), 1, 4) - H * s_comp;
            comp = sqrt(sum(list.^2, 1));
            [~, idx] = min(comp);
            z_ml(:, k) = s_comp(:, idx);
        end

        % demodulation
        data = sign(s); dec_data = reshape(data,1,Mt*iter);
        
        % ZF recovery
        dec_zf = reshape(sign(z_zf),1,Mt*iter);
        error_ZF =error_ZF + sum(abs((dec_data-dec_zf)/2));

        % MMSE recovery
        dec_mmse = reshape(sign(z_mmse),1,Mt*iter);
        error_MMSE = error_MMSE + sum(abs((dec_data-dec_mmse)/2));
            
        % ML recovery
        dec_ML = reshape(sign(z_ml),1,Mt*iter);
        error_ML = error_ML + sum(abs((dec_data-dec_ML)/2));
    end

    tot_zf_error(kk) = error_ZF;
    zf_ber(kk) = tot_zf_error(kk)/(Mt*iter*num);

    tot_mmse_error(kk) = error_MMSE;
    mmse_ber(kk) = tot_mmse_error(kk)/(Mt*iter*num);

    tot_ml_error(kk) = error_ML;
    ml_ber(kk) = tot_ml_error(kk)/(Mt*iter*num);
    
    kk = kk +1;
end

figure;
semilogy(p, zf_ber, '+-', p, mmse_ber, 'o-', p, ml_ber, 'x-');
hold on; grid on;
xlabel('Eb/N0') % X축 단위 표현
ylabel('BER')
legend('ZF', 'MMSE', 'ML');