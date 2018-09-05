function p = blank2P(p,state)
%used to blank the laser when imaging is unnecessary
%state is a string, where '0' blanks the laser

if p.trial.twoP.use && ~isempty(p.trial.twoP.sbudp)
    pds.sbserver.send_sbserver(p,sprintf('L%s',state));
end