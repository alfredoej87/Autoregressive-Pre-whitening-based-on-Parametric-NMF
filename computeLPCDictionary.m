%%Requires: voicebox  http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
function LPC_VectorsDictionary = computeLPCDictionary(Filenames,nData,...
    shiftingTime, samplingFreq, LPCOrder, clustersNumber)
allLPCVectors = estimateARTrainingVectors(Filenames,nData,shiftingTime,...
    samplingFreq,LPCOrder); 
LPC_VectorsDictionary = trainingLPCVectors(allLPCVectors,clustersNumber); 
end