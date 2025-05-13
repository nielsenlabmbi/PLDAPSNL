function s = box_acclimation_Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0.5;
s.stimulus.lickdelay = 0.35;
s.stimulus.fracInstruct = 0;

s.datapixx.adc.channels = [2 4 6];
s.ports.nports=3;
% 
% %debugging
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
