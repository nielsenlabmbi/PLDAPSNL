function p=movePort(port,position,p)

%moves reward spout(s) (port) into (1) or out of (0) reward position
%TTL signal high: port retracted
%TTL signal low: port extended

if p.trial.ports.use && p.trial.ports.movable
    
    %first set port status (1: extended)
    p.trial.ports.position(port)=position;
    
    %we will use the status vector to determine which signal to send via
    %the dio ports; but need to invert the signal
    pos=1-p.trial.ports.position;
    word=bi2de(pos);
    
    %set digital channels
    Datapixx('SetDoutValues', word);
    Datapixx('RegWrRd');
    
end

