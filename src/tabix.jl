"""
  BEDQuery
   A query object holds the coordinates
"""

type BEDQuery
  qid::UTF8String
  seq_id::UTF8String
  start_pos::Integer
  stop_pos::Integer
end


"""
   make_query_path
"""
function make_query_str(queries::Array{BEDQuery} )
    query_array = UTF8String[]
    for query in queries
        str="$(query.seq_id):$(query.start_pos)-$(query.stop_pos)"
        push!(query_array, str)
    end
    return query_array
end


"""
    bedquery2list
"""
function bedquery2list(Q::BEDQuery)
    return (Q.qid,Q.seq_id,Q.start_pos,Q.stop_pos)
end


"""
    initiate

    Get query seq_id,start_pos,stop_pos and new vector
"""

function initiate(query::BEDQuery)
    query_seq_id    = query.seq_id
    query_start_pos = query.start_pos
    query_stop_pos  = query.stop_pos
    query_length    = query_stop_pos - query_start_pos
    V=fill(float32(0.0),query_length)
    return (query_seq_id,query_start_pos,query_stop_pos,query_length,V)
end


"""
    Query
"""

function query(filepath::ASCIIString,query::Array{BEDQuery})
    query_idx=1
    query_str_array = make_query_str(query)
    cmd = `tabix -p bed $filepath $query_str_array`
    D = Dict{UTF8String,Array{Float32}}()
    (query_seq_id,query_start_pos,
     query_stop_pos,query_length,V) = initiate(query[query_idx])
    for line in eachline(cmd)
        (seq_id,start,stop,score)=split( chomp(line), '\t' )
        start_pos = int32(start)
        stop_pos  = int32(stop)

        idx_start_pos = ( start_pos - query_start_pos ) + 1
        idx_stop_pos  = ( stop_pos  - query_start_pos ) + 1

        try
           for i in (idx_start_pos:idx_stop_pos )
               if i < 1
                  continue
               end
               if i > query_length
                  continue
               end
               V[i]= float32(score)
               println("$i ($idx_start_pos) $seq_id, $start,$stop,$score")
           end
        catch e
           println("$seq_id, $start,$stop,$score")
           error(e)
        end

        # If current stop position is greater than the current query stop position
        # then the next interval must be from the next query
        if ( ( stop_pos >= query[query_idx].stop_pos) | (seq_id != query_seq_id) )
            D[ query_str_array[query_idx] ]=copy(V)
            if query_idx < length(query)
                query_idx += 1
                (query_seq_id,query_start_pos,
                 query_stop_pos,query_length,V) = initiate( query[query_idx] )
            end

        end
    end
    D[ query_str_array[query_idx] ]=copy(V)
    return D
end

"""
   bgzip_and_index

   bgzips - then uses tabix -p bed to create an index
"""
function bgzip_and_index(filepath; outputpath=filepath*".gz")
   cmd_bgzip = `bgzip -c $filepath` |> outputpath
   readall(cmd_bgzip)
   cmd_tabix = `tabix -f -p bed $outputpath`
   readall(cmd_tabix)
end

#println("CHANGE AT $seq_id, $start,$stop,$score")
# println("NEXT INTERVAL $seq_id, $query_start_pos,$query_stop_pos,$score")
#println("IS $start_pos GREATER THAN $(query[query_idx].stop_pos) ?")


