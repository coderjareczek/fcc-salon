#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT * FROM services")

SHOW_SERVICES()
{
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do 
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED

SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
if [[ -z $SERVICE_ID_RESULT ]]
then
  echo -e "\nI could not find that service. What would you like today?"
  SHOW_SERVICES
else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $PHONE_RESULT ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/ *$|^ *//g')
  SERVICE_NAME_FORMATTED=$(echo $SERVICE | sed -E 's/ *$|^ *//g')
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?" #format
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed -E 's/ *$|^ *//g')
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED." #format
fi
}
SHOW_SERVICES
