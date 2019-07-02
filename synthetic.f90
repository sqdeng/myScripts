	program synthetic
	implicit none 
	integer :: error,i
	character(len=20) :: filedt,fileab
	integer,external :: line_file
	
	integer :: ndt=0
	integer,allocatable:: dtidone(:), dtidtwo(:)
	character(len=7) :: dtsta
	real :: dtimeone, dtimetwo
	real :: dtweight
	character :: dtpha

	integer :: nabo=0
	integer,allocatable :: absoid(:)
	character(len=7) :: abosta
	real :: abotime
	real :: aboweight
	character :: abopha
	
	filedt='dt.syn'
	fileab='absolute.syn'
	ndt=line_file(filedt)+5
	nabo=line_file(fileab)+5
	write(*,*) ndt,nabo
	allocate(dtidone(ndt))
	allocate(dtidtwo(ndt))
	allocate(absoid(nabo))
	
	write(*,*) 'Transforming synthetic data starts... '
	open(1,file='dt.syn',status='old')
	open(2,file='syn.dt' )
	 i=1
     do while(.true.)
       read(1,*,iostat=error) dtidone(i), dtidtwo(i), dtsta, dtimeone, dtimetwo, dtweight, dtpha
       if(error/=0) exit
	   if(i>1) then
	     if(dtidone(i) == dtidone(i-1) .and. dtidtwo(i) == dtidtwo(i-1)) then
	     write(2,1002) dtsta, dtimeone, dtimetwo, dtweight, dtpha
	     else
	     write(2,1001) "#",dtidone(i), dtidtwo(i)
	     write(2,1002) dtsta, dtimeone, dtimetwo, dtweight, dtpha
	     end if
	   else 
	     write(2,1001) "#",dtidone(i), dtidtwo(i)
	     write(2,1002) dtsta, dtimeone, dtimetwo, dtweight, dtpha
	   end if
       i=i+1
	   if(i>=ndt) then
	     write(*,*) "Please increse ndt parameter..."
	   stop
	   end if
     end do
	
	close(1)
	close(2)
1001 format(a1,1x,i12,1x,i12)
1002 format(a7,1x,f10.4,1x,f10.4,1x,f6.3,1x,a1)
	
	open(3,file='absolute.syn',status='old')
	open(4,file='syn.absolute' )
	 i=1
     do while(.true.)
       read(3,*,iostat=error) absoid(i), abosta, abotime, aboweight, abopha
       if(error/=0) exit
	   if(i>1) then
	     if(absoid(i) == absoid(i-1)) then
	     write(4,2002) abosta, abotime, aboweight, abopha
	     else
	     write(4,2001) "#",absoid(i)
	     write(4,2002) abosta, abotime, aboweight, abopha
	     end if
	   else
	     write(4,2001) "#",absoid(i)
	     write(4,2002) abosta, abotime, aboweight, abopha
	   end if
       i=i+1
	   if(i>=nabo) then
	     write(*,*) "Please increse nabo parameter..."
	   stop
	   end if
     end do
	
	close(3)
	close(4)
	write(*,*) 'Transforming synthetic data succeeds... '
2001 format(a1,4x,i14)
2002 format(a7,3x,f8.2,3x,f8.2,3x,a1)	
	
	stop
	end program

	integer function line_file(filein)
	implicit none
	integer :: error
	character(len=20) filein,line
	line_file=0
	open(10,file=trim(filein),status='old')
	do while(.true.)
		read(10,*,iostat=error) line
		if(error/=0) exit
		line_file=line_file+1
	end do
	close(10)
	return
	end	