function s = square_FBAD7Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam 
s.stimulus.angle = [0 1];
s.datapixx.adc.channels = [2 4 6];
%s.ports.nports=3; %commented out for midpoint


%Full Size
% s.stimulus.sizeX=1900;
% s.stimulus.sizeY=200;

%Large but no longer touching screen edges
s.stimulus.sizeX=500;
s.stimulus.sizeY=175;

%very small
% s.stimulus.sizeX=100;
% s.stimulus.sizeY=50;

s.stimulus.offStim=1.5;
s.stimulus.dotSize = .3;% original 1.5
s.stimulus.dotDensity = 0.0035; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.centerX= 990; %pixels
s.stimulus.centerY= 510;
s.stimulus.stepSize=.05; 
s.stimulus.stepDens=.0005; 
s.stimulus.runtype = 'pseudo';
s.stimulus.backgroundDot=0;
s.stimulus.duration.ITI = 1.5;
%changed 2 to 1.5 11/12/24

%set up the viewing distance
s.display.viewdist = 75; 

