function simpleprinter(scheduler::RemoteChannel)
    while (true)
        if (isready(scheduler))
            println(take!(scheduler))
        end
    end
end

function simpledeleter(scheduler::RemoteChannel)
    while (true)
        if (isready(scheduler))
            take!(scheduler)
        end
    end
end