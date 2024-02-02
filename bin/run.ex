include std/filesys.e
include std/cmdline.e
include std/io.e
include std/sequence.e
include std/search.e

procedure process(sequence slug, sequence soln_folder, sequence outp_folder)
    sequence solution_dir=canonical_path(soln_folder)
    sequence output_dir=canonical_path(outp_folder)
    sequence results_file=join_path({output_dir, "/results.json"})

    create_directory(output_dir)
    printf(1, "%s: testing...", {slug})
    sequence outfile = join_path({output_dir,"t_" & slug & ".out"})
    sequence cmd = build_commandline({"eutest",join_path({solution_dir,"t_" & slug & ".e"}),">", outfile})
    system(cmd,2)

    atom fh = open(outfile, "r")
    sequence data = read_lines(fh)
    close(fh)

    atom failure = 0
    sequence failmsg = ""

    for i = 1 to length(data) do
        integer result = match("  failed:", data[i])
        if result then
            failure = i 
            failmsg = slice(data[i],11)
            break
        end if
    end for
    
    fh = open(results_file,"w")
    if failure = 0 then
        write_file(fh, "{\"version\": 1, \"status\": \"pass\"}")
    else
        write_file(fh, sprintf("{\"version\": 1, \"status\": \"fail\", \"message\": \"%s\"}", {find_replace("\"",failmsg,"\\\"")}))
    end if
    close(fh)
    --puts(1,"done\n")
end procedure

sequence cmdline = command_line()
if (length(cmdline) < 5) then
    puts(1, "usage: eui ./bin/run.ex exercise-slug path/to/solution/folder/ path/to/output/directory/\n")
else
    process(cmdline[3], cmdline[4], cmdline[5])
end if
