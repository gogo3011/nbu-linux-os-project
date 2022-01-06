while :
do
echo "-----------------------------------"
echo "Select user listing option"
echo "1. List all users"
echo "2. List users filtered by their username"
echo "3. List users filtered by their user id"
echo "4. Exit from string"
echo "-----------------------------------"

echo -n "Enter your menu choice [1-4]: "

read menuChoice

case $menuChoice in 
    1)  getent passwd | cut -d: -f1;;
    2)  echo "Write string to filter by:"
        read nameFilter
        getent passwd | grep $nameFilter;;
    3)  echo "write user id to filter by:"
        read userIdFilter
        # getent passwd | grep :$userIdFilter
        awk -v u=$userIdFilter -F":" '$3 == u' /etc/passwd
        ;;
    4)  echo "bye ;)"
        exit;;
    
esac
done
