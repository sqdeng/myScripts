	program  ph2velest
	implicit none
	integer :: m,i,t,tt1,error
	character(len=100) line,fm
	integer,parameter :: preiev=25000
	integer :: yr(preiev),mo(preiev),dy(preiev),hr(preiev),minute(preiev)
	real :: sec(preiev),lat(preiev),lon(preiev),depth(preiev),mag(preiev)
	character(len=20) :: phasefile,stafile,cnvfile,listfile
	integer,parameter :: preiobs=180
	character(len=7) :: sta(preiobs)
	real :: tt(preiobs),wt(preiobs)
	character(len=1) :: phase(preiobs),cns,cew
	integer,parameter :: preista=250
	integer	mode,icc,kk,kwt(preiobs)
	character(len=7) :: stana(preista)
	real :: stalat(50000),stalon(50000),stadepth(50000),pdelay,sdelay
	
	cns='N'
	cew='E'
	
	m=0
	open(1,file='ph2velest.inp',status='old')
	do while(.true.)
	read(1,'(A)',iostat=error) line
	if(line(1:1).NE. '*') then
	m=m+1
	If (m==1) phasefile=trim(line)
	If (m==2) stafile=trim(line)
	If (m==3) cnvfile=trim(line)
	If (m==4) listfile=trim(line)
	end if
	if(error/=0) exit	
	end do
	close(1)
	
	open(11,file=phasefile,status='old')
	open(12,file=cnvfile)
	
	i=1
	write(*,*)'Getting phase data from inputfile: ',phasefile
11	read(11,'(a)',end=1113)line
	if(line(1:1).eq.'#') then
		if (i.gt.1)then
		  write(12,3002)(sta(tt1),phase(tt1),kwt(tt1),tt(tt1),tt1=1,t-1)
	      write(12,*)
        endif
	    read(line,2001,err=1114)yr(i),mo(i),dy(i),hr(i),minute(i),sec(i),lat(i),lon(i),depth(i),mag(i)
	    write(12,3001)yr(i),mo(i),dy(i),hr(i),minute(i),sec(i),lat(i),cns,lon(i),cew,depth(i),mag(i)	 
	    i=i+1
	    t=1
	else	 
	    read(line,2002,err=1114)sta(t),tt(t),wt(t),phase(t)
	    if(wt(t).eq.1.0) kwt(t)=0
	    if(wt(t).eq.0.75) kwt(t)=1
	    if(wt(t).eq.0.5) kwt(t)=2	
	    if(wt(t).eq.0.25) kwt(t)=3
	    t=t+1
	endif
	goto 11
	
1113 continue
	if (i.gt.1)then
	write(12,'(6(a7,a1,i1,2x,f6.2))')(sta(tt1),phase(tt1),kwt(tt1),tt(tt1),tt1=1,t-1)
	write(12,*)
	write(12,'(a)')'9999'
	endif
	write(*,*)'# event = ',i-1

	close(11)
	close(12)
	
	open(13,file=stafile,status='old')
	open(14,file=listfile)
	
	write(*,*)'Getting station data from inputfile: ',stafile
	mode=1
	pdelay=0.0
	sdelay=0.0
	
	i=1
	fm='(a7,f8.4,a1,1x,f8.4,a1,1x,i4,1x,i1,1x,i4,1x,f5.2,2x,f5.2)'
	write(14,'(a)') trim(fm)
12	read(13,'(a)',end=1115)line
	read(line,4000,err=1114)stana(i),stalat(i),stalon(i),stadepth(i)
	icc=i
	write(14,fm) stana(i),stalat(i),cns,stalon(i),cew,int(stadepth(i)),mode,icc,pdelay,sdelay
	i=i+1
	goto 12	
		
1115 continue
	write(*,*)'#station = ',i-1
	close(13)
	close(14)
	stop
	
1114 write(*,*)'reading error line------',line
	stop	
2001 Format(2X,I4,1X,I2,1X,I2,1X,I2,1X,I2,1X,F5.2,1X,F8.4,1X,F9.4,1X,F7.2,2X,F5.2)
2002 Format(A7,2X,F8.2,2X,F3.1,2X,A1)
3001 Format(i4,1x,2i2,1x,2i2,1x,f5.2,1x,f7.4,a1,1x,f8.4,a1,1x,f7.2,2x,f5.2)
3002 Format(6(a7,a1,i1,2x,f6.2))
4000 format(A7,1X,F7.4,1X,F8.4,1X,F7.2)
	end