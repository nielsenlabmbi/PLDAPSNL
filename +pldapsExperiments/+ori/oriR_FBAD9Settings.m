function s = oriR_FBAD9Settings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.15 0.35 0.35 0.35];


%set orientation and offsets
%s.stimulus.offsets{1} = [20];
% s.stimulus.offsets{1} = [20];
% s.stimulus.offsets{2} = [18 14 10 6];
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
s.stimulus.offsets =  horzcat({45},{[45,45,35,25,15,5]});%
s.stimulus.shift = [0 0];
s.stimulus.angle = 45;
s.stimulus.sf = 0.1;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = ones(1,length(s.stimulus.offsets));

s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function

s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 




%%% Debugging settings
% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% s.datapixx.din.useFor.ports =0;
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% %turn saving off
% s.pldaps.nosave = 1;