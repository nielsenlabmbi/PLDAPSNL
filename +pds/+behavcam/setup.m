function p = setup(p)

%setup communication with GigE camera used to record behavior;
%generate preview window and set filename

if p.trial.camera.use
    
    %establish UDP link
    port = instrfindall('RemoteHost',p.trial.camera.cameraIP);
    if ~isempty(port)
        fclose(port);
        delete(port);
        clear port;
    end
    
    % make udp object
    p.trial.camera.udpHandle = udp(p.trial.camera.cameraIP,...
        'RemotePort',p.trial.camera.udpRemotePort,'LocalPort',p.trial.camera.udpLocalPort);
    
    fopen(p.trial.camera.udpHandle);
    
    %generate preview
    msg='preview~';
    fwrite(p.trial.camera.udpHandle,msg);
    
    %acknowledge preview?
    
    %send filename
    
end