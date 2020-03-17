function nmfPSDestimate = nmfPSDObtain(NoisySignal,NoisyPSD,inputDict,...
    numSpeechVct,ar_MMSE)

%%inputs: 
%%NoisyPSD:matrix containing the periodograms of all the segments 
%%inputDict:Dictionary matrix containing speech & noise spectral envelopes
%%numSpeechVct:number of spectral basis corresponding to the speech 
%%ar_MMSE:current AR coefficients fitted to the MMSE-SPP noise psd estimate
%%The corresponding entry will be added to the dictionary to make more
%%robust 
%%arPrewOrder:autoregressive pre-whitening order 
%%Outputs: 
%%nmfPSD


TotalFrames = size(NoisyPSD,1);
segmentLength = size(NoisyPSD,2);
signalIdx = 1:segmentLength;
nShift = segmentLength/2;

for tt=1:TotalFrames
    
    segmentNoisyPSD = NoisyPSD(tt,:)'; %periodogram when plotting
    MMSEPSD = computeArPsd(segmentLength,ar_MMSE(:,tt),1);
    currDict = [inputDict MMSEPSD];
    
    %%Estimate activation coefficients of each spectral basis per segment
    all_actC(tt,:) = CompActivationCoeffs(segmentNoisyPSD',currDict);
    
    %%Separate activation coefficients of clean speech and of noise 
    sp_actC = all_actC(tt,1:numSpeechVct);
    noise_actC = all_actC(tt,numSpeechVct+1:end);
    
    %%Obtan prior PSD of speech and of noise for particular segment 
    SpeechPriorPSD = currDict(:,1:numSpeechVct)*sp_actC';
    NoisePriorPSD = currDict(:,numSpeechVct+1:end)*noise_actC';
    
    %%Obtain a-priori SNR and noise psd based on an mmse psd estimate 
    %%reliant on the estimated activation coefficients of spectral basis
    aprioriSNR = SpeechPriorPSD./max(NoisePriorPSD,1e-12); 
    nmfPSDestimate(tt,:)=(((1./(1+aprioriSNR))).^2).*segmentNoisyPSD+...
        (aprioriSNR./(1+aprioriSNR)).*NoisePriorPSD;
    
    signalIdx = signalIdx+nShift;
end
end


