function p = getData(p)
%pds.datapixx.din.getData     gets data from Datapixx DinLog

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.din.channels)
    return;
end

%get status
Datapixx('RegWrRd');
dinStatus = Datapixx('GetDinStatus');
% read new frames, check that we are monitoring frequently enough
if dinStatus.newLogFrames > 0
    [data tt] = Datapixx('ReadDinLog');
    data = dec2bin(data);
    starti = p.trial.datapixx.din.dataSampleCount+1;
    endi = p.trial.datapixx.din.dataSampleCount + dinStatus.newLogFrames;
    inds = starti:endi;
    p.trial.datapixx.din.dataSampleCount = endi;
    
    nMaps = length(p.trial.datapixx.din.channelMappingChannels);
    for imap 1:nMaps
        iSub = p.trial.datapixx.din.channelMappingsSubs{imap};
        iSub(end).subs{2} = inds;
        
        p = subsasgn(p,iSub,data(p.tral.datapixx.din.channelMappingChannelIndx{imap},:));
        
        if p.trial.datapixx.din.useAsPorts
            p.trial.ports.status = 
        end
        
        if p.trial.daq.use
        end
else
    
end
if dinStatus.newLogFrames > 1
    warning('pds:datapixxdingetData','overflow: getData was not called often enough. Some data is lost.');
end

%transform the data


