include std/filesys.e
include std/cmdline.e
include std/io.e
include std/sequence.e as seq
include std/search.e as srch
include std/regex.e as re
include std/text.e
include std/convert.e

include json.e 

without trace

integer false = 0
integer true = not false
re:regex err_id = re:new("<([0-9]+)>::(.*)")

function first_failure(sequence lines, sequence fallback)
    for i = 1 to length(lines) do
        sequence line = lines[i]
        if match("failed:", line) then
            return trim(line)
        end if
    end for
    return fallback
end function

function failures(sequence txt)
    sequence parts = seq:split(txt,", ")    
    for i = 1 to length(parts) do
        if match("failed",parts[i]) then
            return parts[i]
        end if
    end for
    return ""
end function

function check_for_error(sequence lines, atom current) 
    sequence message = ""
    object res = re:matches(err_id, lines[current]) 
    if not atom(res) then
        message = res[1]
        atom err_number = to_integer(res[2])
        if err_number = 74 then
            -- need to extract the next line of the data[i]
            message &= (" " & trim(lines[current+1]))
        end if 
        return {true, message}
    else
        return {false, message}
    end if
end function 

function check_for_failure(sequence lines, atom current) 
    sequence message = ""
    integer result = match("100% success", lines[current])
    if result then
        return {false, message}
    end if

    result = match("% success", lines[current])
    if result then
        return {true, first_failure(lines, lines[current])}
    else 
        return {false, message}
    end if
end function 

procedure process(sequence slug, sequence soln_folder, sequence outp_folder)
    sequence solution_dir = canonical_path(soln_folder)
    sequence output_dir = canonical_path(outp_folder)
    sequence results_file = join_path({output_dir, "/results.json"})

    create_directory(output_dir)
    printf(1, "%s: testing...", {slug})
    sequence cmd = build_commandline({"cp", join_path({solution_dir, ".meta", "example.ex"}),join_path({"/tmp", slug & ".ex"})})
    system(cmd,2)
    cmd = build_commandline({"cp", join_path({solution_dir, "t_" & slug & ".e"}), "/tmp"})
    system(cmd, 2)
    sequence outfile = join_path({"/tmp", "t_" & slug & ".out"})
    cmd = build_commandline({"eutest", join_path({"/tmp", "t_" & slug & ".e"}), ">", outfile})
    system(cmd,2)

    atom fh = open(outfile, "r")
    sequence data = read_lines(fh)
    close(fh)

    sequence status = "pass"
    sequence message = ""

    --trace(1)
    
    for i = 1 to length(data) do
        sequence response = check_for_error(data, i)
        if response[1] then
            status = "error"
            message = response[2]
            exit
        end if 

        response = check_for_failure(data, i)
        if response[1] then
            status = "fail"
            message = response[2]
            exit
        end if
    end for
    
    sequence JSON = {JSON_OBJECT, 
        {
            {"version", {JSON_NUMBER, 1}}, 
            {"status", {JSON_STRING, status}}, 
            {"message", {JSON_STRING, message}}
        }
    }

    fh = open(results_file,"w")
    json_print(fh, JSON, false)
    close(fh)
end procedure

sequence cmdline = command_line()
if (length(cmdline) < 5) then
    puts(1, "usage: eui ./bin/run.ex exercise-slug path/to/solution/folder/ path/to/output/directory/\n")
else
    process(cmdline[3], cmdline[4], cmdline[5])
end if
