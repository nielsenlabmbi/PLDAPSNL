function p = getData(p)
%pds.datapixx.din.getData     gets data from Datapixx DinLog

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.din.channelMapping)
    return;
end
nMaps = length(p.trial.datapixx.din.channelMapping);
%get status
Datapixx('RegWrRd');
dinStatus = Datapixx('GetDinStatus');
% read new frames, check that we are monitoring frequently enough
% if dinStatus.newLogFrames > 1
%     warning('pds:datapixxdingetData','overflow: getData was not called often enough. Some data is lost.');
%     
% end
if dinStatus.newLogFrames > 0
    [log_data, tt] = Datapixx('ReadDinLog');
    for i = 1:dinStatus.newLogFrames
    data = dec2bin(log_data(i));
    %starti = p.trial.datapixx.din.dataSampleCount+1;
    %endi = p.trial.datapixx.din.dataSampleCount + dinStatus.newLogFrames;
    %inds = starti:endi;
    %p.trial.datapixx.din.dataSampleCount = endi;
    %p.trial.datapixx.din.dataSampleTimes(inds) = tt;
    p.trial.datapixx.din.dataSampleCount = p.trial.datapixx.din.dataSampleCount+1;
    p.trial.datapixx.din.dataSampleTimes(p.trial.datapixx.din.dataSampleCount) = tt(i);
    for imap = 1:nMaps
        iSub = p.trial.datapixx.din.channelMappingSubs{imap};
        iSub(end).subs{2} = p.trial.datapixx.din.dataSampleCount; %inds;
        
        channelStatus = [];
        for nCh = 1:length(p.trial.datapixx.din.channelMappingChannels{imap});
            channelStatus = [channelStatus str2double(data(length(data)-p.trial.datapixx.din.channelMappingChannels{imap}(nCh)))];
        end
        
        p = subsasgn(p,iSub,channelStatus);
        
        if p.trial.datapixx.din.useFor.ports
            p.trial.ports.status = ones(size(channelStatus))-channelStatus;
        end
        
        if p.trial.daq.use && p.trial.datapixx.din.useFor.daq
            %record the time relative to trial start (that's it for now)
            p.trial.daq.timestamp(inds) = datapixx.din.dataSampleTimes(inds) - p.trial.trstart;
        end
    end   
    end
else
    %indicate no state change
    p.trial.datapixx.din.dataSampleCount = p.trial.datapixx.din.dataSampleCount+1;
    p.trial.datapixx.din.dataSampleTimes(p.trial.datapixx.din.dataSampleCount) = Datapixx('GetTime');
    for imap = 1:nMaps
       iSub = p.trial.datapixx.din.channelMappingSubs{imap};
       if p.trial.datapixx.din.dataSampleCount > 1
           iSub(end).subs{2} = p.trial.datapixx.din.dataSampleCount -1; %get the previous state
           channelStatus = subsref(p,iSub);
           iSub(end).subs{2} = p.trial.datapixx.din.dataSampleCount;
           p = subsasgn(p,iSub,channelStatus);
       else
           iSub(end).subs{2} = p.trial.datapixx.din.dataSampleCount;
           p = subsasgn(p,iSub,[1 1 1]);
       end
    end
         
end


