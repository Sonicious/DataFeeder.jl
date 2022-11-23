using Images
using Plots
using Distributed
using CUDA

# check cuda devices:
println("Cuda information:")
println([CUDA.capability(dev) for dev in CUDA.devices()])

# Target architecture
struct Sample
    label::UInt8
    data::Array{Float64,3}
end

# CIFAR 10 Parameters, Data Description
directory = raw"D:\CIFAR10\cifar-10-batches-bin"
const NROW = 32
const NCOL = 32
const NCHAN = 3
const NBYTE = NROW * NCOL * NCHAN + 1 # "+ 1" for label
const CHUNK_SIZE = 10_000
const NCHUNKS = 5

# find all data access points
files = []
for i in 1:NCHUNKS
    push!(files, joinpath(directory, string("data_batch_", i, ".bin")))
end

# function for producer task
##############################################
function producer(dataChannel::Channel, file)
    # Function for raw data conversion
    function readbuffer(bytes)
        return Sample(bytes[1], permutedims(reshape(bytes[2:end], 32, 32, 3) / 256, (3, 1, 2)))
    end
    # local data buffer
    buffer = Array{UInt8}(undef, NBYTE, CHUNK_SIZE)
    # read the actual data
    open(file, "r") do io
        read!(io, buffer)
    end
    # conversion to target architecture and send to channel when ready
    for chunkdata = 1:CHUNK_SIZE
        put!(dataChannel, readbuffer(buffer[:, chunkdata]))
    end
end
##############################################

# Scheduler function
##############################################
function schedule_Test(input::Channel[], output::Channel)
    
end
##############################################

# function for the consumer task
##############################################
function consumer()

end
##############################################