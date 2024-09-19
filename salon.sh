#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n" 

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, we are not offering any services right now."
  else
    # display available servies
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID NAME
    do
      NAME=${NAME#|}
      echo "$SERVICE_ID)$NAME"
    done
  fi
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) GATHER_INFORMATION $SERVICE_ID_SELECTED ;;
    2) GATHER_INFORMATION $SERVICE_ID_SELECTED ;;
    3) GATHER_INFORMATION $SERVICE_ID_SELECTED ;;
    *) MAIN_MENU ;;
  esac
}

GATHER_INFORMATION() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$1'")

  # get service time
  echo -e "\nWhat time would you like?"
  read SERVICE_TIME

  # insert into appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')") 

  # print appointment in terminal
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU
