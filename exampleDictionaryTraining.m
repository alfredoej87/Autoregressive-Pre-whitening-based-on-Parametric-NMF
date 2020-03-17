%%example on how to create a dictionary matrix. Each column will contain
%%typical spectral envelopes, which are parametrized by AR coefficients 

segmentTime = 0.032; %%32 ms 
samplingFreq = 8000;
segmentLength = segmentTime*samplingFreq; 
shiftingTime = segmentTime/2; %%16 ms for example 
orderLPC_noise = 12; 
totalEntries = 16; %%number of Codebook entries 

%%example on how to create a codebook of representative LPC values of noise 
noiseLPCCodebook = computeLPCDictionary({'babble_noisex92_8kHz.wav',...
    'f16_8KHz.wav','street_8KHz.wav','factory_noisex92_8KHz.wav'},...
    segmentLength,shiftingTime,samplingFreq,orderLPC_noise,totalEntries); 
%%From the LPC codebook, create dictionary of normalized spectral envelopes 
for x = 1:totalEntries 
    jointEnvelope(:,x)=computeArPsd(segmentLength,noiseLPCCodebook(x,:),1); 
end

%%Plotting the spectral envelopes 
figure; 
for x = 1:totalEntries
subplot(4,4,idx); 
plot(db20(jointEnvelope(1:end/2,x)),'linewidth',1.5); 
grid on; 
end