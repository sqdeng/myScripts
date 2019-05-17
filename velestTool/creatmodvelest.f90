!-----Creat the MOD file
  Program creatmod
  implicit none
  integer i,l
  Integer nz
  Real zn(50)
  Real vpn(50)
  real vdamp
  Character line*150,headline*60
  Character mod_initial_file*30,mod_finall_file*30,fm*25
  logical :: alive
  integer :: narguments
  
  narguments = iargc()
  if(narguments.lt.1) then
     write(*,'(/,a)') 'PARAMETER INPUT FILE [mode.inp <ret>]:'
     read(5,'(a)') mod_initial_file
     if(LEN_TRIM(mod_initial_file).le.1) then
        mod_initial_file= 'mode.inp' !default input file name
     else
        mod_initial_file= mod_initial_file(1:LEN_TRIM(mod_initial_file))
     endif
  else
     call getarg(1,mod_initial_file)
  endif
  
  inquire(FILE= mod_initial_file,exist=alive)
  if(.not. alive) then 
  write(*,*) ' >>> ERROR OPENING INPUT PARAMETER FILE.'
  stop  
  end if
  
  Write (*, *) 'The name of the control file: ',mod_initial_file
  vdamp=1.00
  Open (10, File=mod_initial_file, Status='old')
  l = 1
  Write (*, *) 'Reading inputfile start...'
  1001 Read (10, '(a)', End=111) line
  If (line(1:1)=='*' .Or. line(2:2)=='*') Goto 1001
  If (l==1) headline=line
  If (l==2) Read (line, *, Err=1010) nz
  If (l==3) Read (line, *, Err=1010)(zn(i), i=1,nz) !z direction node
  If (l==4) Read (line, *, Err=1010)(vpn(i), i=1,nz) !z direction node
  If (l==5) Read (line, *, Err=1010) mod_finall_file  
  l = l + 1
  Goto 1001
  111 Close (10)

  fm='(f5.2,5x,f7.2,2x,f7.3)'
  Open (4, File=mod_finall_file, Status='unknown')
  Write (4, '(A)') headline
  Write (4, '(I2,5X,A25,5X,A30)') nz,'vel,depth,vdamp,phase',fm
  Write (4, fm)(vpn(i),zn(i),vdamp, i=1,nz)
  Close (4)

  Write (*, *) 'Creat mod file successful'
  stop
  1010 Write (*, *) 'Error reading'
  Write (*, *) line
  stop  
End Program creatmod

