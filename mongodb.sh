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
        echo -e "${2} ${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2} ${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "installing mongodb"

systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "enablle and starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "updating remote connections to mongodb"
systemctl restart mongod
validate $? "restarting mongodb"



