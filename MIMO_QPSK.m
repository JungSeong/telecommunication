clc;
clear all; close all;

Mt=2; Mr=2; % Mt : �۽� ���׳��� ����, %Mr : ���� ���׳��� ����
N = 1; % BPSK ���� ����� ���
% N = 2; % QPSK ���� ����� ���

num = 1000;
iter = 1000;
p = 0 : 2 : 16; % �������� ���� (dB)
kk = 1;

for dB = p  
    error_ZF = 0;
    error_MMSE = 0;
    error_ML = 0;

    for i = 1 : num
        Noise_power = 10^(-dB/10); % ��ȣ ���� ����

        n = sqrt(Noise_power) * randn(Mr, iter); % BPSK Noise
        % n = sqrt(Noise_power/2)*(randn(Mr,iter) +1j*randn(Mr,iter)); % QPSK Noise
        
        H = randn(Mr,Mt); % BPSK ä��
        % H = (randn(Mr,Mt)+1j*randn(Mr,Mt))/sqrt(2); % QPSK ä��
        
        s = (2*randi([0,1],Mt,iter)-1)/sqrt(Mt); % BPSK �۽� ��ȣ
        % s = (2*randi([0,1],Mt,iter)-1+1j*(2*randi([0,1],Mt,iter)-1))/sqrt(Mt); % QPSK �۽� ��ȣ
        r = H*s +n; % �۽� ������
        
        % ZF ���� �˰����� ����
        G_zf = pinv(H); % ZF ����� ����ġOP
        % G_zf = ctranspose(H) * inv(H * ctranspose(H))
        % G_zf = inv(H)
        z_zf = G_zf * r;

        % MMSE ���� �˰����� ����
        G_MMSE = ctranspose(H) * inv(H * ctranspose(H) + Noise_power * eye(Mt)); % MMSE ����� ����ġ
        z_mmse = G_MMSE * r;

        % ML ���� �˰����� ����
        % BPSK �ɺ� ����Ʈ
        s_comp = [1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt), -1/sqrt(Mt);
                  1/sqrt(Mt), -1/sqrt(Mt), 1/sqrt(Mt), -1/sqrt(Mt)];

        % QPSK �ɺ� ����Ʈ
        % s_comp = [(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1+1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(1-1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1+1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2),(-1-1j)/sqrt(2);
        %     (1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2),(1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1+1j)/sqrt(2), (-1-1j)/sqrt(2)];

        for ii = 1:iter
            list = repmat(r(:, ii), 1, 2^(N*Mt)) - H * s_comp; % ��� ������ ������ ���� repmat �Լ��� �̿��� �迭 2*1�� ��� r�� �̾� ����
            comp = sqrt(sum(list.^2, 1)); % ���� comp�� ���κ�Ͽ콺 �� ����� �ֱ�
            [~, idx] = min(comp); % ���κ�Ͽ콺 �� ������� ���� ���� �ε��� ���
            z_ml(:, ii) = s_comp(:, idx); % s_comp���� �ش��ϴ� �ε����� �ɺ��� ���� �����ν� ���
        end
         
        % ���ϴ� ��Ʈ��
        data = sign(s); %sign : s�� ������ ũ���� �迭 ��ȯ; ���� ��Ұ� 0���� ũ�� 1, ������ -1, ������ 0
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
xlabel('Eb/N0') % X�� ���� ǥ��
ylabel('BER')
legend('ZF', 'MMSE', 'ML');