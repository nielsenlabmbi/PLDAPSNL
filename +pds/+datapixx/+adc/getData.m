function p = getData(p)
%pds.datapixx.adc.getData    getData from the Datapixx buffer
%
% p = pds.datapixx.adc.getData(p) 
%
% Retrieves new samples from the datapixx buffer during the trial
% (c) lnk 2012
%     jly modified 2013
%     jk  reqrote  2014 to use new parameter structure and add flexibilty
%                       and proper tracking of sample times

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.adc.channels)
    return;
end

%consider having a preallocated bufferData and bufferTimeTags
Datapixx('RegWrRd');
adcStatus = Datapixx('GetAdcStatus');

[bufferData, bufferTimetags, underflow, overflow] = Datapixx('ReadAdcBuffer', adcStatus.newBufferFrames,-1);
if underflow
    warning('pds:datapixxadcgetData','underflow: getData is called to often');
end
if overflow
    warning('pds:datapixxadcgetData','overflow: getData was not called often enough. Some data is lost.');
end

%transform data:
bufferData=diag(p.trial.datapixx.adc.channelGains)*(bufferData+diag(p.trial.datapixx.adc.channelOffsets)*ones(size(bufferData)));


starti=p.trial.datapixx.adc.dataSampleCount+1;
endi=p.trial.datapixx.adc.dataSampleCount+adcStatus.newBufferFrames;
inds=starti:endi;
p.trial.datapixx.adc.dataSampleCount=endi;

p.trial.datapixx.adc.dataSampleTimes(inds)=bufferTimetags;

nMaps=length(p.trial.datapixx.adc.channelMappingChannels);
for imap=1:nMaps
    iSub = p.trial.datapixx.adc.channelMappingSubs{imap};
    iSub(end).subs{2}=inds;
    
    p=subsasgn(p,iSub,bufferData(p.trial.datapixx.adc.channelMappingChannelInds{imap},:));
    
    if p.trial.datapixx.useAsPorts && ~p.trial.datapixx.din.useFor.ports %make sure we want adc and not din
        %if using adc channels to monitor ports, save the last or average value of the
        %relevant channels (indicated in mapping) to  port.status for
        %easier monitoring
        if strcmp(p.trial.datapixx.adc.channelMappingNames(imap),p.trial.ports.adc.portMapping)
            if p.trial.ports.adc.portAvg==0
                tmpData=bufferData(p.trial.datapixx.adc.channelMappingChannelInds{imap},end);
            else
                nAvg=max(p.trial.ports.adc.portAvg,size(bufferData,2));
                tmpData=bufferData(p.trial.datapixx.adc.channelMappingChannelInds{imap},end-nAvg+1:end);
            end
            %disp(size(tmpData))
            tmpData=tmpData.*p.trial.ports.adc.portPol;
            p.trial.ports.status = (tmpData < p.trial.ports.adc.portThreshold);
        end
    end
    
end  

