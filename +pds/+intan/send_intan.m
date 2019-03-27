function p = send_intan(p,channel,digword)
% this function is used to send digital pulses to intan as trial event
% markers
if p.trial.ephys.use
    digital_out(channel,digword);
end