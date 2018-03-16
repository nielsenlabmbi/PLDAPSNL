
function p = calibrate_ports(p,state)
% Calibration of the ports

pldapsDefaultTrialFunction(p,state);

%add functions to particular states
switch state
    case p.trial.pldaps.trialStates.trialSetup
        p = trialSetup(p);
end

function p = trialSetup(p)
setupID = p.trial.behavior.reward.setupID;
%main loop
if strcmp(setupID,'fixed')
pulse = .1;%0.04:0.02:0.1;
p.trial.behavior.reward.logvals = zeros(length(pulse),3);

for j = 1:length(pulse)
    amount = pulse(j);
for i = 1:50
    pds.behavior.reward.give(p,amount,2); %left
    WaitSecs(0.1);
end
for i = 1:50
    pds.behavior.reward.give(p,amount,1); %right
    WaitSecs(0.1);
end
for i = 1:50
    pds.behavior.reward.give(p,amount,3); %start (middle)
    WaitSecs(0.1);
end
%keyboard
end

elseif strcmp(setupID,'free');
pulse = 0.5:-0.1:0.2;
p.trial.behavior.reward.logvals = zeros(length(pulse),3);

for j = 1:length(pulse)
    amount = pulse(j);
    for i = 1:100
        pds.behavior.reward.give(p,amount,2); %left
        WaitSecs(0.3 + amount);
    end
    keyboard
    for i = 1:100
        pds.behavior.reward.give(p,amount,1); %right
        WaitSecs(0.3 + amount);
    end
    keyboard
    % for i = 1:150
    %     pds.behavior.reward.give(p,amount,0); %middle
    %     WaitSecs(0.5);
    % end
end
end

figure; 
hold on;
l = cell(1,length(pulse));
for i = 1:length(pulse);
    plot(p.trial.behavior.reward.logvals(i,:))
    l{i} = num2str(pulse(i));
end
legend(l);
p.trial.pldaps.quit = 2;
%close dac