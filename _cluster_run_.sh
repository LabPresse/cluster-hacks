#!/bin/bash

# set default values
program=$0
project="UNSPECIFIED"
username="jsbryan4"
password=$(head -n 1 _password_.txt)
dirname=""
num_cores=1
num_jobs=0
nodes=""
time="7-00:00"
language="python"

# get command line arguments
while [[ "$#" -ge 1 ]]; do
    case "$1" in
        -t|--time)
            shift;
            time=$1
            ;;
        -c|--num_cores)
            shift;
            num_cores=$1
            ;;
        -j|--num_jobs)
            shift;
            num_jobs=$1
            ;;
        -D|--dirname)
            shift;
            dirname=$1
            ;;
        --username)
            shift;
            username=$1
            ;;
        --password)
            shift;
            password=$1
            ;;
        --nodes)
            shift;
            nodes=$1
            [[ ! $nodes =~ steve|htc ]] && {
                echo "Incorrect option provided for nodes"
                exit 1
            }
            ;;
        --language)
            shift;
            language=$1
            [[ ! $language =~ python|julia ]] && {
                echo "Incorrect option provided for language"
                exit 1
            }
            ;;
        *)
            project=$1
            ;;
    esac
    shift
done

# Check for project
if [[ $project == "UNSPECIFIED" ]]; then
    echo "No project specified"
    exit 1
fi

# Specify nodes
if [[ "$nodes" == "steve" ]]; then
loadnodes="#SBATCH -q spresse\n#SBATCH -p spressecpu1"
elif [[ "$nodes" == "htc" ]]; then
loadnodes="#SBATCH -q normal\n#SBATCH -p htc"
fi

# Specify language
if [[ "$language" == "python" ]]; then
loadmodule="
set -x
module load anaconda/py3
source activate myscipy
"
extension="py"
elif [[ "$language" == "julia" ]]; then
loadmodule="
module load julia/1.7.2
"
extension="jl"
fi

# specify save name
if [[ "$dirname" == "" ]]; then
dirname=$project'_'$(date +%Y_%m_%d_%H_%M)
fi

# Print progess
echo "Starting cluster for $project ..."

# Create directories on cluster
echo '(1/3) ... creating directories ...'
sshpass -p "$password" ssh -T $username@agave.asu.edu<< !
mkdir $dirname
!

# Copy project onto cluster
echo '(2/3) ... copying project ...'
sshpass -p "$password" rsync -av --exclude=.* --exclude=_* --exclude=outfiles/ --exclude=pics/ --exclude=old/ --exclude=*.log "$project/" "$username@agave.asu.edu:/home/$username/$dirname/"

# Create job file and submit jobs
echo '(3/3) ... running jobs ...'
sshpass -p "$password" ssh -T "$username@agave.asu.edu"<< !

cd $dirname
mkdir outfiles

for (( i=0; i<$num_jobs; i++ ))
do

echo "   -\$((\$i+1))/$num_jobs"

printf "#!/bin/bash

$loadnodes
#SBATCH -t $time
#SBATCH -o _job"\$i"_.out
#SBATCH -e _job"\$i"_.err
#SBATCH -N 1
#SBATCH -c $num_cores
#SBATCH -D /home/jsbryan4/$dirname

$loadmodule

$language main.$extension \$i

" > "_job"\$i"_.sh"

sbatch "_job"\$i"_.sh"

done

!

# Print progress
echo "... $project is running on the cluster."

