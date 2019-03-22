function s = ori_FBAA6Settings
% turn saving off
% s.pldaps.nosave = 1;
%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set orientation and offsets
s.stimulus.sf_step = 0.25;
s.stimulus.step = 0; %0.01
s.stimulus.sf_list = {0.25};

s.stimulus.angle = [0 90];
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = [1 0];
s.stimulus.midpointIR = 0;


%set viewing parametersqS
s.stimulus.radius=12; %stimulus radius in deg 
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 
% 
% % % 
% %%% Debugging settings
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