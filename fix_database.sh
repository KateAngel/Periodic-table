#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# echo $($PSQL "DROP TABLE IF EXISTS types;")
# echo $($PSQL "ALTER TABLE elements DROP CONSTRAINT symbol_unique;") "drop symbol_unique"
# echo $($PSQL "ALTER TABLE elements DROP CONSTRAINT name_unique;") "drop name_unique"
# echo $($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius DROP NOT NULL;") "melting drop not null"
# echo $($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius DROP NOT NULL;") "boiling drop not null"
# echo $($PSQL "ALTER TABLE properties RENAME COLUMN atomic_mass TO weight;")
# echo $($PSQL "ALTER TABLE properties RENAME COLUMN melting_point_celsius TO melting_point;")
# echo $($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point_celsius TO boiling_point;")


# rename the weight column to atomic_mass
  COLUMN_EXISTS_WEIGHT=$($PSQL "SELECT * FROM information_schema.columns
                        WHERE table_name='properties' and column_name='weight';")
  if [[ -z $COLUMN_EXISTS_WEIGHT ]]
  then
    echo -e "\nColumn 'weight' is not found"
  else 
    echo $($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;") "weight"
  fi
# rename the melting_point column to melting_point_celsius
COLUMN_EXISTS_MELTING=$($PSQL "SELECT * FROM information_schema.columns
                        WHERE table_name='properties' and column_name='melting_point';")
  if [[ -z $COLUMN_EXISTS_MELTING ]]
  then
    echo -e "\nColumn 'melting_point' is not found"
  else 
    echo $($PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;") "melting"
  fi
# rename the boiling_point column to boiling_point_celsius
COLUMN_EXISTS_BOILING=$($PSQL "SELECT * FROM information_schema.columns
                        WHERE table_name='properties' and column_name='boiling_point';")
  if [[ -z $COLUMN_EXISTS_BOILING ]]
  then
    echo -e "\nColumn 'boiling_point' is not found"
  else 
    echo $($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;") "boiling"
  fi
# melting_point_celsius and boiling_point_celsius columns should not accept null values
echo $($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;") "melting set not null"
echo $($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;") "boiling set not null"
# add the UNIQUE constraint to the symbol and name columns from the elements table
echo $($PSQL "ALTER TABLE elements ADD CONSTRAINT symbol_unique UNIQUE (symbol);") "add symbol_unique"
echo $($PSQL "ALTER TABLE elements ADD CONSTRAINT name_unique UNIQUE (name);") "add name_unique"
# Your symbol and name columns should have the NOT NULL constraint
echo $($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;") "symbol set not null"
echo $($PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL;") "name set not null"
# set properties(atomic_number) as a foreign key that references elements(atomic_number)
echo $($PSQL "ALTER TABLE properties ADD CONSTRAINT fk_pr_el_atomic_number 
              FOREIGN KEY (atomic_number) REFERENCES elements(atomic_number);")
# create a types table
echo $($PSQL "CREATE TABLE types(
  type_id SERIAL PRIMARY KEY,
  type VARCHAR(30) NOT NULL
);") "types"

# add three rows to types table = three different types from the properties table
# insert type options from properties
  NUMBER_TYPE_TO_INSERT=$($PSQL "SELECT COUNT(type) FROM 
                                (SELECT DISTINCT properties.type as type FROM properties 
                                LEFT JOIN types ON properties.type=types.type 
                                WHERE types.type is null) as types_to_insert;")
  # if number of types in properties not yet inserted in types >0:                              
  if [[ $NUMBER_TYPE_TO_INSERT > 0 ]]
  then
    INSERT_TYPE=$($PSQL "INSERT INTO types(type) 
                  SELECT DISTINCT properties.type FROM properties 
                  LEFT JOIN types ON properties.type=types.type 
                  WHERE types.type IS NULL;")
    if [[ $INSERT_TYPE == "INSERT 0 $NUMBER_TYPE_TO_INSERT" ]]
    then
    echo "$NUMBER_TYPE_TO_INSERT types inserted"
    fi
  # else nothing to insert
  else
    echo "Nothing to insert"
  fi

# properties table should have a type_id foreign key column that references the type_id
echo $($PSQL "ALTER TABLE properties ADD COLUMN type_id INT;") "type_id column added"
echo $($PSQL "UPDATE properties SET type_id=types.type_id 
              FROM types WHERE properties.type=types.type;") "type_id filled"
echo $($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;") "type_id set not null"
echo $($PSQL "ALTER TABLE properties ADD CONSTRAINT fk_pr_type_type_id 
              FOREIGN KEY (type_id) REFERENCES types(type_id);") "type_id constraint"
# capitalize the first letter of all the symbol values in the elements
echo $($PSQL "UPDATE elements SET symbol=INITCAP(symbol);") "symbol capitalized"
# remove all the trailing zeros after the decimals from each row of the atomic_mass
echo $($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;")
echo $($PSQL "UPDATE properties SET atomic_mass=TRIM(TRAILING '0' FROM atomic_mass::text)::DECIMAL;") "all the trailing zeros removed"
# add Fluorine
# get atomic_number
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=9")
  # if not found
  if [[ -z $ATOMIC_NUMBER ]]
  then
  # insert to elements
    INSERT_TO_ELEMENTS=$($PSQL "INSERT INTO elements(atomic_number,symbol,name) 
                                              VALUES(9,'F','Fluorine')")
      if [[ $INSERT_TO_ELEMENTS == "INSERT 0 1" ]]
      then
        echo Inserted into elements, $ATOMIC_NUMBER
      fi
  # insert to properties
    INSERT_TO_PROPERTIES=$($PSQL "INSERT INTO properties(atomic_number,type,atomic_mass,melting_point_celsius,boiling_point_celsius,type_id)
                                                  VALUES(9,'nonmetal',18.998,-220,-188.1,3)")
      if [[ $INSERT_TO_PROPERTIES == "INSERT 0 1" ]]
      then
        echo Inserted into properties, $ATOMIC_NUMBER
      fi
  fi  
# add Neon
# get atomic_number
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=10")
  # if not found
  if [[ -z $ATOMIC_NUMBER ]]
  then
  # insert to elements
    INSERT_TO_ELEMENTS=$($PSQL "INSERT INTO elements(atomic_number,symbol,name) 
                                              VALUES(10,'Ne','Neon')")
      if [[ $INSERT_TO_ELEMENTS == "INSERT 0 1" ]]
      then
        echo Inserted into elements, $ATOMIC_NUMBER
      fi
  # insert to properties
    INSERT_TO_PROPERTIES=$($PSQL "INSERT INTO properties(atomic_number,type,atomic_mass,melting_point_celsius,boiling_point_celsius,type_id)
                                                  VALUES(10,'nonmetal',20.18,-248.6,-246.1,3)")
      if [[ $INSERT_TO_PROPERTIES == "INSERT 0 1" ]]
      then
        echo Inserted into properties, $ATOMIC_NUMBER
      fi
  fi  

  $($PSQL "DELETE FROM properties WHERE atomic_number=1000;")
  $($PSQL "DELETE FROM elements WHERE atomic_number=1000;")
  $($PSQL "ALTER TABLE properties DROP COLUMN type;")