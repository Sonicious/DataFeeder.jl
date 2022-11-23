# AbstractChannel interface functions:
import Base: put!, wait, isready, take!, fetch
using DataStructures
using Distributed

mutable struct Pipeline <: AbstractChannel{T}
    buffer::CircularDeque # This is actually not really a circular buffer in the classic sense
    capacity::Int64 # capacity of the Pipeline
    cond_take::Condition  # waiting for data to become available
    cond_push::Condition  # waiting for capacity to push data
    Pipeline() = new(CircularDeque{Int},5, Condition(), Condition())
end

function put!(P::Pipeline, value)
    while isfull(P.buffer)
        wait(cond_push)
    end
    push!(P.buffer, value)
    notify(P.cond_put)
end

function take!(P::Pipeline)
    while isempty(P.buffer)
        wait(cond_take)
    end
    value = popfirst!(P.buffer)
    notify(P.cond_push)
    return value
end

isready(P::Pipeline) = !isempty(P.buffer)
isfull(P::Pipeline) = length(P.buffer) == P.capacity
wait(P::Pipeline) = wait(P.cond_take)

function fetch(P::Pipeline)
    while isempty(P.buffer)
        wait(cond_take)
    end
    value = first(P.buffer)
    return value
end

