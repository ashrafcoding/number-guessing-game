#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET=$(( ( RANDOM % 1000 )  + 1 ))
TRIES=0

echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "select user_id from users where name = '$USERNAME'")
if [[ ! $USER_ID ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      INSERTED_TO_USERS=$($PSQL "insert into users(name) values('$USERNAME')")
      USER_ID=$($PSQL "select user_id from users where name = '$USERNAME'")
else
    GAMES_PLAYED=$($PSQL "select count(user_id) from games where user_id = $USER_ID")
    BEST_GUESS=$($PSQL "select min(guesses) from games where user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
fi 

echo "Guess the secret number between 1 and 1000:"
while true
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]] 
      then
        echo "That is not an integer, guess again:"
    else    
      if [[ $SECRET = $GUESS ]]
        then
          TRIES=$(($TRIES + 1))
          INSERTED_TO_GAMES=$($PSQL "insert into games(user_id, guesses) values($USER_ID, $TRIES)")
          echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
          break
      elif [[ $SECRET -gt $GUESS ]]
        then
          TRIES=$(($TRIES + 1))
          echo "It's higher than that, guess again:"
      else
        TRIES=$(($TRIES + 1))
        echo "It's lower than that, guess again:"
      fi
    fi
  done
