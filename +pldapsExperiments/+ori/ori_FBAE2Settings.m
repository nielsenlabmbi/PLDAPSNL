function s = ori_FBAE2Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
s.stimulus.offStim = 0.5; %stimulus turns off offStim sec after midpoint (if selected)
%s.stimulus.offsets = horzcat({[25]},{[25]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[25 15 10 8 5]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[6]});
s.stimulus.shift = [0 0];
s.stimulus.angle = [0 90];
s.stimulus.sf = 0.1;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = [0 1];
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