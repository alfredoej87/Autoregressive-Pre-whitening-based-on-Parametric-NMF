function SigmaVct = CompActivationCoeffs(segmentPSD,Dictionary) 

%%Function which finds the activation coefficients given the noisy PSD 
%%of a single segment and the dictionary which contains in its columns
%%spectral envelopes of speech and noise. Uses multiplicative update rule

numIter = 40; 
SigmaVct = abs(randn(size(Dictionary,2),1)); 

for p = 1:numIter
    Factor = Dictionary'*(((Dictionary*SigmaVct).^(-2)).*segmentPSD')./(...
        Dictionary'*(Dictionary*SigmaVct).^(-1)); 
    SigmaVct = SigmaVct.*Factor;   
end

end
