
function LPC_per_segment = estimateARTrainingVectors(Filenames,...
    nData, shiftingTime, samplingFreq, LPCOrder)

nShift = shiftingTime*samplingFreq;
NumberFiles = length(Filenames);
%%window = rectwin(nData);
window = hanning(nData);
idxGlobal = 1; %%Increases along all the files

for aa = 1:NumberFiles
    
    filename = cell2mat(Filenames(aa));
    [cleanSpeech,fs2] = audioread(filename);
    %% if fs2 == 16000
    %%cleanSpeech = resample(cleanSpeech,1,2);
    %%end
    %%Resampling to the desired samplingFreq
    [P,Q] = rat(samplingFreq/fs2);
    cleanSpeech = resample(cleanSpeech,P,Q);
    signalLength = length(cleanSpeech);
    TotalSegments = floor(signalLength/nShift)-2;
    signalIdx = 1:nData;
    
    for bb = 1:TotalSegments
        
        speechSegment = cleanSpeech(signalIdx);
        speechSegment = speechSegment.*window;
        signalIdx = signalIdx+nShift;
        
        if sum(speechSegment)>eps
            LPC_per_segment(idxGlobal,:) = lpc(speechSegment,LPCOrder);
            idxGlobal = idxGlobal+1;
        end
        
    end
end