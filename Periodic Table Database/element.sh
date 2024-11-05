#!/bin/bash

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Store the argument
input=$1

# Query the database for the element details based on atomic_number, symbol, or name
result=$(psql -X --username=freecodecamp --dbname=periodic_table -t -c "
SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
FROM elements
JOIN properties ON elements.atomic_number = properties.atomic_number
JOIN types ON properties.type_id = types.type_id
WHERE elements.atomic_number::text = '$input' OR elements.symbol = '$input' OR elements.name = '$input';
")

# Check if the query returned any result
if [[ -z $result ]]; then
  echo "I could not find that element in the database."
else
  # Extract and format the result
  echo "$result" | while IFS=" |" read -r atomic_number name symbol type atomic_mass melting_point boiling_point; do
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
  done
fi
