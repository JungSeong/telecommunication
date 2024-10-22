%base demodulation function using gray code with normalization (08.11.28)
%
% ex) demod_data = base_demod(mod_data,mod_scheme)
%  mod_scheme : BPSK  = 1
%               QPSK  = 2
%               16QAM = 4
%               64QAM = 6
%               256QAM = 8
%
% QPSK성상도
%  10 | 11
%-----------
%  00 | 01
%
% 16QAM 성상도
% 0010 0110 | 1110 1010
% 0011 0111 | 1111 1011
%-----------------------
% 0001 0101 | 1101 1001
% 0000 0100 | 1100 1000


function [demod_data] = base_demod(mod_data,mod_scheme)
% 실수 허수로 나눈다.
RE = real(mod_data);
IM = imag(mod_data);

if mod_scheme == 1         % BPSK demodulation
    demod_data = (mod_data>0)*1; % 0보다 크면 1 아니면 0
    
elseif mod_scheme == 2     % QPSK demodulation
% 행 1 렬 모드데이터길이 원데이터의 1/2
    [MP_row,MP_col]=size(mod_data);  
% 뽑아낸 허수부가 홀수번째 데이터, 크면1 작으면 0 이된다.
    odd_data = (IM>0)*1;  % 홀수 복조
    % 마찬가지
    even_data = (RE>0)*1; % 짝수 복조
    % temp에 뽑아낸 홀수번째 짝수번째 데이터 입력
    temp = [odd_data;even_data];
    % reshape로 2x? 행렬을 MP_row x MP_col*2 로 재배치. ( odd는 홀수번째, even은 짝수번째)
    demod_data = reshape(temp,MP_row,MP_col*2);
    
elseif mod_scheme == 4     % 16QAM demodulation
    % 마찬가지 col은 원 데이터의 1/4
    [MP_row,MP_col]=size(mod_data);  
    % 0 보다 큰지
    first = (RE>0)*1;
    % 절대값이 0.6325를 넘는지 , first와 second가 같지 않앗다면 넘을것이고 아니면 안넘을것.
    second = (abs(RE)<0.6325)*1;
    % 허수부 0보다 큰지
    third = (IM>0)*1;
    % 허수부 절대값 0.6325 보다 큰지 위와 마찬가지
    fourth = (abs(IM)<0.6325)*1;
    temp = [first;second;third;fourth];
    
    demod_data = reshape(temp,MP_row,MP_col*4);
    
elseif mod_scheme == 6     % 64QAM demodulation
    
    [MP_row,MP_col]=size(mod_data);      
    
    first = (RE>0)*1;
    second = (abs(RE)<0.6172)*1;
    third = ((abs(RE)>0.3086)&(abs(RE)<0.9528))*1;
    fourth = (IM>0)*1;
    fifth = (abs(IM)<0.6172)*1;
    sixth = ((abs(IM)>0.3086)&(abs(IM)<0.9528))*1;
    temp = [first;second;third;fourth;fifth;sixth];

    demod_data = reshape(temp,MP_row,MP_col*6);
    
elseif mod_scheme == 8     % 256QAM demodulation
    
    [MP_row,MP_col]=size(mod_data);      
    
    first = (RE>0)*1;
    second = (abs(RE)<0.6136)*1;
    third = ((abs(RE)>0.3068)&(abs(RE)<0.9204))*1;
    fourth = (((abs(RE)>0.1534)&(abs(RE)<0.4602))|((abs(RE)>0.7670)&(abs(RE)<1.0738)))*1;
    fifth = (IM>0)*1;
    sixth = (abs(IM)<0.6136)*1;
    seventh = ((abs(IM)>0.3068)&(abs(IM)<0.9204))*1;
    eighth = (((abs(IM)>0.1534)&(abs(IM)<0.4602))|((abs(IM)>0.7670)&(abs(IM)<1.0738)))*1;
    temp = [first;second;third;fourth;fifth;sixth;seventh;eighth];

    demod_data = reshape(temp,MP_row,MP_col*8);
    
end