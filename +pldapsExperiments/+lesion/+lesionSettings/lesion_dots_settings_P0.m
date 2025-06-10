function s = lesion_dots_settings_P0

%set reward amounts
%s.behavior.reward.amount = [0.1 0.1 0.1];;
%turn saving off (this is just acclimatiztion)
s.pldaps.nosave = 1;

%s.datapixx.adc.channels = [2 4 6];
%s.ports.nports=3;
