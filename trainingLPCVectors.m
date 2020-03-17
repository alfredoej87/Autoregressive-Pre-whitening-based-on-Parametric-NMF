function LPC_VQuantized = trainingLPCVectors(LPC_Observed,numberOfClusters)
%%Requires: voicebox  http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
totalLPCVectors = size(LPC_Observed,1);

for aa = 1:totalLPCVectors-2 %%convert lpc to lsf 
    ObservedLSF(aa,:) = poly2lsf(LPC_Observed(aa,:));
end

[LSF_VQuantized,~,~] = kmeanlbg(ObservedLSF, numberOfClusters);
%%Training the LSF coefficients using LBG
for CBIndex = 1:numberOfClusters  %%Convert LSF back to LPC coeff.
    LPCObservedQuantized = lsf2poly(LSF_VQuantized(CBIndex,:));
    LPC_VQuantized(CBIndex,:) = LPCObservedQuantized;
end
