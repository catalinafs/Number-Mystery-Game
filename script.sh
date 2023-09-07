#!/bin/bash

# Variables for connecting to the database
# Change the host if it is different from the one you are going to use
DB_HOST='localhost'
# Change the port if it is different from yours
DB_PORT='5432'
# Change the name of the DB if it is different from yours
DB_NAME='number_mystery_db'
# Change the user if it is different from the one you are using
DB_USER='postgres'

userOptions() {
    echo -e '\n 1) Play\n 2) Sign In\n 3) Top 5 Players\n 4) Exit\n'
}

user_score() {
    if [ $attempts -le 5 ]; then
        score=100
    elif [ $attempts -le 10 ]; then
        score=90
    elif [ $attempts -le 15 ]; then
        score=80
    elif [ $attempts -le 20 ]; then
        score=60
    elif [ $attempts -le 25 ]; then
        score=40
    elif [ $attempts -le 30 ]; then
        score=20
    else
        score=0
    fi
}

whileNotGuessing() {
    while [[ ! $user_guess -eq $mystery_number || ! "$user_guess" =~ ^[0-9]+$ ]]; do
        echo -n -e '\n Guess the Mystery Number between 1 and 100: '
        read user_guess

        # echo $attempts
        attempts=$((attempts + 1))

        if [[ ! $user_guess =~ ^[0-9]+$ ]]; then
            echo -e "\n This "$user_guess" is not a valid option, please enter a valid number"
            continue
        fi

        if [ $user_guess -lt $mystery_number ]; then
            # echo $attempts
            echo -e "\n The Mystery Number is higher"
        elif [ $user_guess -gt $mystery_number ]; then
            # echo $attempts
            echo -e "\n The Mystery Number is lower"
        fi
        # attempts=$((attempts + 1))
    done
}

play() {
    clear
    echo -e "\n Hi player! We hope you're doing well\n"
    echo -n '  Please, enter your username: '
    read username
    echo -e -n '\n Loading'
    echo -n '.'
    sleep 1
    echo -n '.'
    sleep 1
    echo -n '.'
    sleep 1

    echo -e '\n'

    PLAYER_USERNAME=$(psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -t -c "SELECT username FROM player WHERE username = '"$username"';")
    if [ -z "$PLAYER_USERNAME" ]; then
        echo -e ' Ups! It seems that you are not registered yet'
        echo ' Do you want to register or exit the game?'
        echo -e '\n  1) Register\n  2) Exit\n'
        read usernameNotFund

        if [ $usernameNotFund -eq 1 ]; then
            signInUser
        elif [ $usernameNotFund -eq 2 ]; then
            clear
            echo -e '\n We are sad that you are leaving, we hope to see you again soon :('
            exit
        else
            echo -e '\n Invalid option, try again later ^_~'
        fi
    else
        echo -e "\n Welcome player,"$PLAYER_USERNAME"!"

        echo -e ' The game will start in\n'
        sleep 0.1
        echo -n '  1'
        sleep 0.2
        echo -n '.'
        sleep 0.2
        echo -n '.'
        sleep 0.2
        echo -n '.'
        sleep 0.1
        echo -n '  2'
        sleep 0.2
        echo -n '.'
        sleep 0.2
        echo -n '.'
        sleep 0.2
        echo -n '.'
        sleep 0.3
        echo '  3'

        clear
        echo -e '\n   Good luck with the mystery number ;)'

        mystery_number=$((($RANDOM % 100) + 1))
        attempts=1
        user_guess=-1

        whileNotGuessing

        if [ $user_guess -eq $mystery_number ]; then
            attempts=$((attempts - 1))
            echo -e '\n  Congratulations Player '$username', you have found the Mystery Number ('$mystery_number') in '$attempts' attempts'
            user_score
            echo -e '\n   You score is '$score'\n'

            psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -c "UPDATE player SET score="$score", last_played=now() WHERE username = '"$username"';"
        else
            echo -e ' Player '$username' you have not find the mysterious number\n You can try again'
            whileNotGuessing
        fi
    fi
}

signInUser() {
    clear
    echo -e '\n We are glad you want to register\n'

    # Query variables
    echo -n '  Please enter a unique user(up to 30 characters): '
    read username
    echo ''

    # SQL query with INSERT INTO
    signInUser="INSERT INTO player(username) VALUES ('"${username}"');"

    # The query is executed
    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -U ${DB_USER} -c "$signInUser"
}

top5scores() {
    clear
    echo -e '\n----------------- Top 5 Players -----------------\n'
    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -U ${DB_USER} -c "SELECT username, score, last_played FROM player ORDER BY score DESC LIMIT 5;"
}

# The user is welcomed and shown the options
clear
echo -e '\n Welcome to the Number Mystery Game!\n'
echo -e ' You have to try to guess the mysterious number between 1 and 100\n Good luck and have fun!\n'

options=("Play" "Sign In" "Top 5 Players" "Exit")
select option in "${options[@]}"; do
    case $option in
    "Play")
        # Call the function insertClient
        play

        # The user options are displayed again
        userOptions
        ;;

    "Sign In")
        # Call the function insertBike
        signInUser

        # The user options are displayed again
        userOptions
        ;;

    "Top 5 Players")
        # Call the function top5scores
        top5scores

        # The user options are displayed again
        userOptions
        ;;

    "Exit")
        clear
        echo -e '\n\n  Until next time ;)'
        break
        ;;

    *)
        echo "Invalid option: $REPLY"
        echo "Try again"

        # The user options are displayed again
        userOptions
        ;;
    esac
done
