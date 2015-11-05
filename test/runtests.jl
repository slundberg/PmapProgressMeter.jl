using Base.Test


# write your own tests here
addprocs(2)
using PmapProgressMeter
using ProgressMeter

p = Progress(10)
@test pmap(p, x->begin sleep(1); x end, 1:10)[1] == 1
