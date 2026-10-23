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


dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Installing nodejs 24"

id roboshop &>> $logs_file
if [ $? -ne 0 ] ; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "creating application/System user"
else 
    echo -e "$(timestamp) [INFO] System User Already Exists.. ${Y}SKIPPING${N}"
fi
rm -rf /app
validate $? "removing old directory"
mkdir -p /app
validate $? "creating app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "downloading Catalouge"

cd /app
unzip /tmp/catalogue.zip &>> $logs_file

validate $? "Unzipping Catalogue"

npm install &>> $logs_file
validate $? "Installing dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/catalogue.service"

cp "$script_dir/catalogue.service" /etc/systemd/system/catalogue.service



systemctl daemon-reload &>> $logs_file
systemctl enable catalogue &>> $logs_file
systemctl start catalogue &>> $logs_file
validate $? "Starting and enabling Catalogue"

cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
validate $? "Adding mongodb repo"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "installing mongodb client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()') 2>> $logs_file
validate $? "connecting to mongodb" 



if [ "$product_count" -eq 0 ]; then
   mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $logs_file
     validate $? "Loading products"
else 
    echo "products are already loaded..${Y}SKIPPING${N}"
fi
systemctl restart catalogue &>> $logs_file
validate $? "restarting catalogue"

echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
