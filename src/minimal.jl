using Distributed

# Distribution on processes
const num_of_pipelines = 15
const size_of_pipelines = 1000
const num_of_producers = 30
const num_of_consumers = 5
const num_of_schedulers = 1
const consumer_cache = 4000

# manage the workers into pools
const manager_pid = 1
const pids = addprocs(num_of_producers + num_of_schedulers + num_of_consumers)
const scheduler_pool = [popfirst!(pids) for _ = 1:num_of_schedulers]
const consumer_pool = [popfirst!(pids) for _ = 1:num_of_consumers]
const producer_pool = pids

# Pipeline initialization
const producer_pipelines = Array{RemoteChannel}(undef, num_of_pipelines)
for pipeline_idx = axes(producer_pipelines, 1)
    producer_pipelines[pipeline_idx] = RemoteChannel(() -> Channel{Float64}(size_of_pipelines))
end
const consumer_pipelines = Array{RemoteChannel}(undef, num_of_consumers)
for pipeline_idx = axes(consumer_pipelines, 1)
    consumer_pipelines[pipeline_idx] = RemoteChannel(() -> Channel{Float64}(consumer_cache))
end

# distribute the code
@everywhere [producer_pool..., manager_pid] include("minimal_producer.jl")
@everywhere [scheduler_pool..., manager_pid] include("minimal_scheduler.jl")
@everywhere [consumer_pool..., manager_pid] include("minimal_consumer.jl")

# start scheduler
schedulerfcn = roundrobin_balancer
for scheduler_pid in scheduler_pool
    remote_do(schedulerfcn, scheduler_pid, producer_pipelines, consumer_pipelines)
end

# start consumer (Always amount pipes == amount consumers)
consumerfcn = simpleprinter
for (pipe_idx, consumer_pid) in enumerate(consumer_pool)
    remote_do(consumerfcn, consumer_pid, consumer_pipelines[pipe_idx])
end

#TODO: use clear working stuff and pmap
# start the feeders
producerfcn = simplefeeder
for (pipe_idx, producer_pid) in enumerate(producer_pool)
    pipe_idx = (pipe_idx % num_of_pipelines) + 1
    remote_do(producerfcn, producer_pid, producer_pipelines[pipe_idx])
end

sleep(10)
rmprocs(workers())