#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~ Isaaks Salon ~~\n"
echo -e "Welcome to my Salon, how can I serve you today?\n"

# Funktion, um die Services anzuzeigen
SERVICE_LIST() {
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while IFS='|' read -r ID NAME
  do
    echo $ID')' $NAME
  done
}

# Hauptmenü
MAIN_MENU() {
  while true; do
    # Zeige die verfügbaren Services als nummerierte Liste
    SERVICE_LIST

    # Benutzer nach der Service-Auswahl fragen
    echo -e "\nPlease select a service by entering the number."
    read SERVICE_ID_SELECTED
    
    # Überprüfe, ob die Eingabe gültig ist
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]; then
      echo -e "\nSorry, that's not a valid option, please try again."
    else
      break  # gültige Auswahl, Schleife beenden
    fi
  done

  # Überprüfe die Telefonnummer
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE
  CHECK_PHONE_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

  # Falls die Telefonnummer nicht vorhanden ist
  if [[ -z $CHECK_PHONE_NUMBER ]]; then
    # Frage nach dem Namen
    echo "What's your name?"
    read CUSTOMER_NAME
    # Füge den neuen Kunden hinzu
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" | xargs)
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
  fi

  # Frage nach der Terminzeit
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

  # Neuen Termin eintragen
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')" | xargs)
  
  CUSTOMER_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'" | xargs)
  
  echo -e "\nI have put you down for a $CUSTOMER_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Hauptmenü starten
MAIN_MENU
