#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/SCRipt_NAME.log" 

mkdir -p $LOGS_FOLDER
echo "Script started executed at $(date)" | tee -a &>>$LOG_FILE

if [ $USERID -ne 0 ]; then
   echo "ERROR:: Please run this scripts with root privilege"
   exit 1 # failure is other than 0

fi

VALIDATE(){ # functions receive inputs through args just like shell scripts args
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N" | tee -a &>>$LOG_FILE
        exit 1
    else
        echo -e "$2...$G SUCCESS $N" | tee -a &>>$LOG_FILE
    fi
}        

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "ADDING mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing mongodb repo"

systemctl enable mongod 
VALIDATE $? "Enable mongodb"

systemctl start mongod 
VALIDATE $? "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restart mongodb"