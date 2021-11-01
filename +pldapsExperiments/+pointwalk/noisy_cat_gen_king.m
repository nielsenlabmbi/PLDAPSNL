%% ferret noise initialization

%load('movie100.mat');
[points, coords, frames] = size(coordvec);

Holder = [];
PS_block = cell(250, 1);
for i = 1:length(PS_block)
    PS_block{i, 1} = coordvec2;
    % PS_block{i, 1}(:, 1, :) = where the xcoords will be
    % PS_block{i, 1}(:, 1, :)   what the xcoords were initially
    % + (rand(1)*40 - 20);      + a random translation in the x direction
    PS_block{i, 1}(:, 1, :) = PS_block{i, 1}(:, 1, :) + (rand(1)*40 - 20);
    PS_block{i, 1}(:, 2, :) = PS_block{i, 1}(:, 2, :) + (rand(1)*40 - 20);
    r = randi([1,2]);
    if r == 1
        PS_block{i, 1}(:, 1, :) = PS_block{i, 1}(:, 1, :) *-1;
    end
    Holder = cat(1, Holder, PS_block{i, 1});
end
    

