using Base.Test


addprocs(2)
using PmapProgressMeter
using ProgressMeter

# just make sure it runs
vals = 1:10
p = Progress(length(vals))
@test pmap(p, x->begin sleep(1); x*2 end, vals)[1] == vals[1]*2
