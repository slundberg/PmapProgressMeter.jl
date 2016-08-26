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

# try with multiple lists
vals2 = 10:-1:1
p = Progress(length(vals))
@test pmap(+, p, vals, vals2) == 11*ones(Int,length(vals))

# make sure callback passing works
vals = 1:10
@test pmap((cb, x) -> begin sleep(.1); cb(1); x*2 end, Progress(length(vals)),vals,passcallback=true)[1] == vals[1]*2
