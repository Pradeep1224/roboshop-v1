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

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "Setting up java 25v"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? "setting JAVA_HOME for maven"
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
curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip  &>> $logs_file
validate $? "Downloadig shipping"

cd /app
unzip /tmp/shipping.zip  &>> $logs_file
validate $? "Unzipping shipping"


mvn clean package  &>> $logs_file
validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar 
validate $? "moving jar file"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"

cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service
 dnf install mysql -y  &>> $logs_file
 validate $? "installing mysql client"

 
mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "Loading Shipping Data"


 systemctl daemon-reload  &>> $logs_file
systemctl enable shipping  &>> $logs_file
systemctl start shipping &>> $logs_file
validate $? "starting and enabling shipping"








echo "$(timestamp) [INFO] time taken $SECONDS"
echo "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file
