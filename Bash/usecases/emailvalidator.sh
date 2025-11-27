if [[ "$email" =~ ^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$ ]]; then
  echo "Valid email"
else
  echo "Invalid email"
fi