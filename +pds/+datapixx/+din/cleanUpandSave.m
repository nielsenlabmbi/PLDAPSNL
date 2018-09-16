function p = cleanUpandSave(p)

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.din.channelMapping)
    return;
end

maxDataSamplesPerTrial = size(p.trial.datapixx.din.dataSampleTimes,2);

nMaps = length(p.trial.datapixx.din.channelMappingsChannels);
if p.trial.datapixx.din.dataSampleCount < maxDataSamplesPerTrial/2
    inds=1:p.trial.datapixx.din.dataSampleCount;
        p.trial.datapixx.din.dataSampleTimes=p.trial.datapixx.din.dataSampleTimes(inds);
        for imap=1:nMaps
            
            iSub = p.trial.datapixx.din.channelMappingSubs{imap};
            iSub(end).subs{2}=inds;
            iSub(end).subs{1}=':';

            p=subsasgn(p,iSub(1:end-1),subsref(p,iSub));
        end

elseif p.trial.datapixx.din.dataSampleCount < maxDataSamplesPerTrial
    inds=p.trial.datapixx.din.dataSampleCount+1:maxDataSamplesPerTrial;
        p.trial.datapixx.din.dataSampleTimes(inds)=[];
        for imap=1:nMaps

            iSub = p.trial.datapixx.din.channelMappingSubs{imap};
            iSub(end).subs{2}=inds;
            iSub(end).subs{1}=':';

            p=subsasgn(p,iSub,[]);
        end
end