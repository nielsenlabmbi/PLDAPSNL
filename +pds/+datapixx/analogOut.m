function analogOut(data,chan,sampleRate) 
% Send a [data] signal out the channel [chan]
% 
% Datapixx must be open for this function to work. 
%
% INPUTS:
%	      data: signal to be sent
%              chan - channel on datapixx to send signal 
%                     (you have to map your breakout board [3 on huk rigs])
% 


maxFrames = length(data);

Datapixx('WriteDacBuffer', data ,0 ,chan);

Datapixx('SetDacSchedule', 0, sampleRate, maxFrames ,chan);
Datapixx StartDacSchedule;
Datapixx RegWrRd;


