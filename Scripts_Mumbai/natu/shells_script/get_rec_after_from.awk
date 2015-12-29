awk ' BEGIN{
             SUBSEP=" ";
           }
           {
                 if (match($0,"SELECT")> 0 || match($0,"select")> 0 || match($0,"insert")>0 || match($0,"INSERT")>0 )
                 {
                     if ( match($0," from ")>0 || match($0," FROM ")>0 || match($0," into ")>0 || match($0," INTO ")>0 )   
                     {
                         #found_rec=substr($0,RSTART+1,RLENGTH)
                         found_rec=substr($0,RSTART,length($0))
			 #print $1;
                         $0=found_rec
                         #print found_rec;
                         print $2;
                     }
                 }
           }' /db/Z06-X079-DBSB.log | sort | uniq -c | sort -g

