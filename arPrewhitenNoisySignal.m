function prewhitenedNoisy = arPrewhitenNoisySignal(signal,segmentTime,...
    shiftTime,samplingFreq,arPrewOrder,nSpeechVectors,Dictionary)

%%Pre-whitening a noisy signal
%%input signal is assumed as signal = cleanSignal+noise 

%%Requires: voicebox  http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%%Uses voicebox functions: enframe and overlapadd

%%Example from using the default setting parameters.  

%noisy_nmf_prewhitened = arPrewhitenNoisySignal(y); 
%%for some noise scenarios it is suggested to do training on similar noise
%%types
%%it is also recommended to input the parameters for a specific application

if nargin<7 %%%default provided dictionary of speech and noise envelopes
    %%users can give their own ones, as exemplified in exampleDictionaryTraining
    %%Note that these codebooks were trained on frames with length 32 ms
    %%with an overlap of 50% (i.e., 16 ms) between them, sampling frequency was 8 kHz 
    load generalArctic32order12.mat 
    load cb_noisex92JOINT.mat
    Dictionary = [GeneralSpeechDictionary jointx_envelope]; 
    nSpeechVectors = size(GeneralSpeechDictionary,2); 
end
    
if nargin<6
    nSpeechVectors = 32; %%default number of speech envelopes (from the pretrained dictionary) 
end 

if nargin<5 
    arPrewOrder = 30; %%default order of AR pre-whitening 
end 

if nargin<4 
    samplingFreq = 8000; %%default sampling frequency 
end

if nargin<3
    shiftTime = segmentTime/2; %%default 50% overlap between segments
end 

if nargin<2 
    segmentTime = 0.032; %%default 32ms 
end 

if nargin<1
    error('Missing input signal') % there should be at least 2 arguments (audio data and fs) 
end

lengthSignal = length(signal); 
nShift = shiftTime*samplingFreq;
nFrameSize = segmentTime*samplingFreq; 
nFrames = floor(lengthSignal/nShift); 
window = rectwin(nFrameSize); 

spectrum = fft(enframe(signal,window,nShift),nFrameSize,2); 
periodogram = spectrum.*conj(spectrum)/nFrameSize; 
mmse_psd = estnoiseg(periodogram,nShift/samplingFreq); %%mmse-spp noise psd 
mmseCov = ifft(mmse_psd'); 
for m = 1:size(mmseCov,2) 
    lpcMmse(:,m)=levinson(mmseCov(:,m),arPrewOrder);
end
nmf_psd=nmfPSDObtain(signal,periodogram,Dictionary,nSpeechVectors,lpcMmse); 
nmfCov = ifft(nmf_psd'); 
for m = 1:size(mmseCov,2)  
    lpcNmf(:,m)=levinson(nmfCov(:,m),arPrewOrder);
end

analysisSynthesisWindow = sqrt(hanning(nFrameSize,'periodic'));
spectrumWindowed=fft(enframe(signal,analysisSynthesisWindow,nShift),...
    nFrameSize,2);  
%%Apply pre-whitening filter in frequency domain for overlapping segments
for m = 1:size(lpcNmf,2) 
    noisySpectrum = spectrumWindowed(m,:); 
    prewhitenerFreqDomain = fft(lpcNmf(:,m),nFrameSize); 
    prewhitenedIndivSegments(m,:)=noisySpectrum.*prewhitenerFreqDomain.'; 
end 

%%Overlap and add pre-whitened segments in frequency domain and reconstruct
%%pre-whitened signal in the time-domain 
prewhitenedNoisy = overlapadd(ifft(prewhitenedIndivSegments,nFrameSize,2),...
analysisSynthesisWindow,nShift); 