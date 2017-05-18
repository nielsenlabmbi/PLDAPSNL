function p=closecam(p)

%tell camera computer to finish acquisition

if p.trial.camera.use
    msg='E~';
    fwrite(p.trial.camera.udpHandle,msg);
    pds.behavcam.waitforCamResp(p);
end