function s = shapeOutline_FBAE4Settings
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
s.stimulus.mov=0; %add movement?
s.stimulus.movAmpP=15; %movement amplitude in pixels %changed to start @ 15 12/10/24
s.stimulus.movAmpN=0; %movement amplitude in pixels %changed to start @ 15 12/10/24
s.stimulus.stepAmp=5; %change in amplitude with key press
s.stimulus.movFreq=40; %movement frequency in frames
s.stimulus.shapeType=[0 1]; %no outline, outline
s.stimulus.lineWidth=40;

%ignore midpoint IR port
s.datapixx.adc.channels = [2 4 6];
s.ports.nports=3;

