function s = portcalib_vol_settings

%set reward amounts
s.behavior.reward.amount = [0.5 0.5 0.5]; %volume in ml
s.behavior.reward.amountDelta = 0.1; %ml


%turn saving off (this is just acclimatiztion)
s.pldaps.nosave = 1;


