% function PER = CN02PER(CN0, Rb)
% Function to calculate C/N0 from PER
% output = CN02PER(input)
% input.CN0 - array of CN0 values [dB], input.Rb - bit rate
% output.BER - array of bit error rate values,
% output.PER - array of page error rate values
% Derived from relationships in "Understanding GNSS/GPS: Principles and
% Applications"
% Andrew Neish - 1/30/2019

% TEST Inputs...
clear all
close all
clc
CN0 = linspace(27.5, 29, 100);
Rb = 250;


CN0 = 10.^(CN0/10); % Convert dB values to linear values

% Loop through all CN0 values
D = exp(-CN0./2./Rb);
BER = .5.*(36.*D.^10 + 211.*D.^12 + 1404.*D.^14 + 11633.*D.^16);
PER = 1 - (1 - BER).^Rb;

% TEST outputs
figure
loglog(10*log10(CN0), PER)
xlabel('(C/N_0)_{dB} (dB-Hz)')
ylabel('PER')

% figure
% loglog(10*log10(CN0), output.BER)

