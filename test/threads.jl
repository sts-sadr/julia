# This file is a part of Julia. License is MIT: https://julialang.org/license

let cmd = `$(Base.julia_cmd()) --depwarn=error --startup-file=no threads_exec.jl`
    for test_nthreads in (1, 2, 4, 4) # run once to try single-threaded mode, then try a couple times to trigger bad races
        run(pipeline(setenv(cmd, "JULIA_NUM_THREADS" => test_nthreads), stdout = stdout, stderr = stderr))
    end
end

# issue #34415 - make sure external affinity settings work
if Sys.islinux() && Sys.CPU_THREADS > 1 && Sys.which("taskset") !== nothing
    run_with_affinity(spec) = readchomp(`taskset -c $spec $(Base.julia_cmd()) -e "run(\`taskset -p \$(getpid())\`)"`)
    @test endswith(run_with_affinity("1"), "2")
    @test endswith(run_with_affinity("0,1"), "3")
end
