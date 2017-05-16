function p = initPortStatus(p)

%initialize a vector with the status and position of each port
%11/25/16 - kn wrote it

if p.trial.ports.use
   p.trial.ports.status=zeros(1,p.trial.ports.nPorts);
   
   if p.trial.ports.movable
       p.trial.ports.position=zeros(1,p.trial.ports.nPorts);
   end
       
end
