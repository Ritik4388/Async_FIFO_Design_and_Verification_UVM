merge cov_work/scope/fifo_* -out cov_work/scope/all_runs -overwrite
load -run cov_work/scope/all_runs
report -summary -inst -all
report -detail -metrics covergroup -all
exit
