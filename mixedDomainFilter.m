unction [ Y] = mixedDomainFilter( X, uOutLast, alpha, beta, sigma, range, lambda )
%MIXEDDOMAINFILTER Summary of this function goes here
%   Detailed explanation goes here

N = 4;
NK = 4;

coeffK = [70.00/256, 56.00/256, 28.00/256, 8.00/256, 1.00/256];

channelNum = size(X, 3);

width = size(X, 2);
height = size(X, 1);

L = zeros(height, width);
S = zeros(height, width);
T = zeros(height, width);

temp = zeros(height, width);
for i = 1 : width
    for j = 1 : height
        if ((i-1)^2 + (j-1)^2 <= N^2)
            temp(j, i) = 1;
        end
    end
end

M = sum(sum(temp));

for i = 1 : width
    for j = 1 : height
        if ((i-1)^2 + (j-1)^2 <= N^2)
            L(j, i) = 1 / M;
        end
    end
end

for i = 1 : width
    if (i - 1 <= NK)
        Ki(i) = coeffK(i);
    end
end

for j = 1 : height
    if (j - 1 <= NK)
        Kj(j) = coeffK(j);
    end
end

% calculate S
for i = 1 : height
    for j = 1 : width
        % current index is (i, j
        pixelCount = 0;
        for ii = i - N : i + N
            for jj = j - N : j + N
                if ((ii-i)^2 + (jj-j)^2 <= N^2)
                    % inside window
                    if (ii >= 1 && ii <= height && jj >= 1 && jj <= width)
                        % inside image
                        S(i, j) = S(i, j) + ...
                            nonLinearMap(X(ii, jj) - X(i, j), alpha, beta, sigma, range) + ...
                            X(i, j);
                        pixelCount = pixelCount + 1;
                    end
                end
            end
        end
        if (pixelCount)
            S(i, j) = S(i, j) / pixelCount;
        end
    end
end

% calculate T
for i = 1 : height
    for j = 1 : width
        % current index is (i, j
        pixelCount = 0;
        for ii = i - N : i + N
            for jj = j - N : j + N
                if ((ii-i)^2 + (jj-j)^2 <= N^2)
                    % inside window
                    if (ii >= 1 && ii <= height && jj >= 1 && jj <= width)
                        % inside image
                        T(i, j) = T(i, j) + ...
                            nonLinearMap(X(i, j) - X(ii, jj), alpha, beta, sigma, range) + ...
                            X(ii, jj);
                        pixelCount = pixelCount + 1;
                    end
                end
            end
        end
        if (pixelCount)
            T(i, j) = T(i, j) / pixelCount;
        end
    end
end

% compute G
G = fspecial('gaussian', 9, 0.5);

% compute L
L = fspecial('disk', N);

uOutLastPadding = zeros(size(S));
if (size(uOutLastPadding, 1) > size(uOutLast, 1))
    hInd = size(uOutLast, 1);
else
    hInd = size(uOutLastPadding, 1);
end
if (size(uOutLastPadding, 2) > size(uOutLast, 2))
    wInd = size(uOutLast, 2);
else
    wInd = size(uOutLastPadding, 2);
end
uOutLastPadding(1:hInd, 1:wInd) = uOutLast(1:hInd, 1:wInd);

% compute Uk
U = lambda * imfilter(uOutLastPadding, G, 'replicate' ) + T - imfilter(S, L, 'replicate');
DU = dct2(U);
DG = dct2(G, height, width);
DL = dct2(L, height, width);

DOut = DU ./ (abs(DG).^2 + 1 - abs(DL).^2);

Y = idct2(DOut);


end

