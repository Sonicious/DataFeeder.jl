function simplefeeder(output)
    for _ in 1:10
        sleep(rand())
        put!(output, rand())
    end
end