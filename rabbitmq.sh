user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

 if [ $user_id -ne 0 ]; then
    echo "please run with sudo access......."
    exit 1
fi

mkdir -p $logs_folder
echo "Script started at: $(date +"%F %T")"


validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2} ${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2} ${G}SUCCESS${N}" | tee -a $logs_file
    fi
}
timestamp(){
    date +"%F %T"
}


echo "$(timestamp) [INFO] ====script started execution===" | tee -a $logs_file

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding repo rabbitmq"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Starting and enabling rabbitmq-server"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then 

rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
validate $? "creating rabbitmq user for roboshop"
else 
    echo -e "$(timestamp) [INFO] Rabbitmq user already exists..${Y}SKIPPING${N}"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "setting permissions for rabbitmq user"

echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file