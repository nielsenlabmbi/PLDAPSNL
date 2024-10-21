function s = ori_FBAD7Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
%s.stimulus.offsets = horzcat({[25]},{[25]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[25 15 10 8 5]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[6]});
s.stimulus.shift = [0 0];
s.stimulus.angle = [0 90];

s.stimulus.offStim=1;


% %testing new angle
% % use this for psychometric testing, while keeping traditional angle
% % commented
% %.psych is 1 if discrimination between degrees, 0 if only using [0 90].
%s.stimulus.psych = 1;
% %This version of angle will be a graded change in angle:
% %If side is 90 degrees: 90 82 74 66 58 50
% %If side is 0 degrees: 0 8 16 24 32 40
%s.stimulus.angle = [{[0]}, {[1]}, {[2]}, {[3]}, {[4]}, {[5]}, {[6]}, {[7]}, {[0,1,2,3,4,5,6,7]}, {[4,5]}, {[4,5,6]}, {[5,7]}];
% %0 is left 180 is right
%s.stimulus.direction = [0 180];



s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 1;
%s.stimulus.sideMatch = [1 -1];


%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 

% 
% % Debugging settings
% 
%turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
%turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;