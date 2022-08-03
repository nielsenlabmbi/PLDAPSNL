    

[x, y] = meshgrid([-960:100:960], [-540:100:540]);

[~,rad]=cart2pol(x(:),y(:));
x = x(:);
y = y(:);

newx = x(rad<500);
newy = y(rad<500);

xx = x(:);
xx(:, 2) = 1:length(xx);
yy = y(:);
yy(:, 2) = 1:length(yy);
newxx = xx(find(x(rad<500)), :);
newyy = yy(find(y(rad<500)), :);

figure(1)
scatter(x(:), y(:))

figure(2) 
scatter(newx, newy)
axis([-960 960 -540 540])

%to keep color locked in order, grab idx of x/y pos that are less than the
%radius. After that, use idx on the dotColor vector matrix.
%that new vector becomes dot color

% if p.trial.stimulus.direction==180
%         p.trial.stimulus.dotpos{f}=xypos(:,rad<stimRadius);
%     elseif p.trial.stimulus.direction==0
%         p.trial.stimulus.dotpos{p.trial.stimulus.nrFrames-f+1}=xypos(:,rad<stimRadius);
%     end