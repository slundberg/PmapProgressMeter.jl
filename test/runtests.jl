using Base.Test


addprocs(2)
using PmapProgressMeter
using ProgressMeter

# just make sure it runs
p = Progress(10)
@test pmap(p, x->begin sleep(1); x end, 1:10)[1] == 1
