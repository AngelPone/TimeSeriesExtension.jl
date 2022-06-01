using Documenter, TimeSeriesExtension

makedocs(sitename="TimeSeriesExtension.jl",
         pages = [
             "TimeSeriesExtension OverView" => "index.md"
             "EqualPeriodDS" => "equalperiodds.md"
             "TimeVector" => "timevector.md"
             "Utilities" => "utils.md"
         ])