function test_execution_case_run_string()
    ec = AVLExecution.ExecutionCase(2.0u"°", Dict(2 => Pitch), "a", true, 1, "./")
    AVLExecution.run_string(ec) ==
"a
a 2.0
d2
pm 0
x
fs
./a1.fs
st
./a1.st
"
end

function test_execution_series_run_string()
    ec1 = AVLExecution.ExecutionCase(2.0u"°", Dict(2 => Pitch), "a", true, 1, "./")
    ec2 = AVLExecution.ExecutionCase(4.0u"°", Dict(2 => Pitch), "a", true, 1, "./")
    
    ecs = AVLExecution.ExecutionCaseSeries("armagedon", [ec1, ec2])

    AVLExecution.run_string(ecs) ==
"load
armagedon
oper
" * AVLExecution.run_string(ec1) * AVLExecution.run_string(ec2) * "\nquit\n"
end

#todo
#no screen output?
#redirect output to avoid fs and st files?
function test_call_avl()
    if !isdir(joinpath(@__DIR__, "tmp"))
        mkdir("tmp")
    end
    call_avl("test_plane.run", dirname(@__DIR__))
    if isfile("tmp/test_plane1.fs") && isfile("tmp/test_plane1.st")
        rm("tmp/test_plane1.fs"); rm("tmp/test_plane1.st")
        true
    else
        @warn "something wrong, please clean up test directory"
        false
    end
end

@testset "AVLExecution tests" begin
    @test test_execution_case_run_string()
    @test test_execution_series_run_string()
    @test test_call_avl()
end