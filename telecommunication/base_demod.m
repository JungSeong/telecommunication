%base demodulation function using gray code with normalization (08.11.28)
%
% ex) demod_data = base_demod(mod_data,mod_scheme)
%  mod_scheme : BPSK  = 1
%               QPSK  = 2
%               16QAM = 4
%               64QAM = 6
%               256QAM = 8
%
% QPSK����
%  10 | 11
%-----------
%  00 | 01
%
% 16QAM ����
% 0010 0110 | 1110 1010
% 0011 0111 | 1111 1011
%-----------------------
% 0001 0101 | 1101 1001
% 0000 0100 | 1100 1000


function [demod_data] = base_demod(mod_data,mod_scheme)
% �Ǽ� ����� ������.
RE = real(mod_data);
IM = imag(mod_data);

if mod_scheme == 1         % BPSK demodulation
    demod_data = (mod_data>0)*1; % 0���� ũ�� 1 �ƴϸ� 0
    
elseif mod_scheme == 2     % QPSK demodulation
% �� 1 �� ��嵥���ͱ��� ���������� 1/2
    [MP_row,MP_col]=size(mod_data);  
% �̾Ƴ� ����ΰ� Ȧ����° ������, ũ��1 ������ 0 �̵ȴ�.
    odd_data = (IM>0)*1;  % Ȧ�� ����
    % ��������
    even_data = (RE>0)*1; % ¦�� ����
    % temp�� �̾Ƴ� Ȧ����° ¦����° ������ �Է�
    temp = [odd_data;even_data];
    % reshape�� 2x? ����� MP_row x MP_col*2 �� ���ġ. ( odd�� Ȧ����°, even�� ¦����°)
    demod_data = reshape(temp,MP_row,MP_col*2);
    
elseif mod_scheme == 4     % 16QAM demodulation
    % �������� col�� �� �������� 1/4
    [MP_row,MP_col]=size(mod_data);  
    % 0 ���� ū��
    first = (RE>0)*1;
    % ���밪�� 0.6325�� �Ѵ��� , first�� second�� ���� �ʾѴٸ� �������̰� �ƴϸ� �ȳ�����.
    second = (abs(RE)<0.6325)*1;
    % ����� 0���� ū��
    third = (IM>0)*1;
    % ����� ���밪 0.6325 ���� ū�� ���� ��������
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