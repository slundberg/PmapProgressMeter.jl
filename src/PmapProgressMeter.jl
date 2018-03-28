module PmapProgressMeter

using ProgressMeter
using Compat

# a global to hold progress meter references
globalProgressMeters = Dict()
globalProgressValues = Dict()
globalPrintLock = Dict()

"Wraps pmap with a progress meter. If the keyword argument passcallback is true, then passes an additional first argument to the function which is a callback taking one argument, n, to add n to the progress meter. If it is false, then updates the progress meter by 1 every time a parallel call
finishes."
function Base.pmap(f::Function, p::Progress, values...; kwargs...)
    global globalProgressMeters
    global globalProgressValues
    global globalPrintLock

    id = randstring(50)
    globalProgressMeters[id] = p
    globalProgressValues[id] = p.counter
    globalPrintLock[id] = ReentrantLock()

    passcallback = false
    kwa = Dict(kwargs)
    if haskey(kwa,:passcallback)
      passcallback = true
      delete!(kwa,:passcallback)
    end

    out = pmap(values...; kwa...) do x...
        if passcallback
          v = f(n -> remotecall(updateProgressMeter, 1, id, n), x...)
        else
          v = f(x...)
          wait(remotecall(updateProgressMeter, 1, id, 1))
        end
        v
    end

    delete!(globalProgressMeters, id)
    out
end

"This is remote-called by all the workers to update the progress."
function updateProgressMeter(id,n)
    global globalProgressMeters
    global globalProgressValues
    global globalPrintLock

    lock(globalPrintLock[id])
    globalProgressValues[id] += n
    update!(globalProgressMeters[id] , globalProgressValues[id])
    unlock(globalPrintLock[id])
end

end # module
