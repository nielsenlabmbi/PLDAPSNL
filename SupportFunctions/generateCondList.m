function c=generateCondList(cond,side,randType,nrBlocks,varargin)

%input:
%cond: structure with basic conditions (1 field per condition)
%side: structure with 2 fields: par - name of cond parameter to be used to
%determine side assocation; match: which condition gets matched to left and
%right (vector with the condition values; example: side.par='ori', side.match=[0 90])
%randType: randomization - either pseudorandomization ('pseudo') or blocked
%('block'); blocking occurs per side - sides alternate, all other
%parameters are randomized in order; each condition occur nrReps times
%nrBlocks: number of blocks with all conditions
%nrReps: repeats per condition (only used for blocked)

%output:
%structure with conditions and side assignment for every trial

if nargin==5
    nrReps=varargin{1};
end


%generate full combinatorial tree
fn=fieldnames(cond);
sideParIdx=find(strcmp(side.par,fn)==1);

%first make sure that they are all column vectors (otherwise CombVec fails)
for i=1:length(fn)
    if size(cond.(fn{i}),1)~=1
        cond.(fn{i})=cond.(fn{i})';
    end
end

%generate all combinations of conditions
str=[];
for i=1:length(fn)-1
    str=[str 'cond.' fn{i} ','];
end
str=[str 'cond.' fn{end}];
combCond=eval(['CombVec(' str ')']);

%generate repeat structure
condIdx=[];
if strcmp(randType,'pseudo')
    for i=1:nrBlocks
        condIdx=[condIdx randperm(size(combCond,2))];
    end
elseif strcmp(randType,'block')
    %determine which side
    nrSides=length(side.match);
    %repeat per block (we want to keep the order fixed)
    sideIdx=repmat([1:nrSides],1,nrBlocks);
    %now generate full condition list
    for i=1:length(sideIdx)
        %find all conditions for that side
        idx=find(combCond(sideParIdx,:)==side.match(sideIdx(i)));
        %randomize
        ridx=idx(randperm(length(idx)));
        %now repeat (within block repeats; necessary if there are only 2
        %conditions)
        ridx=repmat(ridx,nrReps,1);
        ridx=reshape(ridx,1,length(idx)*nrReps);
        condIdx=[condIdx ridx];
    end
end

%generate output
c=cell(1,length(condIdx));
for i=1:length(condIdx)
    %basic conditions
    for p=1:length(fn)
        c{i}.(fn{p})=combCond(p,condIdx(i));
    end
    
    %side assignment
    c{i}.side=find(combCond(sideParIdx,condIdx(i))==side.match);
end
