function p = start(p)
%
% p = pds.datapixx.din.start(p) 
%
% The function starts a continuous schedule of DIN data acquisition, stored 
% on the datapixx buffer.
% Data will be read in by repeatedly (once per frame or trial) calling
% pds.datapixx.din.getData (using Datapixx('ReadDinLog')) and when
% pds.datapixx.din.stop is called, which will also stop din data aquesition (Datapixx('StopDinLog'))
% parameters that are required by Datapixx are in the '.datapixx.din.' fields.
% 
% INPUTS
%	p   - pldaps class
% with parameters set: 
% p.trial
%       .datapixx.daq.use 
%       .datapixx.din.channels 
%       .datapixx.din.bufferAddress 
%       .datapixx.din.numBufferFrames 
%       .datapixx.din.channelMapping %cell array with targets in the trial
%       .datapixx.din.channelSampleCountMapping %cell array with targets in the trial
%       struct where this should get mapped to
% (c) lnk 2012
%     jly modified 2013
%     jk  modified 2014 new parameter structure, add flexibility, sample timing
%     edw 2018
%% channel mapping
if ~p.trial.datapixx.use 
    return;
end
uses = fieldnames(p.trial.datapixx.din.useFor);
maps = [];
refs = [];
for i = 1:length(uses)
    S.type = '.';
    S.subs = uses{i};
    if subsref(p.trial.datapixx.din.useFor,S)
        maps = horzcat(maps,{['datapixx.din.' uses{i}]});
        refs = horzcat(refs,uses(i));
    end
end
p.trial.datapixx.din.channelMapping = maps;
nMaps = length(maps);
if nMaps == 0
    return;
end

p.trial.datapixx.din.channelMappingChannels = cell(nMaps,1);
p.trial.datapixx.din.channelMappingSubs = cell(nMaps,1);
T.type = '.';
T.subs = 'trial';

for imap = 1:nMaps
    S.type = '.';
    S.subs = refs{imap};
    p.trial.datapixx.din.channelMappingChannels{imap} = subsref(p.trial.datapixx.din.channels,S); 
    %p.trial.datapixx.din.channelMappingChannelInds{imap} = imap;
    % get levels
    levels = textscan(maps{imap},'%s','delimiter','.');
    levels = levels{1};
    F = repmat(T,[1,length(levels)]);
    [F.subs] = levels{:};
    C.type = '()';
    C.subs = {1:length(p.trial.datapixx.din.channelMappingChannels{imap}),1};
    p.trial.datapixx.din.channelMappingSubs{imap} = [T F C];
end

p.trial.datapixx.din.dataSampleCount=0;

%start logging
Datapixx('StartDinLog');

% timing
p.trial.datapixx.din.startDatapixxTime = Datapixx('GetTime'); %GetSecs;
p.trial.datapixx.din.startPldapsTime = GetSecs;
[getsecs, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');
p.trial.datapixx.din.startDatapixxPreciseTime(1:3) = [getsecs, boxsecs, confidence]; 

 