using Dates

# Timestamps vector with equal period
"""
    EqualPeriodDS(period::Period, start::TimeType, length::Int)

Timestamps with equal period.

"""
struct EqualPeriodDS{U <: TimeType, T <: Period} <: AbstractArray{U, 1}
    period:: T
    start:: U
    length:: Int
end

Base.size(x::EqualPeriodDS) = (x.length,)
Base.getindex(x::EqualPeriodDS, i::Int) = x.start + x.period * (i - 1)
Base.getindex(x::EqualPeriodDS, r::UnitRange{<:Integer}) = EqualPeriodDS(x.period, x.start + x.period * (r.start - 1), length(r))
Base.IndexStyle(::Type{<:EqualPeriodDS}) = IndexLinear()
Base.show(io::IO, x::EqualPeriodDS) = println(io, "EqualPeriodDS(period=", x.period, ", start=", x.start, ", length=", x.length, ")", " end at ", x[end])
Base.show(io::IO, ::MIME"text/plain", x::EqualPeriodDS) = println(io, "EqualPeriodDS(period=", x.period, ", start=", x.start, ", length=", x.length, ")", " end at ", x[end])

"""
    EqualPeriodDS(::AbstractVector{<:TimeType}; period::Dates.Period)

Construct a EqualPeriodDS object from a vector of timestamps given a Period object. 
The time difference between two consecutive timestamps must be equal to the period.
"""
function EqualPeriodDS(x::AbstractVector{T}; period::Period) where {T <: TimeType}
    if length(x) == 0
        error("EqualPeriodDS: empty vector")
    elseif length(x) > 1
        map(enumerate(x[2:end])) do (i, dt)
            @assert dt - period * i == x[1] "EqualPeriodDS: Interval between index $(i+1) and $(i) is not equal to period!"
        end
    end
    return EqualPeriodDS(period, x[1], length(x))
end


"""
    EqualPeriodDS(::AbstractVector{Date})

Construct a EqualPeriodDS object from a vector of `Date` object.
Period is inferred from the time difference between two consecutive timestamps.
Note that if all dates are at the same day or end day in the month, the period is inferred as `Month`.

```julia-repl
julia> ds = [Date(2020, 1, 31) + Month(1)*i for i ∈ 1:100];
julia> EqualPeriodDS(ds)
EqualPeriodDS(period=1 month, start=2020-02-29, length=100) end at 2028-05-29
```
"""
function EqualPeriodDS(x::AbstractVector{Date})
    _check_input(x)
    diff_days = diff(x)
    if allequal(diff_days)
        # week
        if mod(diff_days[1].value, 7) == 0
            return EqualPeriodDS(x; period = Week(diff_days[1].value ÷ 7))
        end 
        return EqualPeriodDS(x; period = diff_days[1])
    elseif allequal(map(y -> Dates.day(y), x)) || all(y -> y == Dates.lastdayofmonth(y), x)
        diff_months = monthdiff(x)
        if allequal(diff_months)
            if mod(diff_months[1].value, 12) == 0
                return EqualPeriodDS(Year(diff_months[1].value / 12), x[1],length(x))
            elseif mod(diff_months[1].value, 3) == 0
                return EqualPeriodDS(Quarter(diff_months[1].value / 3), x[1],length(x))
            else
                return EqualPeriodDS(diff_months[1], x[1], length(x))
            end
        else
            return error("EqualPeriodDS: The series does not have same period!")
        end
    else
        return error("EqualPeriodDS: The series does not have same period!")
    end
end

"""
    EqualPeriodDS(::AbstractVector{DateTime})

Construct a EqualPeriodDS object from a vector of `DateTime` object.
Period is inferred from the time difference between two consecutive timestamps.

```julia-repl
julia> ds = [DateTime(2020, 1, 31) + Month(1)*i for i ∈ 1:100];
julia> EqualPeriodDS(ds)
EqualPeriodDS(period=1 month, start=2020-02-29T00:00:00, length=100) end at 2028-05-29T00:00:00

julia> ds = [DateTime(2020, 1, 31) + Minute(15)*i for i ∈ 1:100];
julia> EqualPeriodDS(ds)
EqualPeriodDS(period=15 minutes, start=2020-01-31T00:15:00, length=100) end at 2020-02-01T01:00:00
```
"""
function EqualPeriodDS(x::AbstractVector{DateTime})
    _check_input(x)
    diff1 = x[2] - x[1]
    diff2 = x[3] - x[2]
    period_seconds = Millisecond(Day(1))
    if mod(diff1, period_seconds).value == 0 && mod(diff2, period_seconds).value == 0
        ed = EqualPeriodDS(Date.(x))
        return EqualPeriodDS(ed.period, x[1], length(x))
    end
    for period in [Hour, Minute, Second]
        period_seconds = Millisecond(period(1))
        if diff1 == diff2
            if mod(diff1, period_seconds).value == 0
                return EqualPeriodDS(x; period = period(diff1 ÷ period_seconds))
            end
        else
            error("EqualPeriodDS: The series does not have same period!")
        end
    end
end

function _check_input(x::AbstractVector{<:TimeType})
    if length(x) == 0
        error("EqualPeriodDS: empty vector")
    elseif length(x) == 1
        error("EqualPeriodDS: can not infer period from a single $(typeof(x[1])).")
    end
end

monthdiff(x::Date, y::Date) = Month(12(Dates.year(y) - Dates.year(x)) + Dates.month(y) - Dates.month(x))

@inline function monthdiff(x::AbstractVector{Date})
    diffs = fill(Month(1), length(x) - 1)
    @inbounds for i ∈ 1:length(x)-1
        diffs[i] = monthdiff(x[i], x[i+1])
    end
    diffs
end