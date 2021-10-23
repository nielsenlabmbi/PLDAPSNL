function [coordvec] = human_dot_gen(coordvec)
% Now I'm chopping this up to place in dotpos I think?
%may not even have to worry about scaling
%for matlab on psychtool box set up


%movie is already loaded
herey = (coordvec(:, 2, :))';
herex = (coordvec(:,1,:))';

sz = 100;
frames = size(herex, 1);

Xdis = diff(herex(:, :));
Ydis = diff(herey(:, :));
min = 1;
max = 14;

% herey = herey *-1;
% herex = herex *-1;
% herex = herex - 19;

randox = rand(1, 1000)*1980 - (1980/2); %bounds should be within all values in dotpos
randoy = rand(1, 1000)*1980 - (1980/2); %same here, all possible values in ferret movement
randox = randox';
randoy = randoy';


rsize = size(randox, 1);


for randoming = 1:size(randox, 1)
    randox(randoming, 2) = randi([min, max]);
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



the_rando(:, 1, :) = randdotposx;
the_rando(:, 2, :) = randdotposy;

coordvec = cat(1, coordvec, the_rando);


%we should be now back to coordvec of the workspace w/in trial


  