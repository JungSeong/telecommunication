function [y , Noise_Power] = awgn_noise(hx,SNR)


[p , q] = size(hx);

Noise_Power = 10^(-SNR/10);

n = (randn(p,q) + 1j*randn(p,q)) * sqrt(Noise_Power/2);

y = hx + n;