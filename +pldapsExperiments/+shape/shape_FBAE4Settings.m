function s = shape_FBAE4Settings
% % turn saving off
% s.pldaps.nosave = 1;

s.stimulus.forceCorrect = 0;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.shapePos=1; %id of positive stimulus
s.stimulus.shapeNeg=1; %id of negative stimulus
s.stimulus.shapeOffset=600; %offset of each stimulus to the side relative to center
s.stimulus.shapeScale=150; %scale factor for shape (in pixels)
s.display.bgColor = [0 0 0 ];

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
