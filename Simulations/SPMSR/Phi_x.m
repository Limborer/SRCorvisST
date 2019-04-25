function [fx] = Phi_x(x)
% Phi_x - Applies the sigmoid transfer function
fx=0.5*(1+tanh(x));