#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams,games")

#Inserting winner and opponent into teams table
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNERS_GOAL OPPONENTS_GOAL
do
  if [[ $YEAR != 'year' ]]
  then
    # get winner name
    TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")

    # if not found
    if [[ -z $TEAM ]]
    then 
      # insert winner name
      INSERT_TEAM_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      # check if results are good
      if [[ $INSERT_TEAM_RESULTS == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi

    # get opponent name
    TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")

    # if not found
    if [[ -z $TEAM ]]
    then 
      # insert winner name
      INSERT_TEAM_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      # check if results are good
      if [[ $INSERT_TEAM_RESULTS == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi
  fi
done

#Inserting the games into games table
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNERS_GOAL OPPONENTS_GOAL
do
  #check if header
  if [[ $YEAR != 'year' ]]
  then
    #get winner team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    
    #get opponent team_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    #insert the games data
    INSERT_INTO_GAMES_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNERS_GOAL,$OPPONENTS_GOAL)")

    #check if insert succeed
    if [[ $INSERT_INTO_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo "Insert into games, $WINNER_ID AND $OPPONENT_ID ON $YEAR"
    fi
  fi
done
