module TestUtilities

using Test
using Dates
using TimeSeriesExtension
using TimeSeriesExtension: monthdiff

@testset "utils function" begin
    @test monthdiff(Date(2020), Date(2021)) == Month(12)
    @test monthdiff(Date(2020), Date(2020, 2)) == Month(1) 
end

@testset "moving average" begin
    ts = TimeVector([Date(2020) + Day(i) for i in 1:100], randn(100), :y, 1)
    @test values(all(moving_average(ts) .== ts))[1]
    
    res = moving_average(ts; m=4)
    @test values(all(ismissing.(res[1:2])))[1]
    @test values(all(ismissing.(res[end-1:end])))[1]
    @test values(res)[3] ≈ 1/8 * (values(ts)[1] + 2values(ts)[2] + 2values(ts)[3] + 2values(ts)[4] + values(ts)[5])
    @test values(res)[90] ≈ 1/8 * (values(ts)[88] + 2values(ts)[89] + 2values(ts)[90] + 2values(ts)[91] + values(ts)[92])

    res = moving_average(ts; m=5)
    @test values(all(ismissing.(res[1:2])))[1]
    @test values(all(ismissing.(res[end-1:end])))[1]
    @test values(res)[3] ≈ 1/5 * (values(ts)[1] + values(ts)[2] + values(ts)[3] + values(ts)[4] + values(ts)[5])
    @test values(res)[90] ≈ 1/5 * (values(ts)[88] + values(ts)[89] + values(ts)[90] + values(ts)[91] + values(ts)[92])
end

end