clc;
clear;

N = 5; % 5개의 병렬 데이터 열로 전송
% N = 10; % 10개의 병렬 데이터 열로 전송

Ts = 1/N; % 부반송파의 심볼의 길이
T = N * Ts; % OFDM 심볼의 길이 

Tx = zeros(1,N); % Input Data
Rx = zeros(1,N); % Output Data
tot_sig = 0;

% QPSK 변조된 Input Data
for i = 1:N
 Tx(i) = exp(j*(-pi/4 + pi/2*i));
end

% 16_QAM 변조된 Input Data
% for i = 1:N
%     if i < 5
%         Tx(i) = 1/3 * (exp(j*(-pi/4 + pi/2*i)));
%     elseif i >= 5 && i < 13
%         Tx(i) = 1/2 * (exp(j*(-pi/8 + pi/4*(i-4))));
%     else
%         Tx(i) = exp(j*(-pi/4 + pi/2*(i-12)));
%     end
% end

% draw plot & subcarrier signaling
for i = 1:N
    % 부반송파의 개형
    t = linspace(0,T);
    subcarrier = exp(j*2*pi*t*i/T);
    subplot(N,6,(i-1)*6+1);
    plot(t,real(subcarrier),'b',t,imag(subcarrier),'r');
    title(['Subcarrier #' num2str(i)]);

    % Input Data의 개형
    x_Tx = linspace(0,real(Tx(i)));
    y_Tx = linspace(0,imag(Tx(i)));
    subplot(N,6,(i-1)*6+2)
    plot(x_Tx, y_Tx, 'b')
    hold on
    plot(0, 0, 'bx', 'MarkerSize', 10)
    hold on
    plot(real(Tx(i)),imag(Tx(i)),'bx', 'MarkerSize', 10);
    axis([-1, 1, -1, 1]);
    grid on;
    title(['Tx ang. #' num2str(i)]);

    % subcarrier signaling (subcarrier * Tx(i)) 이후 신호 합치기
    sub_sig = subcarrier * Tx(i);
    tot_sig = tot_sig + sub_sig;

    % sub_sig 개형
    subplot(N,6,(i-1)*6+3); 
    plot(t,real(sub_sig),'b',t,imag(sub_sig),'r');
    title(['Sub sig. #' num2str(i)]);

    % Tx_sig 개형
    subplot(N,6,2*6+4)
    plot(t,real(tot_sig),'b',t,imag(tot_sig),'r');
    title('Tx sig');

    % sub_sig의 역수의 개형
    MF = exp(-j*2*pi*t*i/T);
    subplot(N,6,(i-1)*6+5);
    plot(t,real(MF),'b',t,imag(MF),'r');
    title(['MF #' num2str(i)]);

    % 원 신호 복조 이후 행렬 Rx에 대입
    Rx_sig = tot_sig .* MF;
    Rx(i) = sum(Rx_sig) / length(t); 

    % Rx_sig 개형
    x_Rx = linspace(0,real(Rx(i)));
    y_Rx = linspace(0,imag(Rx(i)));
    subplot(N,6,(i-1)*6+6)
    plot(x_Rx, y_Rx, 'b')
    hold on
    plot(0, 0, 'bx', 'MarkerSize', 10)
    hold on
    plot(real(Rx(i)),imag(Rx(i)),'bx', 'MarkerSize', 10);
    axis([-1, 1, -1, 1]);
    grid on;
    title(['Rx ang. #' num2str(i)]);
end