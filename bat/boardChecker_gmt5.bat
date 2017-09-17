gmt gmtset MAP_TICK_LENGTH_PRIMARY=0.05c MAP_FRAME_PEN=0.2p MAP_FRAME_WIDTH=0.1c
gmt gmtset FORMAT_GEO_MAP=ddd:mm:ssF FONT_ANNOT=8p FONT_LABEL=12p 
gmt gmtset MAP_ANNOT_OFFSET_PRIMARY 0.2c

set R=98/104.5/22.8/29.2
gmt makecpt -Credblue -T-6/6/6 -D > vel.cpt

rem :infile of pslegend code
echo C black >temp
echo G 0.15c >>temp
echo N 5 >>temp
echo S 0.5c c 0.48c red 0.25p,red 0.8c -6 >>temp
echo S 0.5c c 0.24c red 0.25p,red 0.7c -3 >>temp
echo S 0.5c c 0.01c black 0.25p,black 0.6c 0 >>temp
echo S 0.5c c 0.24c blue 0.25p,blue 0.7c 3 >>temp
echo S 0.5c c 0.48c blue 0.25p,blue 0.8c 6 >>temp
echo N 1 >>temp
echo G 0.2c >>temp
echo L 8 4 C @~\104@~V@-p@- / V@-p@-@~\050\045\051@~ >>temp

for %%i in (0,10,20,30,40,50,80) do (

gmt psbasemap -R%R% -JM10c -Bf0.5a1 -BWesN -P -Xc -Yc -K > pertur%%i.ps
echo P波检测板结果分布G4@~\050@~z=%%ikm@~\051@~ | gmt pstext -R -J -F+cBC+f20p,38 -Dj0i/-2.5c -N -O -K >> pertur%%i.ps
gmt psxy fault.dat -R -J -W0.5p -O -K >> pertur%%i.ps

gawk "{if($3 > -4 && $3 < 4) print $1,$2,$3,sqrt($3**2)*0.08*1.5}" perturfie%%i.dat | gmt psxy -R -J -Sc -Cvel.cpt -O -K >> pertur%%i.ps
gawk "{if($3 <= -4 || $3 >= 4) print $1,$2,$3}" perturfie%%i.dat | gmt psxy -R -J -Sc0.48c -Cvel.cpt -O -K >> pertur%%i.ps

gmt pslegend temp -DjCB+w7.5c/1.3c+o0c/-1.6c -R -J -F+g255/228/255 -O -K >> pertur%%i.ps

gmt psxy -R -J -T -O >> pertur%%i.ps 
gmt psconvert pertur%%i.ps -A -Tj -GD:\ProgramFiles\gs\gs9.20\bin\gswin64c.exe -C-sFONTPATH=C:\Windows\Fonts
)
del gmt.*
pause