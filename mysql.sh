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
dnf module enable mysql:8.4 -y
dnf install mysql-server -y
validate $? "installing mysql"


systemctl enable mysqld
systemctl start mysqld
validate $? "start and enable mysql"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setting root password for mysql"




echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
