using DataFrames
using Libz
"""
  parse_gtf_gene_features_to_df

  Arguments:
    filename: path to gtf file
    gene_ids: An array of gene_ids - if an empty array, then everything is parsed.
    feature_types: Set of feature types - e.g.  Set({"gene"})

  Returns:

"""
function parse_gtf_gene_features_to_df(filename, gene_ids, feature_types)
    gene_id_pat   = r"gene_id\s+\"?([^\s]+)\";"
    header_pat    = r"^#" #<-bug2
    gene_name_pat = r"gene_name\s+\"?([^\s]+)\";"
    gene_type_pat = r"gene_type\s+\"?([^\s]+)\";"
    features_df =DataFrame(seq_id=String[], start_pos=Int[],stop_pos=Int[],
                           strand=String[], gene_id=String[],
                           feature_type=String[], gene_name=String[],gene_type=String[])
    line_count = 0
    io=open(filename)
    if ismatch(Regex(".gz\$"),filename)
        io=ZlibInflateInputStream(io,reset_on_end=true)
    end

    for line in eachline(io)
        if ismatch(header_pat,line)
          continue
        end
        row = split(line, '\t')
        feature_type = row[3]
        if !(feature_type in feature_types)
           continue
        end
        m = match(gene_id_pat, row[9])
        @assert m != nothing
        row_gene_id = m.captures[1]

        match_gene_name = match(gene_name_pat, row[9])
        row_gene_name = match_gene_name.captures[1]

        match_gene_type = match(gene_type_pat, row[9])
        row_gene_type = match_gene_type.captures[1]

        if length(gene_ids) > 0
           if !(row_gene_id in gene_ids)
               continue
           end
       end
       #println("Got $row_gene_id")
       push!(features_df, [row[1],parse(Int64,row[4]), parse(Int64,row[5]),row[7], row_gene_id,feature_type,row_gene_name,row_gene_type])
    end
    return features_df
end
