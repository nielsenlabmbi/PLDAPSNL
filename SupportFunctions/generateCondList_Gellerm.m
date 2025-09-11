function c=generateCondList_Gellerm(Ncond)

% use Gellermann sequences to generate L/R sequences; only produce list of
% condition indices, mapping onto stimulus configuration is then handled in
% the trials function
%
% input: 
% Ncond = total number of conditions; the first half will be mapped onto L,
% the other half onto R
%
% output:
% structure with condition and side assignment per trial; formatted
% according to PLDAPS conditions
% side parameter: 1 = L, 2 = R


% gellermann sequence runs fastest with smaller chunks; generate 4 chunks
% of 50 blocks here
blockLength=50;
nBlocks=4;

LRseq=zeros(1,blockLength*nBlocks);
for i=1:nBlocks
    LRseq((i-1)*blockLength+1:i*blockLength)=gellermannList(blockLength);
end

%condition indices per side get pseudorandomized and then mapped onto the L/R trials
NcondSide=Ncond/2; %first half of conditions = L; second half = R;

%number of repeats per condition: trials per side/conditions per side; since
%things are even this is equal to trials total/conditions total

condIdxL=[];
condIdxR=[];
for i=1:ceil(length(LRseq)/Ncond) %we will generate more than necessary
    condIdxL=[condIdxL randperm(NcondSide)];
    condIdxR=[condIdxR randperm(NcondSide)+NcondSide];
end

%now generate output
condSeq=zeros(size(LRseq));
idx=find(LRseq==0); %L trials
condSeq(idx)=condIdxL(1:length(idx)); %we might have generated too many trials
idx=find(LRseq==1); %R trials
condSeq(idx)=condIdxR(1:length(idx));


%this output structure is required by PLDAPS
c=cell(1,length(condSeq));

for i=1:length(condSeq)
    %condition index for every trial
    c{i}.condIdx=condSeq(i);
    
    %side assignment
    c{i}.side=LRseq(i)+1;
end