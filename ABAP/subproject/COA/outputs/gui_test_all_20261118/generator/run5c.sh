. /tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad/g.sh
O=/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_all_20261118/zqm005
for i in 1 2 3; do shot $D/tmp.png; if python3 $D/iswhite.py $D/tmp.png; then xdotool key Return; sleep 1.5; fi; done
while IFS='|' read lot plant mat batch dt art her; do
  lot=$(echo $lot); plant=$(echo $plant); mat=$(echo $mat); batch=$(echo $batch); dt=$(echo $dt)
  [ -z "$lot" ] && continue
  [ -f $O/z5_$lot.png ] && continue
  d="${dt:6:2}.${dt:4:2}.${dt:0:4}"
  r=jr; [[ $lot == 05* ]] && r=sr
  for i in 1 2 3; do
    tc "/nzqm005"; sleep 2.5; shot $D/tmp.png
    if python3 $D/iswhite.py $D/tmp.png; then xdotool key Return; sleep 1.5; else break; fi
  done
  fld 322 197 "$d"; fld 299 226 "$plant"; fld 355 284 "$mat"; fld 323 313 "$batch"
  if [ $r = sr ]; then xdotool mousemove 31 428 click 1; else xdotool mousemove 31 399 click 1; fi
  xdotool key F8; sleep 14; shot $O/z5_$lot.png
  echo "$lot done" >> $O/progress.txt
done < $D/qals2.txt
echo FIN2 >> $O/progress.txt
