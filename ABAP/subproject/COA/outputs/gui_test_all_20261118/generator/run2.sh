. /tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad/g.sh
O=/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_all_20261118/zqm002
for do in 0085006234 0085006235 0085006240 0085006241 0085006242 0085006243 0085006244 0085006245 0085006270 0085006271 0085006272 0085006276 0085006277 0085006278 0085006279 0085006280 0085006281 0085006282 0085006284 0085006285 0085006286; do
  tc "/nzqm002"; sleep 2; xdotool mousemove 100 128 click 1; sleep 1.5
  tc "/nzqm002"; sleep 3
  xdotool mousemove 335 285 click 1; xdotool key ctrl+a; xdotool type --delay 20 "$do"; xdotool key F8; sleep 6
  shot $O/z2_$do.png; echo "$do" >> $O/progress.txt
done
echo FIN >> $O/progress.txt
