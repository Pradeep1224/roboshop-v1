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


dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y &>> $logs_file
validate $? "Installing Nginx"

systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Enable and start Nginx"


# id roboshop &>> $logs_file
# if [ $? -ne 0 ] ; then

# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
# validate $? "creating application/System user"
# else 
#     echo -e "$(timestamp) [INFO] System User Already Exists.. ${Y}SKIPPING${N}"
# fi

rm -rf /usr/share/nginx/html/*
validate $? "removing Default page"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $logs_file
validate $? "Downloadig frontend"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $logs_file
 validate $? "Unzipping frontend"
# mkdir -p /app
# validate $? "creating app directroy"
# curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip  &>> $logs_file


# cd /app
# unzip /tmp/payment.zip  &>> $logs_file



# python3.14 -m venv /app/.venv &>> $logs_file
# validate $? "creating virtual environment"
# /app/.venv/bin/pip install -r requirements.txt &>> $logs_file
# validate $? "Installing dependencies"



sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/roboshop.conf"

cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf
 validate $? "copying roboshop config"

 nginx -t &>> $logs_file
 validate $? "checking conf file"

systemctl restart nginx &>> $logs_file
validate $? "restart nginx"




echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
