function [ y ] = nonLinearMap( d, alpha, beta, sigma, range )
%LOCAL Summary of this function goes here
%   Detailed explanation goes here

d = double(d);
sigma = double(sigma);

r = abs(d)/sigma;
if (d > 0)
    dRef = sigma;
else
    dRef = -sigma;
end

if (r > 1)
    y = dRef * sqrt(1 + beta^2 * (r^2 - 1));
elseif (alpha == 1)
    y = d;
elseif (alpha < 1 && alpha > 0)
    y = dRef * r^(1/alpha);
else if (alpha == 0)
        y = 0;
else
    s = max([0 min([1 100*(r*sigma - 0.01 * range)])]);
    y = dRef * (r + s * (r^(1/alpha) - r));
end


end
