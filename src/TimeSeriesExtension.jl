module TimeSeriesExtension

include("utils.jl")
include("equalds.jl")
include("timevector.jl")
include("ma.jl")

export EqualPeriodDS, meta, TimeVector, freq, timestamp, colnames, moving_average

end # module
