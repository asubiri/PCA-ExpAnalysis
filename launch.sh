#! /usr/bin/env bash

#SBATCH --mem='60gb'
#SBATCH --constraint=cal
#SBATCH --time='10:00:00'
hostname

source ~soft_bio_267/initializes/init_degenes_hunter

curdir=`pwd`
project_dir="/mnt/home/users/bio_267_uma/elenarojano/projects/tfms/albaSubiri"
pseudocounts_table=$project_dir"/data/pseudocounts_table.txt"

# Prepare variables:

qualitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaLitative.lst | sed 's/,$//'`
quantitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaNTitative.lst | sed 's/,$//'`
genesList=`tr "\n" "," < $project_dir/data/parse_outbrat/genes.lst | sed 's/,$//'`
blacklist=$curdir"/blaklist_FurtherInvestigation.txt"


# Execute HUNTER:

results_folder=$curdir"/results"
targets_folder=$curdir"/TARGETS"
#rm -rf $curdir"/TARGETS"
mkdir $targets_folder

# REPARE TARGETS

if [ "$1" == "A" ] ; then
	mkdir -p $results_folder"/FIB4.stage"
	mkdir -p $results_folder"/allPatients"
	quantitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaNTitative.lst | sed 's/,$//' | sed 's/FIB4.stage,//g'`
	quantitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaNTitative.lst | sed 's/,$//'`
	qualitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaLitative.lst | sed 's/,$//' | sed 's/FIB4.stage,//g'` #descomentar para FIB4.stage
	qualitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaLitative.lst | sed 's/,$//'`
	sed 's/FIB4\.stage/treat/; s/0-1/Ctrl/; s/2-3/Treat/' $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" > $targets_folder"/FIB4.stage_target.txt" #uncomment to generate FIB4.stage Target!
	less -S $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt"
	grep -Fwv -f FIB4.class_bl $targets_folder"/FIB4.stage_target.txt" > $targets_folder"/FIB4.stage_target_bl.txt"
	grep -Fwv -f cluster3_samples_remove.txt $targets_folder"/FIB4.stage_target_bl.txt" > $targets_folder"/FIB4.stage_target.txt"
	degenes_Hunter.R -i $pseudocounts_table -o $results_folder"/allPatients" -t $targets_folder"/allPatients.txt" --pseudocounts -m 'DELN' -S $qualitativeVars -N $quantitativeVars -f 1 -p 0.05
	#functional_Hunter.R -i $results_folder"/FIB4.stage" -t E -c 6 -o $results_folder/functional_enrichment -m Human
fi

## FIB4.class 0 (control) vs FIB4.class 1 (treat)
if [ "$1" == "B" ] ; then
	mkdir -p $results_folder"/FIB4.class"
	qualitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaLitative.lst | sed 's/,$//' | sed 's/FIB4.class,//g'`
	sed 's/FIB4\.class/treat/; s/Fib0/Ctrl/; s/Fib1/Treat/' $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" > $targets_folder"/FIB4.class_target.txt"
	grep -Fwv -f FIB4.class_bl $targets_folder"/FIB4.class_target.txt" > $targets_folder"/FIB4.class_target_bl.txt"
        mv $targets_folder"/FIB4.class_target_bl.txt" $targets_folder"/FIB4.class_target.txt"
	degenes_Hunter.R -i $pseudocounts_table -o $results_folder"/FIB4.class" -t $targets_folder"/FIB4.class_target.txt" --pseudocounts -m 'D' -S $qualitativeVars -b FIB4.class_bl
	functional_Hunter.R -i $results_folder -t E -c 6 -o $results_folder/functional_enrichment --MODEL_ORGANISM Human
fi

## FIB4.Adv.Fib assessment (control) vs FIB4.Adv.Fib excluded (treat)
if [ "$1" == "C" ] ; then
	mkdir $curdir"/tmp"
	mkdir -p $results_folder"/FIB4.Adv.Fib"
	head -n +1 $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" > $curdir"/tmp/FIB4.Adv.Fib_samples.txt"
	grep -wvE 'Excluded|Assessment' $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" | cut -f 1 | tail -n +2 > $curdir"/tmp/FIB4.Adv.Fib_blacklist.txt"
	grep -w 'Excluded' $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" >> $curdir"/tmp/FIB4.Adv.Fib_samples.txt"
	grep -w 'Assessment' $project_dir"/data/parse_outbrat/parsed_files/sample_data.txt" >> $curdir"/tmp/FIB4.Adv.Fib_samples.txt"
	
	qualitativeVars=`tr "\n" "," < $project_dir/data/parse_outbrat/quaLitative.lst | sed 's/,$//' | sed 's/FIB4.Adv.Fib,//g'`
	sed 's/FIB4\.Adv\.Fib/treat/; s/Assessment/Ctrl/; s/Excluded/Treat/' $curdir"/tmp/FIB4.Adv.Fib_samples.txt" > $targets_folder"/FIB4.Adv.Fib_target.txt"
	less -S $targets_folder"/FIB4.Adv.Fib_target.txt"
	degenes_Hunter.R -i $pseudocounts_table -o $results_folder"/FIB4.Adv.Fib" -t $targets_folder"/FIB4.Adv.Fib_target.txt" --pseudocounts -m 'DE' -S "Etnia,Sex,AgeHigher50,Smoker,Hypertension,Dyslipidemia,Diabetes,Obesity,Antihypertensives_HPM,DM2,AntiDM,Quartils.Temp,Quartils.MinTemp,Quartil.MaxTemp,Healthy" -f 0.6 -p 0.05
	functional_Hunter.R -i $results_folder"/FIB4.Adv.Fib" -t E -c 6 -o $results_folder/FIB4.Adv.Fib/functional_enrichment -m Human	
fi

exit
