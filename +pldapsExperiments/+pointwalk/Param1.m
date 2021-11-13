%% Local vs no movement
tic
%**** 100% coherence means all dots are signal, i.e they don't move
%**** 0% coherence means all dots are not moving
load('movie100.mat');


coherence = [1.00, .80, .60, .40, .20];
% 100% would have the signal value, which is 100% no dots moving
% 20% would have the signal value, which is 20% no dots move

% *nothing is corresponding to global motion at this time
% *directoin calculations don't matter at this time
dot_lifetime = 216;
%*** cordvec basis
herey = squeeze(coordvec(:, 2, :))';
herex = squeeze(coordvec(:,1,:))';

frames = size(herex, 1);

Xdis = diff(herex(:, :));
Ydis = diff(herey(:, :));

%***initialize random dots
%the bounds will correspond to psychtoolbox bounds
nrDots = 100;
maxi = 4*max(max(max(coordvec)));
mini = 4*min(min(min(coordvec)));
randdotvec = mini + (maxi - mini).*rand(2, nrDots)';


%*** initialize noise vector
nrSignal = round(nrDots*coherence(5));
noisevec = zeros(nrDots, 2);
noisevec(1:nrSignal, 1) = 1; %1 = signal 0 = noise
%the remainder noise will move w/ a random movement vector
noisevec(nrSignal + 1:end, 2) = randi(14, 1, nrDots-nrSignal);

%idx = 0, these are the noise
%idx = 0, these are the values that will move

%*** don't need directions for now

%*** initialize lifetime

if dot_lifetime >0
    lifetime = randi(frames, nrDots, 1);
end


%this is the building vector
%once complete, its size should be [dots x frames]
dotposx = randdotvec(:, 1);
dotposy = randdotvec(:, 2);

%*** now it's time to start making all the dots

%***
  %dotpos can take 3D array w/ x/y concatenated
      %will have to split up here for testing
%***


for counter = 2:frames
    idx = find(noisevec(:, 1) == 0);
    randdotvec(idx, 1) = randdotvec(idx, 1) + (Xdis(counter-1, noisevec(idx, 2)))';
    randdotvec(idx, 2) = randdotvec(idx, 2) + (Ydis(counter-1, noisevec(idx, 2)))';
    
    if dot_lifetime > 0
        idx = find(lifetime == 0);
        lifetime(idx) = randi(frames, length(idx), 1);
        randdotvec(idx, :) = mini + (maxi - mini).*rand(2, length(idx))';
        newbag(idx, 1) = rand(length(idx),1);
%         sigidx = find(noisevec(idx, 1) <= coherence(2));
%         noisevec(sigidx, 1) = 1;
%         noisevec(sigidx, 2) = 0;
%         noidx = find(noisevec(idx, 1) > coherence(2));
%         noisevec(noidx, 1) = 0;
%         noisevec(noidx, 2) = randi(14, 1, length(noidx));
        if newbag(idx, 1) <= coherence(5)
            noisevec(idx, 1) = 1;
            noisevec(idx, 2) = 0;
        elseif newbag(idx, 1) > coherence(5)
            noisevec(idx, 1) = 0;
            noisevec(idx, 2) = randi(14, 1, length(idx));
        end
        
        lifetime = lifetime - 1;
    end
    
    dotposx(:, counter) = randdotvec(:, 1);
    dotposy(:, counter) = randdotvec(:, 2);

end

coordvec = coordvec * -1;
%% visualize

xhold = [-15, 15];
yhold = [-15, 15];

count = 0;
while count < 2
    for views = 1:frames
        scatter(dotposx(:, views), dotposy(:, views), 'filled', 'k')
        hold on
        scatter(xhold, yhold, 'filled', 'k')
        hold on
        scatter((coordvec(:, 1, views) + 0.025*views), coordvec(:, 2, views), 'filled', 'k')
        hold off
        drawnow
    end
    count = count +1;
    title('Param1')
end
toc
