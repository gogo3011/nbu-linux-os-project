# create and infinite loop, so the user always gets the menu
while :
do
# print out menu options
echo "-----------------------------------"
echo "Select user listing option"
echo "1. List all users"
echo "2. List users filtered by their username"
echo "3. List users filtered by their user id"
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
    2)  echo "Write string to filter by:"
        # read namefilter from input
        read nameFilter
        # filter out users output with the nameFilter
        getent passwd | grep $nameFilter;;
    3)  echo "Write user id to filter by:"
        # read userIdFilter from input
        read userIdFilter
        # use awk with the users database by separating the cols by separator :
        # condition to output (is userIdFilter equal to the third col)
        awk -v u=$userIdFilter -F":" '$3 == u' /etc/passwd
        ;;
    4)  echo "bye ;)"
        # exit from script
        exit;;
    *)  # just catch all invalid menu option
        echo "invalid input"
        ;;
    
esac
done
