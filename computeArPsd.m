function arPsd = computeArPsd(nData, arParameters, exVar)
    arPsd = exVar./abs(fft([arParameters(:)], nData)).^2;
end
    