using DataFrames

# when dataframes get written, by default they output
# comma delimited with a header, and strings are quoted.
# these things need to be rectified.
"""
    write_bedfile

    Writes a dataframe into a format that is acceptable as a bed file, or can at least be used by bedtools
      i)   Sorts the dataframe - needed for things like tabix indexing
      ii)  Writes the dataframe to disk - bedfiles don't have headers, and are tab delimited
      iii) removes the quotes around strings.
"""
function write_bedfile(output_path,df::DataFrame;sort=true,seq_id_colname=:seq_id,start_pos_colname=:start_pos)
    if sort
        sort!(df,cols=[seq_id_colname,start_pos_colname])
    end
    writetable( output_path, df, separator='\t', header=false)
    cmd = `sed -i -s 's/\"//g' $output_path` #"
    readall(cmd)
end

# cross over two dataframes using basic bedtools intersect
function bedtools_intersect(A::DataFrame, B::DataFrame; negate=false,sort=false)

    tmpdir = tempdir()
    tmpa=joinpath( tmpdir, "A")
    tmpb=joinpath( tmpdir, "B")
    tmpc=joinpath( tmpdir, "C")
    write_bedfile(tmpa,A,sort=sort)
    write_bedfile(tmpb,B,sort=sort)
    bedtools_cmd="bedtools"
    bedtools_args = ["intersect","-wo","-a",tmpa, "-b",tmpb]
    if negate
     # splices in between 2nd and 1st element with out removing any elements
     splice!(bedtools_args,2:1,["-v"])
    end
    run_cmd(bedtools_cmd, bedtools_args, tmpc)
    df=readtable(tmpc,separator='\t',header=false)
end

function bedtools_intersect(pathA::AbstractString, B::DataFrame;negate=false,sort=false)

    tmpdir = tempdir()
    tmpb=joinpath( tmpdir, "B")
    tmpc=joinpath( tmpdir, "C")
    write_bedfile(tmpb,B,sort=sort)

    bedtools_cmd="bedtools"
    bedtools_args = ["intersect","-wo","-a",pathA, "-b",tmpb]
    if negate
       # splices in between 2nd and 1st element with out removing any elements
       splice!(bedtools_args,2:1,["-v"])
    end
    run_cmd( bedtools_cmd, bedtools_args,tmpc)
    #cmd=`bedtools intersect $minusv -wo -a $pathA -b $tmpb` |> tmpc
    #cmd=`$bedtools_cmd $bedtools_args` |> tmpc
    #readall(cmd)
    df=readtable(tmpc,separator='\t',header=false)
end

function bedtools_intersect(pathA::AbstractString, pathB::AbstractString;negate=false)
    tmpdir = tempdir()
    tmpc=joinpath( tmpdir, "C")
    bedtools_cmd="bedtools"
    bedtools_args = ["intersect","-wo","-a",pathA, "-b",pathB]
    if negate
       # splices in between 2nd and 1st element with out removing any elements
       splice!(bedtools_args,2:1,["-v"])
    end
    #cmd=`bedtools intersect $minusv -wo -a $pathA -b $tmpb` |> tmpc
    #cmd=`$bedtools_cmd $bedtools_args` |> tmpc
    #readall(cmd)
    run_cmd( bedtools_cmd, bedtools_args,tmpc)
    df=readtable(tmpc,separator='\t',header=false)
end


# converts files which have
# chr1 start strand ... to
# chr1 start start strand
function convert_methpipebed_to_bedfile(pathA)
     tmppath = tempname()
     cmd = `zcat $pathA` |> `perl -F"\t" -lane 'print join("\t",$F[0],$F[1],$F[1],$F[2],$F[3],$F[4],$F[5])'` |> tmppath
     readall(cmd)
     return tmppath
end


# -- NOT TESTED --
# -- functions that avoid creating temporary tables
function query_features_to_query_str(df::DataFrame)
   n,r = size(df)
   rows = ASCIIString[]
   for i in 1:n
        row=Any[]
        println("row $i")
        for j in 1:r
            push!(row,  df[i,j] )
        end
        push!(rows, join(row,"\t")  )
    end
   return join(rows,"\n")
end

function query_features_from_bed_file(bedfile::ASCIIString, query_feature_df::DataFrame)
    df = DataFrame()
    sort!(query_feature_df)
    query_str = query_features_to_query_str( query_feature_df)
    println("Query String: $query_str :")
    bedtools_args = ["-sorted", "-wo","-a", "-", "-b", bedfile]
    bedtools_cmd = `echo -e $query_str` |> `bedtools intersect $bedtools_args`
    println(bedtools_cmd)
    # open iterator
    lines = eachline( bedtools_cmd  )
    firstline = readdlm( IOBuffer( first(lines) ) )

    # get the first line - this will define how many fields are in the dataframe
    println("first line: $firstline")
    for (num,field) in enumerate(firstline)
       fieldname=symbol("x$num") #note just using df[1],df[2]..and so on would make the header x1,x2..automatically poss customise this in future
       df[fieldname]=field
    end

    for line in lines
       fields = readdlm( IOBuffer(line))
       println("FIELDS: $fields")
       push!(df,fields)
    end
    return df
end
