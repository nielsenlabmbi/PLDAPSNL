function s = opticFlow_generalSettings


%set reward amounts
s. behavior.   reward. amount = [0.1 0.35 0.35];

%set orientation and offsets
s.stimulus.frameRate = 120;
s.stimulus.stim_time = 360;
s.stimulus.x_pos = 960;
s.stimulus.y_pos = 540;
s.stimulus.stimDir = [1];
s.stimulus.stimRadius = 50;
s.stimulus.stimType = 4; 'Rand, Tx, Ty, C, R';
s.stimulus.dotDensity = 30;
s.stimulus.sizeDots = 0.2;
s.stimulus.speedDots = 10;
s.stimulus.dotLifetime = 240;
s.stimulus.dotCoherence = 100;
s.stimulus.dotType = 1; 'sq, circ';
s.stimulus.deltaXY = [-10 10];
s.stimulus.shiftX = [1 0];

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 0.2;
s.stimulus.duration.ITI = 3; %s.stimulus.stim_time/s.stimulus.frameRate;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0;


%set up the viewing distance
s.display.viewdist = 75; 

% % %configure ports
%  s.ports.use = true;
%  s.ports.nports = 3;
%  s.ports.movable = true;
%  s.datapixx.adc.channels = [1 3 5];
%  
%  %turn mouse input off
% s.mouse.useAsPort = 0;
% s.mouse.use = 0;
% 
%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

% turn saving off
s.pldaps.nosave = 1;