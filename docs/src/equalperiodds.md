# EqualPeriodDS




## Constructors

```@autodocs
Modules = [TimeSeriesExtension]
Order   = [:type, :function]
Filter = t -> t == EqualPeriodDS
```


## Index

```@setup abc
using Dates, TimeSeriesExtension
ds = EqualPeriodDS(Day(1), Date(2020), 10)
size(ds)
ds[2]
ds[1:7]
```

```@repl
using Dates, TimeSeriesExtension
ds = EqualPeriodDS(Day(1), Date(2020), 10)
size(ds)
ds[2]
ds[1:7]
```

You can also access elements out of the index range.

```@repl abc
ds[11]
ds[11:20]
ds[0]
```