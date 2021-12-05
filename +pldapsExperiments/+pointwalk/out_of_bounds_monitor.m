%% testing which dots are acting up

%% Original, this will replicate what psychtool box drew for a trial
xhold = [-4000, 4000];
yhold = [-4000, 4000];

count = 0;
while count <10
    for i = 1:216
        subplot(1, 2, 1)
        scatter(p.data{1,2}.stimulus.dotpos(:, 1, i), p.data{1,2}.stimulus.dotpos(:, 2, i), 'filled')
        hold on
        scatter(xhold, yhold, 'filled')
        hold off
        drawnow
        pause(.2)
    end
count = count +1;
end

%% extra portion, can choose the timecourse of x variables or y variables
x = p.data{1,2}.stimulus.dotpos(:, 1, :);
y = p.data{1,2}.stimulus.dotpos(:, 2, :);
x = squeeze(x);
y = squeeze(y);
for j = 14:size(x, 1)
    figure(99)
    scatter([1:216], x(j, :), 'filled')
    hold on
    pause(1)
end


%% subplot isolates even more: left shows 'faulty dots'; right shows sample of good dots


xhold = [-4000, 4000];
yhold = [-4000, 4000];

count = 0;
while count <10
    for i = 1:216
        subplot(1, 2, 1)
        scatter(p.data{1,2}.stimulus.dotpos(15:35, 1, i), p.data{1,2}.stimulus.dotpos(15:35, 2, i), 'filled')
        hold on
        scatter(xhold, yhold, 'filled')
        hold off
        drawnow
        subplot(1, 2, 2)
        scatter(p.data{1,2}.stimulus.dotpos(50:75, 1, i), p.data{1,2}.stimulus.dotpos(50:75, 2, i), 'filled')
        hold on
        scatter(xhold, yhold, 'filled')
        hold off
        drawnow
        pause(.2)
    end
count = count +1;
end

x = p.data{1,12}.stimulus.dotpos(:, 1, :);
y = p.data{1,12}.stimulus.dotpos(:, 2, :);
x = squeeze(x);
y = squeeze(y);
for j = 15:35%size(x, 1)
    figure(99)
    scatter([1:216], y(j, :), 'filled')
    hold on
    pause(1)
end
%%
for tile = 1:size(jumps, 1)
    jumpdiff(tile, :) = diff(jumps(tile, :));
end
%% some scratch I don't remember, but at this stage, not helpful
%most likely was trying to replicate the loop of a previous version


if this(:, 1) >= (1000)
    what(1:length(this), 1) = 11;
    this(:, 1) = what;
    %this(:, 2) = -1000 + (1000 - (-1000)).*rand(1);
%             trythis = this(:, 1) - 1500;
%             this(:, 1) = trythis;
elseif this(:, 1) <= (-1000)
    what(1:length(this), 1) = 99;
    this(:, 1) = what;
    %this(:, 2) = -1000 + (1000 - (-1000)).*rand(1);
%             trythis = this(:, 1) + 1500;
%             this(:, 1) = trythis;
end