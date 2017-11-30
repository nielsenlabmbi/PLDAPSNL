function s = plain3_generalSettings

s.display.bgColor = [0 0 0];
%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.useAsEyePos = 1;
%s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;