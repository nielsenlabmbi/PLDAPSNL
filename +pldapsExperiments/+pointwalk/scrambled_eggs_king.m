%% phase scramble

load('movie100.mat');


A = coordvec(:, 1, 1);
%A = A';
maybe = A(randperm(length(A))); %block i'm shuffling
percent = [.2 .4 .6 .8]'; %percentage of shuffle
values = ceil(percent(2)*size(A,1)); %values to scramble
%values will be a setting called phase_coherence
phasedock = A(randperm(numel(A),values)); %i'm shuffling a percentage of block
B = A; 
 
[points, coords, frames] = size(coordvec);

 %grab the locations of the scrambled values
ind = zeros(size(phasedock)); 
for val = 1:length(phasedock)
     ind(val) = find(A == phasedock(val));
end

%this step randomized the pulled values
%then in the new randomized order, the original block was reordered by new
%phases
phasedockperm = phasedock(randperm(length(phasedock)));

%now need this for the new index
idx = zeros(size(phasedockperm)); 
for val = 1:length(phasedockperm)
     idx(val) = find(A == phasedockperm(val));
end

coordvec2 = coordvec;
for coord = 1:2
    for col = 1:frames
        for val = 1:length(phasedockperm)
            coordvec2(ind(val), coord, col) = coordvec(idx(val), coord, col);
        end
    end
end



%DANG THIS WASN'T EVEN A SCRAMBLE, EVERYTHING LANDED ON EACH OTHER



%coorddot = zeros(14, 2, 270);
%coorddot = zeros(points, coords, frames)

% for f = 1:frames
%     for ii = 1:length(phasedockperm)
%         coordvec(ind(ii)) = 
%     end
% end

%just think, if i had multiple rows, they all would scramble simultaneously
%that way it can be kept cohesive and attached to the motion trajectory

%% true phase scrambling

load('movie100.mat');
[points, coords, frames] = size(coordvec);

%*********These are the motion values
Xdis = diff(squeeze(coordvec(:, 2, :))')';
Ydis = diff(squeeze(coordvec(:,1,:))')';



%*******instantiate first column
A = coordvec(:, 1, 1);

%*******scramble by percent (phase_coherence
percent = [.2 .3 .4 .5 .6 .7 .8 .9]'; %percentage of shuffle %this gets changed in cell array
phase_coherence = ceil(percent(8)*size(A,1)); %values to scramble

phasedock = A(randperm(numel(A),phase_coherence)); %i'm shuffling a percentage of block 
 
%*******grab the indicies of what was scrambled
ind = zeros(size(phasedock)); 
for val = 1:length(phasedock)
     ind(val) = find(A == phasedock(val));
end

%*******this step randomized the pulled values
phasedockperm = phasedock(randperm(length(phasedock)));

%*******this becomes the new index of the scrambled values
idx = zeros(size(phasedockperm)); 
for val = 1:length(phasedockperm)
     idx(val) = find(A == phasedockperm(val));
end

%*******original postions are now being updated with new movement vector
coordvec2 = coordvec; %dummy holder
for col = 2:frames
    for val = 1:length(phasedockperm)
        coordvec2(ind(val), 1, col) = coordvec(idx(val), 1, (col - 1)) + Xdis(idx(val), (col - 1));
        coordvec2(ind(val), 2, col) = coordvec(idx(val), 2, (col - 1)) + Ydis(idx(val), (col - 1));
    end
end







 