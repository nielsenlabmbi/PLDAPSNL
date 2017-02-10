function p = keyboardCmd(p)

%firstPressQ contains an array with time stamps for each key
%if key has been pressed, then time stamps > 0

%format below would in principle allow multiple keys to have been pressed

%%%%general command keys
if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.pKey)   % P = pause
    p.trial.pldaps.quit = 1;
    ShowCursor;
end

if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.qKey) % Q = quit
    p.trial.pldaps.quit = 2;
    ShowCursor
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.lKey) % l=toggle lock trial
    p.trialMem.lock=1-p.trialMem.lock;
    disp(['***Trial lock status: ' num2str(p.trialMem.lock)]); 
end

%%%%%change reward amounts
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.oneKey)   % reward change
    pds.behavior.reward.updateAmount(p,1);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.twoKey)   % reward change
    pds.behavior.reward.updateAmount(p,2);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.thrKey)   % reward change
    pds.behavior.reward.updateAmount(p,3);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.forKey)   % reward change
    pds.behavior.reward.updateAmount(p,4);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.fivKey)   % reward change
    pds.behavior.reward.updateAmount(p,5);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.sixKey)   % reward change
    pds.behavior.reward.updateAmount(p,6);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.svnKey)   % reward change
    pds.behavior.reward.updateAmount(p,7);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.eitKey)   % reward change
    pds.behavior.reward.updateAmount(p,8);
end

%%%%%toggle reward spout position
if p.trial.ports.movable
    moveP=0;
    if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.aKey)  %move spout 1
        portId=p.trial.ports.dio.channel.LEFT;
        moveP=1;
    end
    if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.sKey)  %move spout 2
        portId=p.trial.ports.dio.channel.MIDDLE;
        moveP=1;
    end
    if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.dKey)  %move spout 3
        portId=p.trial.ports.dio.channel.RIGHT;
        moveP=1;
    end
    if moveP==1
        p.trial.ports.position(portId)=1-p.trial.ports.position(portId);
        pds.ports.movePort(portId,p.trial.ports.position(portId),p); 
    end
end

%%%%%deliver reward through a particular spout
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.zKey)
    pds.behavior.reward.give(p,p.trial.behavior.reward.manualAmount,...
        p.trial.behavior.reward.channel.LEFT);
end
   
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.xKey)
    pds.behavior.reward.give(p,p.trial.behavior.reward.manualAmount,...
        p.trial.behavior.reward.channel.START);
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.cKey)
    pds.behavior.reward.give(p,p.trial.behavior.reward.manualAmount,...
        p.trial.behavior.reward.channel.RIGHT);
end
