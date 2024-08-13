
function s = ori_FBAE1Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 1; %use midpoint IR beam to turn off stimulus (o off, 1 on)
s.stimulus.offStim = 0.0; %stimulus turns off offStim sec after midpoint (if selected)
%s.stimulus.offsets = horzcat({[25]},{[25]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[25 15 10 8 5]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[6]});
s.stimulus.shift = [0 0];
s.stimulus.angle = [0 90];
s.stimulus.sf = 0.20;
s.stimulus.range = [127 100 50 20 6]; % 127 alone is full range of contrasts, limit by adding lower ranges to the vector
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = [0 1]; %[1 0] to start with full screen
%s.stimulus.sideMatch = [1 -1];


%set viewing parameters
s.stimulus.radius=19; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 45; %set at 75 by default,45 from 2nd IR beam location, 60 is distance from most distant IR beam to screen

% 
% % Debugging settings
% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;