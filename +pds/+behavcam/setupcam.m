function p = setupcam(p)

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
    
    % set udp parameters
    set(p.trial.camera.udpHandle, 'InputBufferSize', 1024)
    set(p.trial.camera.udpHandle, 'OutputBufferSize', 1024)
    set(p.trial.camera.udpHandle, 'Datagramterminatemode', 'off')
    set(p.trial.camera.udpHandle, 'BytesAvailableFcnMode', 'Terminator');
    set(p.trial.camera.udpHandle, 'Terminator','~'); 

    %open port and check
    fopen(p.trial.camera.udpHandle);
    stat=get(p.trial.camera.udpHandle, 'Status');

    if ~strcmp(stat, 'open')
        disp([' Trouble opening connection to camera computer; cannot proceed']);
        p.trial.camera.udpHandle=[];
        return;
    end

    
    disp('UDP connection to camera established');
    
    %generate preview
    msg='P~';
    fwrite(p.trial.camera.udpHandle,msg);
    pds.behavcam.waitforCamResp(p);
    
    disp('Preview generated');

    %send filename
    fname=p.trial.session.file;
    fname=fname(1:end-4);
    msg=['F;' fname '~'];
    fwrite(p.trial.camera.udpHandle,msg);
    pds.behavcam.waitforCamResp(p);
    
    disp('Filename sent to camera computer');
    
    %rest is handled in runTrial loop
end