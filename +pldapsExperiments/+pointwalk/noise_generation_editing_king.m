%% the X's

X = zeros([time, pos]);
ferXX = zeros([time, pos]);

for p = 1:pos
    for i = 1:time
        x = cell2mat(stand_norm{i,1}(p,1));
        x = filloutliers(x,'previous','movmedian',2);
        X(i, p) = x;
    end
    figure(p);
    subplot(1,3,3);
    plot(1:time, X(:,p), 'r')
    %title(strcat(positions{p}, 'regularX'));
    
    
    
    subplot(1, 3, 1)
    x2 = sgolayfilt(X(:, p),2,21);
    plot(1:time, x2, 'o')
    %title(strcat(positions{p}, 'golayfitX'));
    
    
    xx = 1:.25:time;
    yy = spline(([1:time]), x2 ,xx);
    subplot(1,3,2);
    plot(xx,yy,'g')
    %title(strcat(positions{p}, 'splineX'));
    ferXX(:, p) = x2;
end

%% the Y's

Y = zeros([time, pos]);
ferYY = zeros([time, pos]);

for p = 1:pos
    for i = 1:time
        y = cell2mat(stand_norm{i,1}(p,2));
        y = filloutliers(y,'previous','movmedian',2);
        Y(i, p) = y;
    end
    figure(p + pos);
    
    subplot(1,3,3);
    plot(1:time, Y(:,p), 'r')
    %title(strcat(positions{p}, 'regularY'));
    
    subplot(1,3,1);
    y2 = sgolayfilt(Y(:, p),2,21);
    plot(1:time, y2, 'o')
    %title(positions{p});
    %title(strcat(positions{p}, 'golayfitY'));
    
    xx = 1:.25:time;
    yy = spline(([1:time]), y2 ,xx);
    subplot(1,3,2);
    plot(xx,yy,'g')
    %title(strcat(positions{p}, 'splineY'));
   
    ferYY(:, p) = y2;
end

%% rainbow loop

for i = 1:size(ferXX, 2) 
    scatter3(ferXX(:, i), ferYY(:, i), [1:220], [], rand(1,3), 'filled');
    hold on
end

%%  diff testing
cool = randi(99, 1, 100);                                  % Create Data
beans = randi(99, 1, 100);                                  % Create Data
d = hypot(diff(cool), diff(beans));                            % Distance Of Each Segment
d_tot = sum(d); 


%% instantiating displacement of filtered xy trajectory
%problem, how do I do simultaneously plot them all
Xdis = diff(ferXX(:, :));
Ydis = diff(ferYY(:, :));
min = 1;
max = 15;



for randoming = 1:size(Xdis, 1)
    Xdis(randoming, max +1) = randi([min, max]);
    Ydis(randoming, max + 1) = Xdis(randoming, max + 1);
end

%Xdis((j - 1), Xdis(j, max +1)); 
%this specifies the random trajectory
%the previous for loop locks this in place


randox = rand(1, 100); %bounds should be within all values in dotpos
randoy = rand(1, 100); %same here, all possible values in ferret movement
randox = randox';
randoy = randoy';

for randoming = 1:size(randox, 1)
    randox(randoming, 2) = randi([min, max]);
    randoy(randoming, 2) = randox(randoming, 2);
end




%what i am confused about here is that there should be a way to choose upon
%call in loop
%write a function that loops and randomizes and computes all.
%problem for later


 for j = 1:size(Xdis, 1)
    for groups = 1:size(randox, 1)
        if j == 1
            scatter(randox(groups, 1), randoy(groups,1), 'filled')
        else
            scatter((randox(groups, 1) + Xdis((j - 1), randox(groups, 2))), (randoy(groups, 1) + Ydis((j - 1), randoy(groups, 2))), 'filled');
            %randox = (randox + Xdis((j - 1), Xdis(j, max +1)));
            randox(groups,1) = (randox(groups, 1) + Xdis((j - 1), randox(groups, 2)));
            randoy(groups,1) = (randoy(groups, 1) + Ydis((j - 1), randoy(groups, 2)));
            %randoy = (randoy + Ydis((j - 1), Ydis(j, max +1)));
        %axis = [-2 2 -2 2];
        drawnow
        end
    end
 end
 
 
%% THIS IS THE ONE

%rewrote this to incorporate smooth and show juxtaposition
%movie 100 is aggregate
%A/B/C are reworked coordvecs


load('movie100.mat') %to use for stimuli plot against

% % here1y = squeeze(A(:, 2, :))' *-1;
% % here1x = squeeze(A(:,1,:))' * -1;
% % here1x = here1x - 19;
% % 
% % here2y = squeeze(B(:, 2, :))'*-1;
% % here2x = squeeze(B(:,1,:))' * -1;
% % here2x = here2x - 19;
% % 
% % here3y = squeeze(C(:, 2, :))'*-1;
% % here3x = squeeze(C(:,1,:))' * -1;
% % here3x = here3x - 19;

%here = cat(3, coordvec, coordvec, coordvec, coordvec, coordvec(:, :, 1:120)); 
%equals 1000
herey = squeeze(coordvec(:, 2, :))';
herex = squeeze(coordvec(:,1,:))';

sz = 100;
frames = size(herex, 1);

Xdis = diff(herex(:, :));
Ydis = diff(herey(:, :));
mini = 1;
maxi = 14;

herey = herey *-1;
herex = herex *-1;
herex = herex - 19;



randox = rand(1, 1000)*40 - 20; %bounds should be within all values in dotpos
randoy = rand(1, 1000)*40 - 20; %same here, all possible values in ferret movement
randox = randox';
randoy = randoy';


rsize = size(randox, 1);


for randoming = 1:size(randox, 1)
    randox(randoming, 2) = randi([mini, maxi]);
    randoy(randoming, 2) = randox(randoming, 2);
end

randdotposx = zeros(rsize, frames); %column will be 1 + diff matrix
randdotposy = zeros(rsize, frames);

 
for k = 1:size(randox, 1)
    for j = 1:size(Xdis, 1)
        if j == 1
            randdotposx(:, 1) = randox(:,1);
            randdotposy(:, 1) = randoy(:,1);
        else
            randdotposx(k, j) = randox(k,1) + Xdis((j - 1), randox(k, 2));
            randdotposy(k, j) = randoy(k,1) + Ydis((j - 1), randoy(k, 2));
            randox(k, 1) = randox(k,1) + Xdis((j - 1), randox(k, 2));
            randoy(k, 1) = randoy(k,1) + Ydis((j - 1), randoy(k, 2));
        end
        if (randdotposx(k,j) < -25 || randdotposx(k, j) > 25)
                randdotposx(k,j) = rand(1)*4 - 2;
                randox(k, 1) = randdotposx(k, j);       
        end
        if (randdotposy(k,j) < -25 || randdotposy(k, j) > 25)
                randdotposy(k,j) = rand(1)*4 - 2;
                randoy(k, 1) = randdotposy(k, j);       
        end
    end
end


%% visualize

%this portion is connected to scrambled eggs
% coordvec(:, 1, :) = coordvec(:, 1, :) *-1;
% coordvec(:, 2, :) = coordvec(:, 2, :) *-1;
% coordvec(:, 1, :) = coordvec(:, 1, :) -19;
% 
% coordvec2(:, 1, :) = coordvec2(:, 1, :) *-1;
% coordvec2(:, 2, :) = coordvec2(:, 2, :) *-1;
% coordvec2(:, 1, :) = coordvec2(:, 1, :) -19;

% visualize
count = 0;
while count < 5
    hAxes=axes;
        hBehavior = hggetbehavior(hAxes, {'Zoom','Pan','Rotate3d'});  % undocumented
        hBehavior(1).Enable=0;
        hBehavior(2).Enable=0;
        hBehavior(3).Enable=0;
    for q = 1:frames
        axis([-20 20 -20 20]);
        axis manual
%         scatter(randdotposx(:, q), randdotposy(:,q), 'k', 'filled');
%         hold on
        scatter(Holder(1:1000, 1, q) + (.1*q), Holder(1:1000, 2, q), 'k', 'filled');
        hold on
        scatter(Holder(1001:2000, 1, q) - (.1*q), Holder(1001:2000, 2, q), 'k', 'filled');
        hold on
        scatter(Holder(2001:3000, 1, q) + (.1*q), Holder(2001:3000, 2, q), 'k', 'filled');
        hold on
        scatter(Holder(3001:end, 1, q) - (.1*q), Holder(3001:end, 2, q), 'k', 'filled');
        hold on
%         scatter(Holder(4001:5000, 1, q) + (.1*q), Holder(4001:5000, 2, q), 'k', 'filled');
%         hold on
%         scatter(Holder(5001:6000, 1, q) - (.1*q), Holder(5001:6000, 2, q), 'k', 'filled');
%         hold on
%         scatter(Holder(6001:end, 1, q) + (.1*q), Holder(6001:end, 2, q), 'k', 'filled');
%         hold on
        scatter(coordvec(:, 1, q) + (.1*q), coordvec(:, 2, q), 'c', 'filled');
        hold on
        scatter(coordvec2(:, 1, q) + (.1*q), coordvec(:, 2, q) + 5, 'k', 'filled');
        %scatter(herex(q, :) + (.1*q), herey(q, :), 'k', 'filled')
        %hold on
% %         scatter(here1x(q, :) + (.1*q), (here1y(q, :) + 5), 'g', 'filled')
% %         hold on
% %         scatter(here2x(q, :) + (.1*q), (here2y(q, :) - 5), 'c', 'filled')
% %         hold on
% %         scatter(here3x(q, :) + (.1*q), (here3y(q, :) - 10), 'r', 'filled')
        hold off

        
        %count = count + 1;
        drawnow
    end
    count = count + 1;
end
%% Now I'm chopping this up to place in dotpos I think?
%may not even have to worry about scaling
%for matlab on psychtool box set up


load('movie15.mat') %to use for stimuli plot against
%here = cat(3, coordvec, coordvec, coordvec, coordvec, coordvec(:, :, 1:120)); 
%equals 1000
%lets try not squeezing for now
herey = (coordvec(:, 2, :))';
herex = (coordvec(:,1,:))';

sz = 100;
frames = size(herex, 1);

Xdis = diff(herex(:, :));
Ydis = diff(herey(:, :));
mini = 1;
maxi = 14;

herey = herey *-1;
herex = herex *-1;
herex = herex - 19;

randox = rand(1, 1000)*1980 - (1980/2); %bounds should be within all values in dotpos
randoy = rand(1, 1000)*1980 - (1980/2); %same here, all possible values in ferret movement
randox = randox';
randoy = randoy';


rsize = size(randox, 1);


for randoming = 1:size(randox, 1)
    randox(randoming, 2) = randi([mini, maxi]);
    randoy(randoming, 2) = randox(randoming, 2);
end

randdotposx = zeros(rsize, frames); %column will be 1 + diff matrix
randdotposy = zeros(rsize, frames);

 
for k = 1:size(randox, 1)
    for j = 1:size(Xdis, 1)
        if j == 1
            randdotposx(:, 1) = randox(:,1);
            randdotposy(:, 1) = randoy(:,1);
        else
            randdotposx(k, j) = randox(k,1) + Xdis((j - 1), randox(k, 2));
            randdotposy(k, j) = randoy(k,1) + Ydis((j - 1), randoy(k, 2));
            randox(k, 1) = randox(k,1) + Xdis((j - 1), randox(k, 2));
            randoy(k, 1) = randoy(k,1) + Ydis((j - 1), randoy(k, 2));
        end
        if (randdotposx(k,j) < -990 || randdotposx(k, j) > 990)
                randdotposx(k,j) = rand(1)*1980 - 990;
                randox(k, 1) = randdotposx(k, j);       
        end
        if (randdotposy(k,j) < -990 || randdotposy(k, j) > 990)
                randdotposy(k,j) = rand(1)*1980 - 990;
                randoy(k, 1) = randdotposy(k, j);       
        end
    end
end


%visualize


%count = 0;
%deleted scatter for now

for filling = 1:frames
    %coordvec(:, 1, filling) = [coordvec(:, 1, filling)];
end

the_rando(:, 1, :) = randdotposx;
the_rando(:, 2, :) = randdotposy;

WHAT_IS_THIS = cat(1, coordvec, the_rando);

for q = 1:frames
    
    scatter(WHAT_IS_THIS(:, 1, q), WHAT_IS_THIS(:, 2, q), 'k', 'filled');
   
    %axis = ([-20 20 -20 20]);
    %count = count + 1;
    drawnow
end
    