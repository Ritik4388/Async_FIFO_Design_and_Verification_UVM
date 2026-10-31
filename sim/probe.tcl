# probe.tcl -- record every signal in tb_top into a SimVision database (waves.shm)
database -open waves -shm -default
probe -create tb_top -depth all -all -database waves
run
exit
