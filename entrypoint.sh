echo "Cloning destination git repository"

git config --global user.email "shreyans.gupta@blueyonder.com"
git config --global user.name "shreyans-gupta-by"
git clone --single-branch --branch main "https://x-access-token:$API_TOKEN_GITHUB@github.com/amol-singh-by/cps.git" 

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
  then
     git commit --message "A custom message for the commit"
     echo "Pushing git commit"
     git push -u origin HEAD:main
  else
     echo "No changes detected"
fi
