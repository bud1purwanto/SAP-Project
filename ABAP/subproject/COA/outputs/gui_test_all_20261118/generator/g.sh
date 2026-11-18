export DISPLAY=:99
D=/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad
tc() { xdotool mousemove 108 66 click 1; xdotool key ctrl+a; xdotool type --delay 30 "$1"; xdotool key Return; }
shot() { python3 $D/shot.py "$1"; }
fld() { xdotool mousemove $1 $2 click 1; xdotool key ctrl+a; xdotool type --delay 20 "$3"; }
z5() { # date plant mat batch radio(jr|sr) out
  tc "/nzqm005"; sleep 2.5
  fld 322 197 "$1"; fld 299 226 "$2"; fld 355 284 "$3"; fld 323 313 "$4"
  if [ "$5" = sr ]; then xdotool mousemove 31 428 click 1; else xdotool mousemove 31 399 click 1; fi
  xdotool key F8; sleep 4; shot "$6"; }
