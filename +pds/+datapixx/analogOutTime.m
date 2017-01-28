function analogOutTime(open_time, chan, TTLamp,sampleRate) 
% Send a [TTLamp] volt signal out the channel [chan], for [open_time] seconds
% 
% Datapixx must be open for this function to work. 
%
% INPUTS:
%	      open_time - seconds to send signal (default = .5)
%              chan - channel on datapixx to send signal 
%                     (you have to map your breakout board [3 on huk rigs])
%            TTLamp - voltage (1 - 5 volts can be output) defaults to 3
% 
%
% written by Kyler Eastman 2011
% modified by JLY 2012 - replaced if~exist with nargin calls for speedup
% modified by JK  2014 - slight adjustments for use with version 4.1
% modified by KN 2017 


bufferData = [TTLamp*ones(1,round(open_time*sampleRate)) 0] ;
maxFrames = length(bufferData);

Datapixx('WriteDacBuffer', bufferData ,0 ,chan);

Datapixx('SetDacSchedule', 0, sampleRate, maxFrames ,chan);
Datapixx StartDacSchedule;
Datapixx RegWrRd;


