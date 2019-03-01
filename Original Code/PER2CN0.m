% function output = PER2CN0(input)
% Function to calculate C/N0 from PER
% Derived from relationships in "Understanding GNSS/GPS: Principles and
% Applications"
% Andrew Neish - 1/30/2019
clear all
close all
clc

% Inputs...
input.CN0 = linspace(10^2, 10^4, 100);
input.Rb = 250;

% Loop through all PER values

D = exp(-input.CN0./2./input.Rb);
Pb = .5.*(36.*D.^10 + 211.*D.^12 + 1404.*D.^14 + 11633.*D.^16);

figure
loglog(10*log10(input.CN0), Pb)
xlabel('(C/N_0)_{dB} (dB-Hz)')
ylabel('BER')








% end