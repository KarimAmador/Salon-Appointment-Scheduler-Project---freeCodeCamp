#!/bin/bash
PSQL="psql -X -U freecodecamp -d salon --no-align --tuples-only -c"

echo -e "\n~~~~ Baldn't Salon ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to Baldn't Salon, how can I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Invalid service number."
    return
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "Sorry, there's no such service."
    return
  fi

  # ask for the customer's phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # look for the customer's name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if the customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for the customer's name
    echo -e "\nIt seems this is your fist time here, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # ask the time for the appointment
  echo -e "\nPlease give me a time for your appointment (in 12 or 24 hour format):"

  # while [[ ! $SERVICE_TIME =~ ^(([0-9]|1[0-2])(:[0-5][0-9])?(([Aa]|[Pp])[Mm]))|(([0-1][0-9]|2[0-3]):([0-5][0-9]))$ ]]
  # do
    read SERVICE_TIME
  # done

  # make the new appointment
  INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a ${SERVICE_NAME,,} at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU