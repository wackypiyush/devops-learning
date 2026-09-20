if [ -n "$1" ]; then
echo "Hello $1"
fi
echo "$(hostname)"
echo "$(whoami)"
echo "$(uptime)"
exit
