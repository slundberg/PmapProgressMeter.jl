module PmapProgressMeter

using ProgressMeter

export updateProgressMeter

# a global to hold progress meter references
globalProgressMeters = Dict()
globalProgressValues = Dict()
globalPrintLock = Dict()

"Wraps pmap with a progress meter."
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
    if haskey(kwa,:passid)
      passid = true
      delete!(kwa,:passid)
    end

    out = pmap(values...; kwa...) do x...
        if passid
          v = f(id, x...)
        else
          v = f(x...)
        end
        wait(remotecall(1, updateProgressMeter, id))
        v
    end

    delete!(globalProgressMeters, id)
    out
end

"This is remote-called by all the workers to update the progress."
function updateProgressMeter(id)
    global globalProgressMeters
    global globalProgressValues
    global globalPrintLock

    lock(globalPrintLock[id])
    globalProgressValues[id] += 1
    update!(globalProgressMeters[id] , globalProgressValues[id])
    unlock(globalPrintLock[id])
end

end # module
