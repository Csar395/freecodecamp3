#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~ Isaaks Salon ~~\n"
echo -e "Welcome to my Salon, how can I serve you today?\n"

SERVICE_LIST() {
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while IFS='|' read -r SERVICE NAME
  do
    echo $SERVICE')' $NAME
  done
}

MAIN_MENU() {
  # Zeige die verfügbaren Services als nummerierte Liste
  SERVICE_LIST

  # Benutzer nach der Service-Auswahl fragen
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    echo -e "\nSorry Buddy, that's not a valid option, try again."
    MAIN_MENU  # Rekursiver Aufruf bei ungültiger Eingabe
  else 
    # Überprüfe die Telefonnummer
    echo -e "What's your phone number?"
    read CUSTOMER_PHONE
    CHECK_PHONE_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Falls die Telefonnummer nicht vorhanden ist
    if [[ -z $CHECK_PHONE_NUMBER ]]
    then
      # Frage nach dem Namen
      echo "What's your name?"
      read CUSTOMER_NAME
      # Füge den neuen Kunden hinzu
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    
    # Terminzeit
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # Neuer Termin
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
    CUSTOMER_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED' LIMIT 1")
    
    echo -e "\nI have put you down for a $CUSTOMER_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
