# create and infinite loop, so the user always gets the menu
# and can execute a function
while :
do
# print out menu options
echo "-----------------------------------"
echo "Select user listing option"
echo "1. List all users"
echo "2. List users filtered by a regex pattern"
echo "3. List users filtered by their username"
echo "4. Exit from script"
echo "-----------------------------------"

echo -n "Enter your menu choice [1-4]: "
# read user input
read menuChoice

# switch case with each action
case $menuChoice in 
        # just list all users
    1)  getent passwd
        # end of block
        ;;
    2)  echo "Write string/regex to filter by:"
        # read filter from input
        read filter
        # filter out users output with the filter
        getent passwd | grep $filter;;
    3)  echo "Write username chars to filter by:"
        # read userIdFilter from input
        read userNameFilter
        # use awk with the users database by separating the cols by separator :
        # condition to output (is userIdFilter equal to the third col)
        getent passwd | awk -v u="$userNameFilter" -F ':' 'index($1, u)'
        ;;
    4)  echo "bye ;)"
        # exit from script
        exit;;
    *)  # just catch all invalid menu option
        echo "invalid input"
        ;;
# end switch case statement
esac
done

exit 0