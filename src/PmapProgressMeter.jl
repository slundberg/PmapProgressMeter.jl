module PmapProgressMeter

using ProgressMeter

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
    globalProgressValues[id] = 0
    globalPrintLock[id] = ReentrantLock()

    passid = false
    kwa = Dict(kwargs)
    if haskey(kwa,:passcallback)
      passcallback = true
      delete!(kwa,:passcallback)
    end

    out = pmap(values...; kwa...) do x...
        if passcallback
          v = f(n -> updateProgressMeter(id,n), x...)
        else
          v = f(x...)
          wait(remotecall(1, updateProgressMeter, id, 1))
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
    globalProgressValues[id] += 1
    update!(globalProgressMeters[id] , globalProgressValues[id])
    unlock(globalPrintLock[id])
end

end # module
