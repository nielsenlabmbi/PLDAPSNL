function c=generateCondList_sides(cond,side,randType,nrBlocks,varargin)

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
for i=1:length(fn)
    if ~(i == sideParIdx)
        str=[str 'cond.' fn{i} ','];
    end
end
str= str(1:end-1);
combCond=eval(['combvec(' str ')']);

%generate repeat structure
condIdx=[]; 
if strcmp(randType,'pseudo')
    if size(combCond,2) < 2;
        %increase the number of conditions artificially, for greater
        %randomness
        combCond = repmat(combCond, 1, 4);
    end
    allConds = [];
    for i=1:nrBlocks
        %permute within each side
        condPerm = [];
        for k = 1:length(side.match)
            condPerm = [condPerm; randperm(size(combCond,2))];
        end
        
        %permute side, in batches
        batches = min(factor(length(condPerm)));
%         if batches < 3
%             batches = batches*2;
%         end
        sides = repmat(side.match,1,batches);
        
        %shuffle side assignment
        allsides = [];
        for j = 1:length(condPerm)/batches;
            allsides = [allsides sides(randperm(length(sides)))];
        end
        
        %combine side and condition permutations
        conditions = zeros(size(repmat(combCond,1,length(side.match))));
        %find the side assignments
        for k = 1:length(side.match)
            sideIdx(k,:) = find(allsides == side.match(k));
            conditions(:,sideIdx(k,:)) = combCond(:,condPerm(k,:));
        end
        
        %technical - just need to reconstruct our combCond vector that we
        %took apart. We rename it here. 
        if sideParIdx == 1
            conditions = [allsides; conditions];
        elseif sideParIdx == size(combCond,1)+1;
            conditions = [conditions; allsides];
        else
            conditions = [conditions(1:sideParIdx -1,:); allsides; conditions(sideParIdx:end,:)];
        end
        allConds = [allConds conditions];
        
    end
    
    %generate output
    c=cell(1,length(allConds));
    for i=1:length(allConds)
        %basic conditions
        for p=1:length(fn)
            c{i}.(fn{p}) = allConds(p,i);
        end
        
        %side assignment
        c{i}.side = find(allConds(sideParIdx,i)==side.match);
    end
%     else
%         %for simple cases there is no need to shuffle the side like this
%         for i=1:nrBlocks
%             condIdx=[condIdx randperm(size(combCond,2))];
%         end
%         %generate output
%         c=cell(1,length(condIdx));
%         for i=1:length(condIdx)
%             %basic conditions
%             for p=1:length(fn)
%                 c{i}.(fn{p})=combCond(p,condIdx(i));
%             end
%             
%             %side assignment
%             c{i}.side=find(combCond(sideParIdx,condIdx(i))==side.match);
%         end
%     end
    
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
end
