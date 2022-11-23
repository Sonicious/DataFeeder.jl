

# get the training data and create a matrix of binary vectors
println("get CIFAR10 data and manage data into batches")

directory = raw"D:\CIFAR10\cifar-10-batches-bin"
const NROW = 32
const NCOL = 32
const NCHAN = 3
const NBYTE = NROW * NCOL * NCHAN + 1 # "+ 1" for label
const CHUNK_SIZE = 10_000
const NCHUNKS = 5

struct cifar10_type
    label::UInt8
    data::Array{UInt8}
end

files = []
for i in 1:NCHUNKS
    push!(files, joinpath(directory, string("data_batch_", i, ".bin")))
end

buffer = Array{UInt8}(undef, NBYTE, CHUNK_SIZE)

open(files[1], "r") do io
    read!(io, buffer)
end