function p = close2P(p)

if p.trial.twoP.use
    
%stop data acquisition    
pds.sbserver.shutter2P(p,'1');
pds.sbserver.send_sbserver(p,'S');

%close the udp connection
if ~isempty(p.trial.twoP.sbudp)
    fclose(p.trial.twoP.sbudp);
    p.trial.twoP.sbudp = [];
end


port = instrfindall('RemoteHost',p.trial.twoP.IP);
    if ~isempty(port)
        fclose(port);
        delete(port);
        clear port;
    end
    
end
    