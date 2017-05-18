function p=close(p)

%tell camera computer to finish acquisition
 msg='E~';
 fwrite(p.trial.camera.udpHandle,msg);
 pds.camera.waitforCamResp(p);