  !Output absolute velocity and relative perturbation velocity per layer
  !3 Inputfiles : grid file: grid.dat; initial mod file: MOD; velocity file: Vp_model.dat 
  
  program createDepthGrid
  implicit none
  integer :: i,j,k
  real :: bld
  integer :: nx,ny,nz,nxyz2,cont
  real,allocatable :: xn(:),yn(:),zn(:)
  real,allocatable :: modvel(:,:,:)
  real,allocatable :: grid(:,:)
  real,allocatable :: absvel(:,:,:)		!absolute velocity
  real,allocatable :: relatvel(:,:,:)    !relative velocity perturbation
  real,allocatable :: dwsvalue(:,:,:)
  integer :: stat=0
  integer :: zdepth
  character(len=2) :: zdepthstr
  character(len=15) :: absfie
  character(len=15) :: perturfie
  character(len=15) :: dwsfile
  character(len=20) :: line
  
  open(1,file='MOD',status='old')
  read(1,*) bld,nx,ny,nz
  allocate(xn(nx))
  allocate(yn(ny))
  allocate(zn(nz))
  read(1,*) xn
  read(1,*) yn
  read(1,*) zn
  allocate(modvel(nx,ny,nz))
  Do k = 1, nz
    Do j = 1, ny
    read (1, '(22f6.2)',iostat=stat) (modvel(i,j,k), i=1,nx)
	if(stat /= 0) exit
    End Do
  End Do 
  close(1)
  
  nxyz2 = (nx-2)*(ny-2)*(nz-2)
  allocate(grid(nxyz2,2))
  open(2,file='grid.dat',status='old')
    do i=1,nxyz2
    read (2, *,iostat=stat) grid(i,1),grid(i,2)
	if(stat /= 0) exit
	end do
  close(2)
 
  allocate(absvel(nx,ny,nz))
  open(3,file='Vp_model.dat',status='old')
    Do k = 1, nz
    Do j = 1, ny
    read (3, '(22f7.3)',iostat=stat) (absvel(i,j,k), i=1,nx)
	if(stat /= 0) exit
    End Do
    End Do
  close(3)
  
  allocate(dwsvalue(nx,ny,nz))
  open(4,file='tomofdd.vel',status='old')
  do while(.true.)
10  read(4,'(a)',iostat=stat) line
  if(stat /= 0) exit
  if (trim(line) == ' DWS for P-wave.') then
    Do k = 1, nz
    Do j = 1, ny
    read (4, '(22f10.2)') (dwsvalue(i,j,k), i=1,nx)	
    End Do
    End Do
	else
	goto 10
  end if
  end do
  close(4)  
  
! Output absolute velocity file
  do k=2,nz-1
  zdepth=INT(zn(k))
  if (zdepth < 10) then
  write(zdepthstr,'(I1)') zdepth
  else
  write(zdepthstr,'(I2)') zdepth
  end if
  absfie='absfie'//trim(zdepthstr)//'.dat'
  open(10+k,file=absfie)
  do j=2,ny-1
  do i=2,nx-1
  cont = i+(j-2)*(nx-2)+(k-2)*(nx-2)*(ny-2)-1
  write(10+k,'(f7.3,2X,f7.3,2X,f7.3)') grid(cont,1),grid(cont,2),absvel(i,j,k)
  end do
  end do
  close(10+k)
  end do
  
! Output relative perturbation velocity file  
  do k=2,nz-1
  zdepth=INT(zn(k))
  if (zdepth < 10) then
  write(zdepthstr,'(I1)') zdepth
  else
  write(zdepthstr,'(I2)') zdepth
  end if
  perturfie='perturfie'//trim(zdepthstr)//'.dat'
  open(20+k,file=perturfie)
  do j=2,ny-1
  do i=2,nx-1
  cont = i+(j-2)*(nx-2)+(k-2)*(nx-2)*(ny-2)-1
  write(20+k,'(f7.3,2X,f7.3,2X,f6.2)') grid(cont,1),grid(cont,2),(absvel(i,j,k)-modvel(i,j,k))*100/modvel(i,j,k)
  end do
  end do
  close(20+k)
  end do
  
! output DWS for every node from tomoDD.vel  
  do k=2,nz-1
  zdepth=INT(zn(k))
  if (zdepth < 10) then
  write(zdepthstr,'(I1)') zdepth
  else
  write(zdepthstr,'(I2)') zdepth
  end if
  dwsfile='dwsfile'//trim(zdepthstr)//'.dat'
  open(30+k,file=dwsfile)
  do j=2,ny-1
  do i=2,nx-1
  cont = i+(j-2)*(nx-2)+(k-2)*(nx-2)*(ny-2)-1
  write(30+k,'(f7.3,2X,f7.3,2X,f10.2)') grid(cont,1),grid(cont,2),dwsvalue(i,j,k)
  end do
  end do
  close(30+k)
  end do
  
  stop
  end program