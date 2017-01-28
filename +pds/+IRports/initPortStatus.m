function p = initPortStatus(p)

%initialize a vector with the status of each IR port
%11/25/16 - kn wrote it

if(p.trial.ports.use)
   p.trial.ports.status=zeros(1,p.trial.ports.nPorts);
end
