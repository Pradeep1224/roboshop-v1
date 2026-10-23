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
dnf install python3.14 python3.14-pip -y &>> $logs_file
validate $? "Installing Python3.14"



id roboshop &>> $logs_file
if [ $? -ne 0 ] ; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "creating application/System user"
else 
    echo -e "$(timestamp) [INFO] System User Already Exists.. ${Y}SKIPPING${N}"
fi

rm -rf /app
validate $? "removing old code"

mkdir -p /app
validate $? "creating app directroy"
curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip  &>> $logs_file
validate $? "Downloadig payment"

cd /app
unzip /tmp/payment.zip  &>> $logs_file
validate $? "Unzipping payment"


python3.14 -m venv /app/.venv &>> $logs_file
validate $? "creating virtual environment"
/app/.venv/bin/pip install -r requirements.txt
validate $? "Installing dependencies"



sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/payment.service"

cp "$script_dir/payment.service" /etc/systemd/system/payment.service


systemctl daemon-reload &>> $logs_file
systemctl enable payment &>> $logs_file
systemctl restart payment &>> $logs_file
validate $? "starting/re and enabling payment"

echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
