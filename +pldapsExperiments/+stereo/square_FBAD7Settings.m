function s = square_FBAD7Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
s.stimulus.angle = [0 1];


%Full Size
% s.stimulus.sizeX=1900;
% s.stimulus.sizeY=200;

%Large but no longer touching screen edges
s.stimulus.sizeX=500;
s.stimulus.sizeY=175;

%very small
% s.stimulus.sizeX=100;
% s.stimulus.sizeY=50;

s.stimulus.offStim=1;


s.stimulus.runtype = 'pseudo';

s.stimulus.duration.ITI = 1.5;
%changed 2 to 1.5 11/12/24

%set up the viewing distance
s.display.viewdist = 75; 

