#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# If no argument provided
if [[ -z $1 ]]
then
  #Ask for an argument
  echo Please provide an element as an argument.
# If argument is provided
else
  # Read input
  INPUT=$1

  # Regular expression to check if it's a number
  CHECK_NUMBER='^[0-9]+$'

    # Regular expression to check if it's a number
  CHECK_NUMBER='^[0-9]+$'

  if [[ $INPUT =~ $CHECK_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = '$INPUT' ")
    # Case where argument is atomic number
  # If it isn't an atomic number
  else
    # Try seeing if it's a symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$INPUT' ")
    
    # If it isn't a symbol
    if [[ -z $ATOMIC_NUMBER ]]
    then
      #Try checking if it's a name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$INPUT' ")
    fi
  fi
  
  # If an atomic number was found, determine symbol and name
  if [[ $ATOMIC_NUMBER ]]
  then
    ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    ELEMENT_NAME=$(  $PSQL "SELECT name   FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    #echo $ELEMENT_SYMBOL
    #echo $ELEMENT_NAME
    #echo $ATOMIC_NUMBER
    PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING (type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
    echo "$PROPERTIES" | while IFS='|' read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  else
    echo "I could not find that element in the database."
  fi
fi
