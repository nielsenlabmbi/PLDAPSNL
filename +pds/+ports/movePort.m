function p=movePort(port,position,p)

%moves reward spout(s) (port) into (1) or out of (0) reward position
%TTL signal high: port retracted
%TTL signal low: port extended

if p.trial.ports.use && p.trial.ports.movable
    %first set port status
    p.trial.ports.position(port)=position;
    
    % 'port', as an input, is indexed by side, so we have to align these indices
    % see pdsDefaultTrialStructureNL(in support functions) for side
    % assignment
    
    channels = [p.trial.ports.dio.channel.RIGHT, p.trial.ports.dio.channel.LEFT, p.trial.ports.dio.channel.MIDDLE];
    sides = [p.trial.stimulus.side.RIGHT, p.trial.stimulus.side.LEFT, p.trial.stimulus.side.MIDDLE];
    
    %get aligned index
    idx = ismember(sides,port);
    
    out_channel = channels(idx);
    
    digword = 1-position;
    digital_out(out_channel,digword);
%     
%     %first set port status (1: extended)
%     p.trial.ports.position(port)=position;
%     
%     %we will use the status vector to determine which signal to send via
%     %the dio ports; but need to invert the signal    
%     wordvec=zeros(1,24);
%     wordvec(port)=1-position; %it is ok only to update the channels we want to move - the other ones are masked out
%     word=bi2de(wordvec);
%     
%     maskvec=zeros(1,24);
%     maskvec(port)=1;
%     mask=bi2de(maskvec);
% 
%     %set digital channels
%     Datapixx('SetDoutValues', word,mask);
%     Datapixx('RegWrRd');
    
end

