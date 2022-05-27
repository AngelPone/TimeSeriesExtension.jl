module TestTimeVector

using Test
using TimeSeriesExtension
using TimeSeriesExtension: TSMeta
using Dates

ds = [Date(2020) + Day(1) * (i-1) for i ∈ 1:100]
val = 1:100
col = :y
@testset "TimeVector" begin
    @testset "TimeVector Constructor" begin
        tv = TimeVector(ds, val, col, 12)
        @test freq(tv) == 12 && colnames(tv) == [col] && timestamp(tv) == ds
        @test typeof(meta(tv)) == TSMeta && meta(tv).freq == [12]

        tv = TimeVector(NamedTuple((:timestamp => ds, col => val)); timestamp=:timestamp, ts=col, freq=12)
        @test freq(tv) == 12 && colnames(tv) == [col] && timestamp(tv) == ds
        @test typeof(meta(tv)) == TSMeta && meta(tv).freq == [12]

        tv = TimeVector(tv; freq=24, meta=nothing)
        @test freq(tv) == 24 && colnames(tv) == [col] && timestamp(tv) == ds
        @test typeof(meta(tv)) == TSMeta && meta(tv).freq == [24]
    end

    tv = TimeVector(ds, val, col, 12)
    @testset "TimeVector math operators" begin
        tv = tv + tv
        @test freq(tv) == 12 && colnames(tv) == [col] && timestamp(tv) == ds && all(values(tv) .== val .* 2)
        tv = tv - tv
        @test freq(tv) == 12 && colnames(tv) == [col] && timestamp(tv) == ds && all(values(tv) .== 0)
        @test_throws AssertionError("x and y should have the same timetamps") tv + tv[1:90]
        @test_throws AssertionError("x and y should have the same timetamps") tv - tv[1:90]
    end
end

end
