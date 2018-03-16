function s = ori_generalSettings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.1 0.35 0.35];

%set orientation and offsets
s.stimulus.offsets = [20];
s.stimulus.angle = 45;
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.baseline = 0.3;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.2;
s.stimulus.fracInstruct = 0.7;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 1;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 1.5;
%set up the viewing distance
s.display.viewdist = 45; 
% 
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

