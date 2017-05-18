function camCb(obj,event)
%Callback function from Stimulus PC

global DcomState

n=get(DcomState.serialPortHandle,'BytesAvailable');
if n > 0
    inString = fread(DcomState.serialPortHandle,n);
    inString = char(inString');
else
    return
end

inString = inString(1:end-1);  %Get rid of the terminator

