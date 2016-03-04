module PmapProgressMeter

using ProgressMeter

# a global to hold progress meter references
globalProgressMeters = Dict()
globalProgressValues = Dict()

"Wraps pmap with a progress meter."
function Base.pmap(f::Function, p::Progress, values...; kwargs...)
    global globalProgressMeters
    global globalProgressValues

    id = randstring(50)
    globalProgressMeters[id] = p
    globalProgressValues[id] = 0

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

    globalProgressValues[id] += 1
    update!(globalProgressMeters[id] , globalProgressValues[id])
end

end # module
