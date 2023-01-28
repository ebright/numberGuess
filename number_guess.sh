#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

##INITAL SCRIPT LAYOUT##

MAIN() {
  NUMBER_TO_GUESS=$[ $RANDOM % 1000 + 1 ]
  ATTEMPTS=0
  echo "Enter your username:" 
 
  read USERNAME
  
  RESULTS=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
  read USER_ID CHECK_USER <<< $(echo $RESULTS | sed 's/|/ /g')

  if [[ $CHECK_USER != $USERNAME ]]
    then
      echo $($PSQL "INSERT INTO users(username) VALUES ('$USERNAME') ") > /dev/null
      echo -e "Welcome, $USERNAME! It looks like this is your first time here."
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    else
      GET_USER_DETAILS
      echo -e "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  
  PLAY_GAME
}
#ADD_USER()

GET_USER_DETAILS() {
    RESULTS=$($PSQL "SELECT game_id, number_of_guesses FROM users INNER JOIN games USING(user_id) WHERE user_id = $USER_ID;")

    if [[ -z $RESULTS ]]
      then
        echo $($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES ($USER_ID, 0)") > /dev/null
    fi
    DB_USERNAME=$($PSQL "SELECT username FROM users WHERE user_id = $USER_ID;")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID;")
    BEST_GAME=$($PSQL "SELECT min(number_of_guesses) FROM games WHERE user_id = $USER_ID;")
}

PLAY_GAME() {
  if [[ $1 ]]
  then
    echo -e "$1"
  else
	  echo -e "Guess the secret number between 1 and 1000:" 
  fi
  read GUESS
  let "ATTEMPTS++"
  if ! [[ $GUESS =~ ^[0-9]*$ ]]
    then
      PLAY_GAME "That is not an integer, guess again:"
  elif [[ $GUESS -lt $NUMBER_TO_GUESS ]]
    then
      PLAY_GAME "It's higher than that, guess again:"
  elif [[ $GUESS -gt $NUMBER_TO_GUESS ]]
    then
      PLAY_GAME "It's lower than that, guess again:"
  elif [[ $GUESS -eq $NUMBER_TO_GUESS ]]
    then
      GUESSED_IT
  fi

}

GUESSED_IT() {
  
  echo $($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES ($USER_ID, $ATTEMPTS)") > /dev/null
  echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
}

MAIN