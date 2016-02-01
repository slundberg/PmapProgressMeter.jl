using Base.Test


addprocs(2)
using PmapProgressMeter
using ProgressMeter

# just make sure it runs
vals = 1:10
p = Progress(length(vals))
@test pmap(x->begin sleep(1); x*2 end, p, vals)[1] == vals[1]*2

# test the do-block syntax
pmap(p, vals) do x
    sleep(1)
    x*2
end

# make sure it runs it kwargs
vals = 1:10
p = Progress(length(vals))
@test pmap(x->begin sleep(.1); x*2 end, p, vals, err_stop=true)[1] == vals[1]*2
