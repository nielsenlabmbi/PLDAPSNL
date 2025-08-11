function s = shapeRot_FBAE4Settings
% % turn saving off
% s.pldaps.nosave = 1;

s.stimulus.forceCorrect = 0;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.imgBase='/home/nielsenlab/shapeImg';
s.stimulus.posImg='plus';
s.stimulus.negImg='star';
s.stimulus.filetype='jpeg';
%s.stimulus.shapeScale=1; %scale factor for shape
s.display.bgColor = [0 0 0];
s.stimulus.rotShape=[0 1 2 3];%rotate none, positive, negative, or both shapes
s.stimulus.Nrot=8;

%ignore midpoint IR port
s.datapixx.adc.channels = [2 4 6];
s.ports.nports=3;

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
