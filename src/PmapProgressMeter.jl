module PmapProgressMeter

using ProgressMeter

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

    out = pmap(values...; kwargs...) do x...
        v = f(x...)
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
    global globalIsPrinting

    lock(globalPrintLock[id])
    globalProgressValues[id] += 1
    update!(globalProgressMeters[id] , globalProgressValues[id])
    unlock(globalPrintLock[id])
end

end # module
