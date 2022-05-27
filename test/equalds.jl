module Testequalds

using Test
using Dates

using TimeSeriesExtension: EqualPeriodDS, monthdiff

@testset "EqualPeriodDS" begin

    @test_throws ErrorException("EqualPeriodDS: empty vector") EqualPeriodDS(Vector{Date}(); period=Day(1))
    @test_throws ErrorException("EqualPeriodDS: empty vector") EqualPeriodDS(Vector{Date}())
    @test_throws ErrorException("EqualPeriodDS: can not infer period from a single Dates.Date.") EqualPeriodDS([Date(2020)])
    @test_throws ErrorException("EqualPeriodDS: The series does not have same period!") EqualPeriodDS([Date(2020), Date(2021, 1, 2), Date(2022, 1, 3)])
    @test_throws AssertionError("EqualPeriodDS: Interval between index 2 and 1 is not equal to period!") EqualPeriodDS([Date(2020), Date(2021, 1, 2), Date(2022, 1, 3)]; period=Day(1))
    @test_throws AssertionError("EqualPeriodDS: Interval between index 2 and 1 is not equal to period!") EqualPeriodDS([DateTime(2020), DateTime(2021, 1, 2), DateTime(2022, 1, 3)]; period=Day(1))
    @test_throws ErrorException("EqualPeriodDS: empty vector") EqualPeriodDS(Vector{DateTime}(); period=Second(1))
    @test_throws ErrorException("EqualPeriodDS: empty vector") EqualPeriodDS(Vector{DateTime}())

    @testset "EqualPeriodDS inference with Different Date type" begin
        @testset for period in [Day(1), Week(1), Month(2), Quarter(2), Year(2)]
            test_days = [Date(2020) + period * i for i ∈ 1:100]
            ds = EqualPeriodDS(test_days)
            @test ds.period == period && ds.start == test_days[1] && ds.length == 100
            @test ds[1] == test_days[1]
        end
        # initilize at the end of month
        test_days = [Date(2020, 1, 31) + Month(1) * i for i ∈ 1:100]
        ds = EqualPeriodDS(test_days)
        @test ds.period == Month(1) && ds.start == test_days[1] && ds.length == 100
    end   
    
    @testset "EqualPeriodDS inference with Different DateTime type" begin
        @testset for period in [Second(1), Minute(15), Hour(1), Day(1), Week(1), Month(2), Quarter(2), Year(2)]
            testsets = [DateTime(2020) + period * i for i ∈ 1:100]
            ds = EqualPeriodDS(testsets)
            @test ds.period == period && ds.start == testsets[1] && ds.length == 100
            @test ds[1] == testsets[1]
        end
    end

    @testset "EqualPeriodDS index" begin
        ds = EqualPeriodDS(Day(1), Date(2020), 10)
        @test ds[2] == Date(2020, 1, 2)
        @test ds[1:7] == EqualPeriodDS(Day(1), Date(2020, 1, 1), 7)
        @test ds[2:7] == EqualPeriodDS(Day(1), Date(2020, 1, 2), 6)
    end
end
end

