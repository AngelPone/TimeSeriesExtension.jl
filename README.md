# TimeSeriesExtension.jl

`TimeSeriesExtension.jl` provides a few extensions to [`TimeSeries.jl`](https://github.com/JuliaStats/TimeSeries.jl)


## Quick Start



- `TimeSeriesExtension.jl` exports a `EqualPeriodDS<:AbstractVector{<:TimeType}` which allows for equal interval between two consecutive timestamps. 

    ```julia
    julia> using TimeSeriesExtension, Dates
    julia> ds = EqualPeriodDS(Week(1), Date(2020), 100)
    EqualPeriodDS(period=1 week, start=2020-01-01, length=100) end at 2021-11-24
    julia> ds[20]
    2020-05-13
    ```

- There are other constructors which can infer Period from given `Vector{<:TimeType}`.


- `TimeSeriesExtension.jl` also exports a `TimeVector{T,D,A}` which is alias of `TimeSeries.TimeArray{T,1,D,A}` with additional features.


For more details, please refer to Documentation.

