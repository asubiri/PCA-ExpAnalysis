#! /usr/bin/env bash
infile="../outbrat_db_mod_fib4.txt"
mkdir -p parsed_files
dos2unix $infile
header=`head -n 1 $infile`
echo -e $header > parsed_files/sample_data.txt

if [ "$1" == "A" ] ; then
	echo "Prepare sample_data with qualitative and quantitative data:"
	qual_cols=`echo $header | tr ' ' '\n' | awk '{print NR "\t" $0}' | grep -w -F -f quaLitative.lst | cut -f 1 | tr '\n' ',' | sed 's/,$//'`
	# Note: quant_cols won't be used in this study since they do not contribute to the system
	quant_cols=`echo $header | tr ' ' '\n' | awk '{print NR "\t" $0}' | grep -w -F -f quaNTitative.lst | cut -f 1 | tr '\n' ',' | sed 's/,$//'`
	echo $header | tr ' ' '\t' | cut -f 1,$quant_cols,$qual_cols > parsed_files/sample_data.txt
	echo $header | tr ' ' '\t' | cut -f 1,$qual_cols >> parsed_files/sample_data.txt
	grep '^M_' $infile | tr ',' '.' | cut -f 1,$quant_cols,$qual_cols >> parsed_files/sample_data.txt 
	grep '^M_' $infile | tr ',' '.' | cut -f 1,$qual_cols >> parsed_files/sample_data.txt 
	sed -i 's/Counts_code/sample/g' parsed_files/sample_data.txt
fi

if [ "$1" == "B" ] ; then
	echo "Prepare sample_data with aleatory samples as controls/treats:"
	samples_num=$(($(wc -l < parsed_files/sample_data.txt) -1 ))
	half_samples=$(($samples_num / 2))

	echo 'treat' > treat_column.txt

	for ((i=1; i<=$samples_num; i++)); do
		if [ "$i" -le "$half_samples" ]; then
	        	echo "Treat" >> treat_column.txt
		else
	        	echo "Ctrl" >> treat_column.txt
		fi
	done
	paste parsed_files/sample_data.txt treat_column.txt > parsed_files/sample_data.txt
	sed -i 's/Counts_code/sample/g' parsed_files/sample_data.txt
fi