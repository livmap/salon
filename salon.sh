#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples -c"

SERVICES=$($PSQL "SELECT service_id,name FROM services;")

SERVE_MENU(){
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
if [[ "$SERVICE_ID" =~ ^-?[0-9]+$ ]]
then
echo "$SERVICE_ID) $NAME"
fi
done
}

START_MENU(){
  echo -e "\n$1\n"
  SERVE_MENU

  read SERVICE_ID_SELECTED
  if [[ "$SERVICE_ID_SELECTED" =~ ^-?[0-9]+$ ]]
  then
  SERVICE_CHECK=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  if [[ -z $SERVICE_CHECK ]]
  then 
  START_MENU "I could not find that service. What would you like today?"
  else
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  NUMBER_CHECK=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $NUMBER_CHECK ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  fi
  else
  START_MENU "Please enter an appropriate number"
  fi

}

START_MENU "Welcome to My Salon, how can I help you?"