for i in {1..17}; do for j in test ref; do hexdump -c $j.flv | head -$i | tail -1; done; echo; done
