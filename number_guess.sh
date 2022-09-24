#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# GENERATE RANDOM NUM 1 - 1000
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
# PROVIDE USERNAMES
echo "Enter your username:"
read USERNAME
# IF USERNAME DOESN'T EXIST (New user)
CHECK_USERNAME=$($PSQL "SELECT username FROM user_score WHERE username='$USERNAME'")
if [[ -z $CHECK_USERNAME ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
INSERT_USER=$($PSQL "INSERT INTO user_score(username) VALUES('$USERNAME')")
# IF USERNAME EXIST (Old user)
else
GET_USERNAME=$($PSQL "SELECT username FROM user_score WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_score WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM user_score WHERE username='$USERNAME'")
echo "Welcome back, $GET_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
# SECRET NUMBER ANSWER
echo "Guess the secret number between 1 and 1000:"
read USER_ANSWER
let COUNT=1
# IF SECRET NUM ANSWER IS NOT A NUMBER
until [[ $USER_ANSWER = $RANDOM_NUMBER ]] 
do
while [[ ! $USER_ANSWER =~ ^[0-9]+$ ]]
do
echo "That is not an integer, guess again:"
read USER_ANSWER
done
# IF INPUT < SECRET NUM
while [[ $USER_ANSWER < $RANDOM_NUMBER ]]
do
echo "It's higher than that, guess again:"
read USER_ANSWER
let COUNT++
done
# IF INPUT > SECERET NUM
while [[ $USER_ANSWER > $RANDOM_NUMBER ]]
do
echo "It's lower than that, guess again:"
read USER_ANSWER
let COUNT++
done
done
# IF INPUT = SECRET NUM
if [[ $USER_ANSWER = $RANDOM_NUMBER ]]
then
echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_score SET games_played = games_played + 1 WHERE username='$USERNAME'")
UPDATE_BEST_GAME=$($PSQL "UPDATE user_score SET best_game = $COUNT WHERE (best_game > $COUNT OR best_game IS NULL)")
fi
