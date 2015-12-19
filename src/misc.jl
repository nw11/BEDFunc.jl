#=
 Misc routines that are associated with BED like files
=#

using DataFrames

"""
   load_dataframe_from_url

   Until I can figure out how to use Requests to download dropbox links
"""
function load_dataframe_from_url(url,readtable_options={:separator=>'\t'})
    tmpfile = tempname()
    curl_cmd=`curl -L $url` |> tmpfile
    readall(curl_cmd)
    df= readtable(tmpfile;readtable_options...)
    return (df,tmpfile)
end

"""
  run_cmd

  To handle compatibility between 0.3 and 0.4

"""
function run_cmd(bedtools_cmd,bedtools_args,outfile)
  if Base.VERSION < v"0.4.0"
        cmd=`$bedtools_cmd $bedtools_args` |> outfile
        readall(cmd)
    else
       cmd=pipeline(`$bedtools_cmd $bedtools_args`,stdout=outfile)
       run(cmd)
    end
end
