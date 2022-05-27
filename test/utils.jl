module TestUtilities

using Test
using Dates
using TimeSeriesExtension: monthdiff

@testset "utils function" begin
    @test monthdiff(Date(2020), Date(2021)) == Month(12)
    @test monthdiff(Date(2020), Date(2020, 2)) == Month(1) 
end

end