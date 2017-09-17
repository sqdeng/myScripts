gmt gmtset MAP_TICK_LENGTH_PRIMARY=0.05c MAP_FRAME_PEN=0.2p MAP_FRAME_WIDTH=0.1c
gmt gmtset FORMAT_GEO_MAP=ddd:mm:ssF FONT_ANNOT=8p FONT_LABEL=12p 
gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0.2c

set title="姚安地区P波相对扰动速度"
set R=98.5/104/23.5/28

gmt makecpt -Cred2blue -T-6/6/0.02 -Z -D > vel.cpt

rem -----------------------------------
for %%i in (0,5,15,25,35,45) do (

gmt psbasemap -R%R% -JM12c -Bf0.5a1 -BWesN -Xc -Yc -K -P > pertur%%i.ps
echo 滇西地区P波相对扰动速度@~\050@~z=%%ikm@~\051@~ | gmt pstext -R -J -F+cBC+f20p,38 -Dj0c/-2.5c -N -O -K >> pertur%%i.ps

gawk "{print $1,$2,$3}" perturfie%%i.dat | gmt blockmedian -R -I0.1m > median.xyz
gmt surface median.xyz -R -I0.2m -Gmedian.grd
gmt grdimage median.grd -R -J -Cvel.cpt -O -K >> pertur%%i.ps

gmt psxy fault.dat -R -J -W0.5p -O -K >> pertur%%i.ps
gmt psxy cityYN_gmt5.txt -R -J -Sc0.05i -O -K >> pertur%%i.ps
gmt pstext cityYN_gmt5.txt -R -J -F+f10p,35+j -O -K >> pertur%%i.ps

gawk "{if($4 >= %%i-2.5 && $4 <= %%i+2.5) print $3,$2,$17*0.02}" tomofdd.reloc | gmt psxy -R -J -Sc -Gwhite -O -K >> pertur%%i.ps
gawk "{if($4 >= %%i-2.5 && $4 <= %%i+2.5 && $17 >= 6.0) print $3,$2}" tomofdd.reloc | gmt psxy -R -J -Sa0.18 -W1.0p,black -Gwhite -O -K >> pertur%%i.ps
rem grdcontour median.grd  -J -C1.0 -O -K>> pertur%%i.ps

gmt gmtset MAP_LABEL_OFFSET=0.1c 
gmt psscale -R -J -DjCB+w7.0c/0.4c+o0c/-0.7c+h -Cvel.cpt -Bxa3+l"@~\050@~ wt=30 dm=250@~\051@~" -By+l"@~\104@~V@-p@-/V@-p@-" -O -K>> pertur%%i.ps

gmt psxy -R -J -T -O >> pertur%%i.ps 
gmt psconvert pertur%%i.ps -A -Tj -GD:\ProgramFiles\gs\gs9.20\bin\gswin64c.exe -C-sFONTPATH=C:\Windows\Fonts
)
del gmt.* median.* vel.cpt
pause