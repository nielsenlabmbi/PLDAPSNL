function s = som_FBAC0Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
% s.behavior.reward.pulseFreq = 3;
% s.behavior.reward.pulseInt = 0.2;


%set viewing parameters
s.stimulus.duration.ITI = 1.5;



%set stimulus parameters
s.stimulus.curvetype=[1 2]; %convex/concave
s.stimulus.shapeid=[1]; %there are 2 shapes per curvature
s.stimulus.solenoidCh=[8 6 4 2];
s.stimulus.movein=1; %ttl high moves shapes in
s.stimulus.moveout=0; 
s.stimulus.runtype = 'pseudo';
s.stimulus.sideMatch = [1 2];


% %configure ports
% s.ports.use = true;
% s.ports.nPorts = 3;
% s.ports.movable = true;
% s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
% s.datapixx.useAsEyepos = 0;
 %use din?
% s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
%s.mouse.useAsPort = 0;
% s.mouse.use = 0;
% 
% %%% Debugging settings
% % 
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