using TimeSeries

struct TSMeta
    freq::Vector{Integer}
    meta::Any
end

"""
    TimeVector{T, D, A} where {T,D<:TimeType,A<:AbstractVector{T}}

`TimeVector{T,D,A}` is alias of `TimeArray{T, 1, D, a}` with specific Meta Type `TSMeta` 
which contains `frequency` of the time series and other meta data. 
"""
const TimeVector{T, D, A} = TimeArray{T,1,D,A} where {T,D<:TimeType,A<:AbstractVector{T}}


"""
# Constructors

    TimeVector(timestamp::T, ts::D, name::Symbol[], meta::TSMeta; unchecked=false)
    TimeVector(timestamp::T, ts::D, name::Symbol, freq::Int, meta::Any=nothing; unchecked=false)
    TimeVector(tv::TimeVector; timestamp::T=timestamp(tv), ts::D=values(tv), name::Symbol=names(tv)[1], freq=freq(tv), meta=meta(tv), unchecked=false)
    TimeVector(data::NamedTuple; timestamp::Symbol, ts::Symbol, freq::Int, meta::Any; unchecked=false)

- The first constructor is used to be compatible with `TimeSeries.TimeArray`. You may hardly use it.
- The third constructor will update `tv` according to new `timestamp`, `ts`, `name` and `freq`.

# Parameters

- `T<:AbstractVector{<:TimeType}` shoule be of vector of `TimeType`(i.e., `Date` and `DateTime`). If possible, the constructor 
will convert `T` to a `EqualPeriodDS{<:TimeType}`
- `D<:AbstractVector{A}` shoule be of vector of `A`.
- `name::Symbol` is name of the time series.
- `freq::Int` is frequency of the time series. 
- `meta::Any` can be any metadata.

# Examples

Construct TimeVector using the second constructor.

```julia-repl
julia> using Dates, TimeSeriesExtension
julia> ds = [Date(2020) + Day(1) * i for i in 1:100];
julia> tv = TimeVector(ds, ts, :y, 12)
100×1 TimeArray{Int64, 1, Date, UnitRange{Int64}} 2020-01-02 to 2020-04-10
│            │ y     │
├────────────┼───────┤
│ 2020-01-02 │ 1     │
│ 2020-01-03 │ 2     │
│ ⋮          │ ⋮     │
│ 2020-04-09 │ 99    │
│ 2020-04-10 │ 100   │
```
"""
function TimeVector(ds::AbstractVector{D}, ts::AbstractVector{T}, names::Vector{Symbol}, meta::TSMeta=nothing; unchecked=false) where {T, D<:TimeType}
    ds = try 
        EqualPeriodDS(ds)
    catch ErrorException
        ds
    end
    TimeArray{T, 1, D, typeof(ts)}(ds, ts, names, meta; unchecked=unchecked)
end

TimeVector(ds::AbstractVector{D}, ts::AbstractVector{T},
    name::Symbol, freq::Int=1, meta::Any=nothing; args...) where {T,D<:TimeType} = 
    TimeVector{T,D,typeof(ts)}(ds, ts, [name], TSMeta([freq], meta); args...)

TimeVector(tv::TimeVector{T, D, A};
          timestamp = timestamp(tv), values = values(tv),
          name::Symbol = colnames(tv)[1], freq::Int=freq(tv), meta = meta(tv), args...) where {T,D<:TimeType,A<:AbstractVector{T}}=
    TimeVector(timestamp, values, [name], TSMeta([freq], meta); args...)


function TimeVector(data::NamedTuple; timestamp::Symbol, ts::Symbol, freq::Int=1, meta = nothing, args...)
    TimeVector(data[timestamp], data[ts], [ts], TSMeta([freq], meta); args...)
end

function freq(ts::TimeArray)
    frequency = getfield(meta(ts), :freq)
    if length(frequency) == 1
        return frequency[1]
    else
        return frequency
    end
end

function Base.:+(x::TimeVector, y::TimeVector)
    if colnames(x)[1] == colnames(y)[1]
        colname = colnames(x)[1]
    else
        colname = Symbol(colnames(x)[1], colnames(y)[1])
    end
    @assert timestamp(x) == timestamp(y) "x and y should have the same timetamps"
    TimeVector(x; values=values(x)+values(y))
end

function Base.:-(x::TimeVector, y::TimeVector)
    if colnames(x)[1] == colnames(y)[1]
        colname = colnames(x)[1]
    else
        colname = Symbol(colnames(x)[1], colnames(y)[1])
    end
    @assert timestamp(x) == timestamp(y) "x and y should have the same timetamps"
    TimeVector(x; values=values(x)-values(y))
end


