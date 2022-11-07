every 12.minute do
    command "python /home/deploy/consul/current/public/machine_learning/scripts/moderate.py >> /home/deploy/consul/current/public/machine_learning/data/moderate.log"
end