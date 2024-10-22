% Function for generating Rayleigh channel coeffecients made in 2018 %

function [ch_coef, rx_power] = Rayleigh_channel(channel_shape, distance_rate, sig_power, profile)


% 구성 정보 확인
Multipath = channel_shape(1,1);

[~, c] = size(channel_shape);
if c ~= 1
    row = channel_shape(1,2);
else
    row = 1;
end


% 프로파일 생성
if nargin < 4
    % 기본 채널 프로파일
    CH_Profile = exp( -(1:Multipath) / 5 );
else
    % 입력 채널 프로파일
    CH_Profile = profile;
    [~, Multipath] = size(profile);
end


% 프로파일 정규화 및 반복
CH_Profile = ones(row,1) * CH_Profile / sum(CH_Profile);

% 프로파일과 랜덤 행렬의 곱
ch_coef = ( randn(row,Multipath) + 1j*randn(row,Multipath) ) * sqrt(0.5);
ch_coef = ch_coef .* sqrt(CH_Profile);


% 상대 거리 및 상대 전력 사용시
if nargin > 2
    
    % 일반적 3 ~ 4, 이상적 2
    exp_beta = 3;

    % 일반적 5 ~ 12, LTE: 10
    sigma = 0;
    shadowing = randn(1) * sigma;

    % + log10(k) : 송수신 안테나 gain 및 안테나로 인한 손실 = 1 로 정규화
    path_loss = -10 * exp_beta * log10(distance_rate); 

    % path loss 적용
    loss = 10^( (path_loss + shadowing) / 10);

    % 거리에 따른 수신 전력 적용
    ch_coef = ch_coef * sqrt(loss) * sqrt(sig_power);
    
    % 정규화 된 수신 전력
    rx_power = loss * sig_power;
    
else
    rx_power = 1;
    
end