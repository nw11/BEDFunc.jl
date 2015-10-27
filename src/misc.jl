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
