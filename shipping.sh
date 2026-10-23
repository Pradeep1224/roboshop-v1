user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="pradeepverse.online"
script_dir=$(dirname "$(realpath "$0")")
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

dnf module enable maven:3.9 -y &>> $logs_file
dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? "Installing java and maven"







echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
