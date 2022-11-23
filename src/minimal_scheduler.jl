function roundrobin_single(pipeline::Array{RemoteChannel}, output::RemoteChannel)
    while (true)
        for chnl in pipeline
            if (isready(chnl))
                temp = take!(chnl)
                put!(output, temp)
            end
        end
    end
end

function roundrobin_balancer(inputpipeline::Array{RemoteChannel}, outputpipeline::Array{RemoteChannel})
    numouts = size(outputpipeline, 1)
    balancingterm = 0
    while (true)
        for inputchannel in inputpipeline
            if (isready(inputchannel))
                temp = take!(inputchannel)
                put!(outputpipeline[balancingterm+1], temp)
                balancingterm = (balancingterm+1)%numouts
            end
        end
    end
end

