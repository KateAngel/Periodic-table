#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

OUTPUT () {
ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties INNER JOIN elements 
                    ON properties.atomic_number=elements.atomic_number 
                    WHERE elements.atomic_number=$ATOMIC_NUMBER;")
MELTING=$($PSQL "SELECT melting_point_celsius FROM properties INNER JOIN elements 
                    ON properties.atomic_number=elements.atomic_number 
                    WHERE elements.atomic_number=$ATOMIC_NUMBER;")
BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties INNER JOIN elements 
                    ON properties.atomic_number=elements.atomic_number 
                    WHERE elements.atomic_number=$ATOMIC_NUMBER;")
TYPE=$($PSQL "SELECT types.type FROM types RIGHT JOIN properties 
                    ON types.type_id=properties.type_id INNER JOIN elements 
                    ON properties.atomic_number=elements.atomic_number 
                    WHERE elements.atomic_number=$ATOMIC_NUMBER;")
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

#check if has an argument
if [[ -z $1 ]]
# if yes
then
  echo "Please provide an element as an argument."
else
  ARG=$1
  # check if an argument is a number
  if [[ $ARG =~ ^[0-9]+$ ]]; then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ARG")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;")
      OUTPUT
    fi
  elif [[ $ARG =~ ^[a-zA-Z]{1,2}$ ]]; then
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$ARG'")
    if [[ -z $SYMBOL ]]
    then
      echo "I could not find that element in the database."
    else 
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL';")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL';")
      OUTPUT
    fi
  elif [[ $ARG =~ ^[a-zA-Z]+$ ]]; then
    NAME=$($PSQL "SELECT name FROM elements WHERE name='$ARG'")
    if [[ -z $NAME ]]
    then
        echo "I could not find that element in the database."
    else 
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME';")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$NAME';")
      OUTPUT
    fi
  else
    echo -e "I could not find that element in the database."
  fi
fi
