# this is now an interactive job/shell on some execution node

profile=job_${SLURM_JOB_ID}_$(hostname)

echo "Creating profile ${profile}"
ipython profile create ${profile}

echo "Launching controller"
ipcontroller --ip="*" --profile=${profile} --log-to-file &
sleep 10

echo "Launching engines"
srun ipengine --profile=${profile} --location=$(hostname) --log-to-file &
sleep 45

python3 /home/mpib/kloosterman/MATLAB/COBRA/123back_bias_novelvsfam/code/COBRA_HDDM_123back_bias.py --profile ${profile}
