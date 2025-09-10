function p = keyboardCmd(p)

%firstPressQ contains an array with time stamps for each key
%if key has been pressed, then time stamps > 0

%format below would in principle allow multiple keys to have been pressed

%%%%general command keys
if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.oKey)   
    pds.audio.playDatapixxAudio(p,'breakfix');
    p.trial.pldaps.quit = 1;
    ShowCursor;
end

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
    disp(['***Trial lock status: ' num2str(p.trialMem.lock)]); %actual locking happens in defaultTrialFunction
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Larrow) %left arrow = user 1
    p.trial.userInput=1;
    disp('left key')
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Rarrow) %right arrow = user 2
    p.trial.userInput=2;
    disp('right key')
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Uarrow) %up arrow = user 3
    p.trial.userInput=3;
    disp('up key')
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Darrow) %down arrow = user 4
    p.trial.userInput=4;
    disp('down key')
end

%edit 8/28/25 added N and M and O key for non-match, match, and all conditions
%for lesion experiments
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.mKey) %right arrow = user 5
    p.trial.userInput=5;
    disp('M key')
end
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.nKey) %right arrow = user 6
    p.trial.userInput=6;
    disp('N key')
end
if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.oKey) %right arrow = user 7
    p.trial.userInput=7;
    disp('O key')
end

if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.spaceKey) %change trials list
    p.trialMem.whichConditions = mod(p.trialMem.whichConditions+1,length(p.trial.allconditions));
    p.conditions = p.trial.allconditions{p.trialMem.whichConditions + 1};
    disp(['Switched to trials list:' num2str(p.trialMem.whichConditions) ]);
    p.trial.userInput= -1;
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
        portId=p.trial.stimulus.side.LEFT;
        moveP=1;
    end
    if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.sKey)  %move spout 2
        portId=p.trial.stimulus.side.MIDDLE;
        moveP=1;
    end
    if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.dKey)  %move spout 3
        portId=p.trial.stimulus.side.RIGHT;
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
