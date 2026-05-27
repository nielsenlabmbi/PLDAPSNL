function s = portcalib_time_settings

%set reward amounts

s.behavior.reward.amount = [0.35 0.35 0.35];
s.behavior.reward.amountDelta = 0.1; %ml


%turn saving off (this is just acclimatiztion)
s.pldaps.nosave = 1;


