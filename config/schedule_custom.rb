every 12.minute do
 command "python /home/deploy/consul/current/public/machine_learning/scripts/moderate.py >> /home/deploy/consul/current/public/machine_learning/data/moderate.log"
end
every :day, at: ["6 AM", "11 AM","9 PM"] do
 command "python /home/deploy/consul/current/public/machine_learning/scripts/budgets_summary_comments.textrank.py >> /home/deploy/consul/current/public/machine_learning/data/machine_learning.log"
end
every :day, at: ["7 AM", "12 AM","10 PM"] do
 command "python /home/deploy/consul/current/public/machine_learning/scripts/legislation_summary_comments.textrank.py >> /home/deploy/consul/current/public/machine_learning/data/machine_learning.log"
end
every :day, at: ["8 AM", "1 PM","11 PM"] do
 command "python /home/deploy/consul/current/public/machine_learning/scripts/proposals_summary_comments.textrank.py >> /home/deploy/consul/current/public/machine_learning/data/machine_learning.log"
end
every :day, at: ["5:30 AM", "3 PM"] do
 command "python /home/deploy/consul/current/public/machine_learning/scripts/proposals_related_content_and_tags_nmf.py >> /home/deploy/consul/current/public/machine_learning/data/machine_learning.log"
end
