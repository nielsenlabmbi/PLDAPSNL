function s = shape_XXXX0Settings
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.shapePos=0; %id of positive stimulus
s.stimulus.shapeNeg=0; %id of negative stimulus
s.stimulus.shapeOffset=300; %offset of each stimulus to the side relative to center
s.stimulus.shapeScale=10; %scale factor for shape (in pixels)


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
