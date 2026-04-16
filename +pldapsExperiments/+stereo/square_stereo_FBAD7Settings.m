function s = square_stereo_FBAD7Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam 
s.stimulus.angle = [0 1];


%Full Size

%Large but no longer touching screen edges
s.stimulus.sizeX=500;
s.stimulus.sizeY=175;

s.stimulus.dotColor1=[1 0 0, 0.5]; %red
s.stimulus.dotColor2=[0 1 0, 0.5]; %green
s.stimulus.dotColor3=[0 0 0]; %black
s.stimulus.offStim=1.5;
s.stimulus.dotSize = .3;% original 1.5
s.stimulus.dotDensity = .005; %0.03; %dots/deg^2
s.stimulus.centerX= 990; %pixels
s.stimulus.centerY= 300;
s.stimulus.duration.ITI = 1.5;
s.stimulus.disp= .8; 
s.stimulus.disp1= 2.5; %originally 1, changed 3/19, changed to 2.5 4/13
s.stimulus.disp2= .8; %originally .5, changed 3/19, changed to .8 4/13


%set up the viewing distance
s.display.viewdist = 75; 
s.display.useOverlay=0;

s.stimulus.cond.Ncond=12; %stim side x color
%s.stimulus.cond.counterIdx{1}=[1 1 1 1 3 3 2 2 2 2 4 4]; %index into the counter for each condition
s.stimulus.cond.counterIdx{1}=[1 1 2 2 3 3 1 1 2 2 3 3];  %for _2
s.stimulus.cond.counterNames{1}={'Mono'; 'SmallDisp'; 'LargeDisp'};
%s.stimulus.cond.counterNames{1}={'L-Mono';'R-Mono';'L-Stereo';'R-Stereo'};