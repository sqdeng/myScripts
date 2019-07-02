!-----Creat the MOD file
  Program creatmod
  implicit none
  integer i,j,k,l,m,n
  Real bld
  Integer nx
  Integer ny
  Integer nz
  Real xn(50)
  Real yn(50)
  Real zn(50)
  Real vel(50, 50, 50)
  Real vpvs(50, 50, 50)
  Real vpn(50)
  Real vsn(50)
  Real synvellp(50, 50, 50)
  Real synvells(50, 50, 50)
  Real synvellps(50, 50, 50)
  Character synmodp*500
  Character synmodps*500
  Character line*500
  Character mod_initial_file*30
  Character modp*30
  Character modps*30
  real :: quantity
  logical :: alive
  integer :: narguments
  
  narguments = iargc()
  if(narguments.lt.1) then
     write(*,'(/,a)') 'PARAMETER INPUT FILE [node.inp <ret>]:'
     read(5,'(a)') mod_initial_file
     if(LEN_TRIM(mod_initial_file).le.1) then
        mod_initial_file= 'node.inp' !default input file name
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

  Open (10, File=mod_initial_file, Status='old')
  l = 1
  Write (*, *) 'Reading inputfile start...'
  1001 Read (10, '(a)', End=111) line
  If (line(1:1)=='*' .Or. line(2:2)=='*') Goto 1001
  If (l==1) Read (line, *, Err=1010) modp !output  mod file about vp
  If (l==2) Read (line, *, Err=1010) modps !output  mod file about vp
  If (l==3) Read (line, *, Err=1010) synmodp !p wave outputfile used
  If (l==4) Read (line, *, Err=1010) synmodps !s wave outputfile used
  If (l==5) Read (line, *, Err=1010) bld, nx, ny, nz
  If (l==6) Read (line, *, Err=1010)(xn(i), i=1, nx) !x direction node
  If (l==7) Read (line, *, Err=1010)(yn(i), i=1, ny) !y direction node
  If (l==8) Read (line, *, Err=1010)(zn(i), i=1, nz) !z direction node
  If (l==9) Read (line, *, Err=1010)(vpn(i), i=1, nz) !z direction node
  If (l==10) Read (line, *, Err=1010)(vsn(i), i=1, nz) !z direction node
  If (l==11) Read (line, *, Err=1010) quantity
  l = l + 1
  Goto 1001
  111 Close (10)

!check whether the 3-D grids are true   
  do n=1,nx-1
    if(xn(n+1) <= xn(n)) then
	write(*,*) 'Error in x-direction grid...'
	stop
	end if
  end do
  
  do n=1,ny-1
    if(yn(n+1) <= yn(n)) then
	write(*,*) 'Error in y-direction grid...'
	stop
	end if
  end do
  
  do n=1,nz-1
    if(zn(n+1) <= zn(n)) then
	write(*,*) 'Error in z-direction grid...'
	stop
	end if
  end do
  
  quantity = quantity/100.0  
  Write (*, *) 'Reading normaly...'
  Write (*, *) 'Output mod file about only vp is ', modp
  Write (*, *) 'Output mod file about vp/vs is ', modps
  Continue
  do m=1,nz
      if(vsn(m)==0) vsn(m)=vpn(m)/(sqrt(3.0))
  end do

  Open (1, File=modp, Status='unknown')
  Open (2, File=modps, Status='unknown')
  Open (3, File=synmodp, Status='unknown')
  Open (4, File=synmodps, Status='unknown')
  open (20, File='grid_gmt.dat', Status='unknown')

  Write (1, 2000) bld, nx, ny, nz
  Write (1, '(50f8.2)')(xn(i), i=1, nx)
  Write (1, '(50f8.2)')(yn(i), i=1, ny)
  Write (1, '(50f8.2)')(zn(i), i=1, nz)

  Write (2, 2000) bld, nx, ny, nz
  Write (2, '(50f8.2)')(xn(i), i=1, nx)
  Write (2, '(50f8.2)')(yn(i), i=1, ny)
  Write (2, '(50f8.2)')(zn(i), i=1, nz)

  Write (3, 2000) bld, nx, ny, nz
  Write (3, '(50f8.2)')(xn(i), i=1, nx)
  Write (3, '(50f8.2)')(yn(i), i=1, ny)
  Write (3, '(50f8.2)')(zn(i), i=1, nz)

  Write (4, 2000) bld, nx, ny, nz
  Write (4, '(50f8.2)')(xn(i), i=1, nx)
  Write (4, '(50f8.2)')(yn(i), i=1, ny)
  Write (4, '(50f8.2)')(zn(i), i=1, nz)


  Do k = 1, nz
    Do j = 1, ny
      Do i = 1, nx
		if(k == 1) write(20,"(F7.1,2X,F6.1,2X,F7.1)") xn(i),yn(j),zn(k)
        If (mod(i+j+k,2)==0) Then
          synvellp(i, j, k) = vpn(k)*(1-quantity)
          synvells(i, j, k) = vsn(k)*(1-quantity)
        Else                                
          synvellp(i, j, k) = vpn(k)*(1+quantity)
          synvells(i, j, k) = vsn(k)*(1+quantity)
          synvellps(i, j, k) = synvellp(i, j, k)/synvells(i, j, k)
        End If
        vel(i, j, k) = vpn(k)
        vpvs(i, j, k) = vpn(k)/vsn(k)
      End Do
    End Do
  End Do

  Do k = 1, nz
    Do j = 1, ny
      Write (1, '(50f6.2)')(vel(i,j,k), i=1, nx)
      Write (2, '(50f6.2)')(vel(i,j,k), i=1, nx)
      Write (3, '(50f6.2)')(synvellp(i,j,k), i=1, nx)
      Write (4, '(50f6.2)')(synvellp(i,j,k), i=1, nx)
    End Do
  End Do

  Do k = 1, nz
    Do j = 1, ny
      Write (2, '(50f6.2)')(vpvs(i,j,k), i=1, nx)
      Write (4, '(50f6.2)')(synvellps(i,j,k), i=1, nx)
    End Do
  End Do

  Close (1)
  Close (2)
  Close (3)
  Close (4)
  close (20)
  Goto 1111
  1010 Write (*, *) 'Error reading'
  Write (*, *) line
  stop
  1111 Write (*, *) 'Creat mod file successful'
  stop
  2000 FORMAT(f4.1,3i3)
End Program creatmod

