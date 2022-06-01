
"""
Moving Average (MA) Smoothing for time series.

    moving_average(x::TimeVector; m::Int = freq(x))

`m` is the frequency of time series by default.

# References
[Moving averages - fpp3](https://otexts.com/fpp3/moving-averages.html)
"""
function moving_average(x::TimeVector; m::Int = freq(x))
    if iseven(m)
        filters = [1, fill(2, m-1, 1)..., 1] / 2m
    else
        filters = fill(1, m, 1) / m
    end
    l = length(x)
    k = m ÷ 2
    output = [fill(missing, k)..., fill(0., l-2k)..., fill(missing, k)...]
    vx = values(x)

    for i ∈ k + 1 : length(x) - k
        output[i] = sum(filters .* vx[i - k : i + k])
    end

    TimeVector(x; values = output)
end