# TODO

# Higher Priority
-[ ] Update bug reporting URL in translation .po files (`app/locale/fortune/*.po`) from `https://connectbot.org/bug` to `https://github.com/johnrobinsn/VibeTTY/issues`
-[X] Not crazy that we're using volumne up and down for fontsize changes... will sort of convenient... its' a pain if we just want to change the volume

## Low Priority
-[ ] Cleanup graphics and feature graphic (annoying defects)

## Futures (not committed)
-[ ] Consider someway for an agent to "upgrade the connection" beyond just ssh.  sharing webservers or UI remotely... but then letting us downgrade back to ssh

## Futures recommended VibeMux config (not recommended)
-[ ] tmux section in readme.md
-[ ] tmux config ctrlA + dn should move to next panel and if there is no other panel it should split down to create one


## Notes
* ssh has a number of advantages in that it's basically a fairly ubiquitous command/control channel that allows for good baseline communication to agentic coding agents.  It also has support for dynamic port forwarding that allows us to share other services dynamically... We just need a standard/discoverable upgrade mechanism to do it.  I have a the server-side port forwarding SPEC.  add port...and send urls for sharing dev webserver endpoints and possibly sharing UI etc.. the other idea would be to use webrtc as the command control channel... which would allow for peer to peer transmission of information.pus