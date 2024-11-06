#!/bin/bash

# Database connection setup
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for a username
echo "Enter your username:"
read USERNAME

# Ensure username length does not exceed 22 characters
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters. Please try again."
  exit 1
fi

# Check if the user exists in the database
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

# Determine if the user is new or returning
if [[ -z $USER_DATA ]]; then
  # New user case
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into the database
  INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Returning user case - Note the exact format required
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate the secret number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"

# Initialize the guess counter
NUMBER_OF_GUESSES=0

# Main game loop
while true; do
  read GUESS

  # Validate if the guess is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment guess counter
  ((NUMBER_OF_GUESSES++))

  # Check if the guess matches the secret number
  if (( GUESS == SECRET_NUMBER )); then
    # Note the exact format required for the winning message
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done

# Update user statistics in the database
((GAMES_PLAYED++))
if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$NUMBER_OF_GUESSES
fi
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
