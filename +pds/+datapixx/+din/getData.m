function p = getData(p)
%pds.datapixx.din.getData     gets data from Datapixx DinLog

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.din.channelMapping)
    return;
end

%get status
Datapixx('RegWrRd');
dinStatus = Datapixx('GetDinStatus');
% read new frames, check that we are monitoring frequently enough
if dinStatus.newLogFrames > 0
    [data, tt] = Datapixx('ReadDinLog');
    data = dec2bin(data);
    starti = p.trial.datapixx.din.dataSampleCount+1;
    endi = p.trial.datapixx.din.dataSampleCount + dinStatus.newLogFrames;
    inds = starti:endi;
    p.trial.datapixx.din.dataSampleCount = endi;
    p.trial.datapixx.din.dataSampleTimes(inds) = tt;
    
    nMaps = length(p.trial.datapixx.din.channelMapping);
    for imap = 1:nMaps
        iSub = p.trial.datapixx.din.channelMappingSubs{imap};
        iSub(end).subs{2} = inds;
        
        p = subsasgn(p,iSub,str2double(data(length(data)-p.trial.datapixx.din.channelMappingChannels{imap})));
        
        if p.trial.datapixx.din.useFor.ports
            p.trial.ports.status = ones(size(p.trial.ports.status))-str2num(data(length(data)-p.trial.datapixx.din.channelMappingChannels{imap},:));
        end
        
        if p.trial.daq.use && p.trial.datapixx.din.useFor.daq
            %record the time relative to trial start (that's it for now)
            p.trial.daq.timestamp(inds) = datapixx.din.dataSampleTimes(inds) - p.trial.trstart;
        end
    end
else
    
end
if dinStatus.newLogFrames > 1
    warning('pds:datapixxdingetData','overflow: getData was not called often enough. Some data is lost.');
end


