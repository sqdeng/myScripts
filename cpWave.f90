	program cpWave
	implicit none
	integer :: i,j,day
	character(len=80) dir
	character(len=2) month(12)
	integer dayMonth(12)
	character(len=2) prov(4)
	character(len=1) dayStr1
	character(len=2) dayStr
	character(len=100) line

	dir='cp /run/media/dengshanquan/Seagate_Backup_Plus_Drive3/waveform20181106/2017'
	DATA month / '01','02','03','04','05','06','07','08','09','10','11','12' /
	DATA dayMonth / 31,28,31,30,31,30,31,31,30,31,30,31 /
	DATA prov / 'CQ','GZ','SC','YN' /

	open(11,file='cpWave.sh')
	write(11,'(A)') "#!/bin/bash"
	write(11,'(A)') "rm *.mseed"

	do i=8,11
		do day=1,dayMonth(i)
			
			if(day<10) then
				write(dayStr1,'(I1)') day
				dayStr='0'//dayStr1
			else
				write(dayStr,'(I2)') day
			end if

			do j=1,4
				line=trim(dir)//month(i)//dayStr//"/"//prov(j)//"*BHZ*mseed"//" ./"
				write(11,'(A)') trim(line)
			end do

		end do
	end do
	do j=1,4
		write(11,'(A)') trim(dir)//'1201/'//prov(j)//"*BHZ*mseed"//" ./"
	end do

	close(11) 

	call system("chmod +x cpWave.sh")

	stop
	end program
