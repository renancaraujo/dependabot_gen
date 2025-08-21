

new_version="$1"
old_version="$2"

if [[ "$old_version" == "" ]]; then
  old_version=$(dart pub deps --json | pcregrep -o1 -i '"version": "(.*?)"' | head -1)
fi

if [[ "$new_version" == "" ]]; then 
  echo "No new version supplied, please provide one"
  exit 1
fi

if [[ "$new_version" == "$old_version" ]]; then
  echo "Current version is $old_version, can't update."
  exit 1
fi

echo "Updating from $old_version to $new_version"

previousTag="v${old_version}"
raw_commits="$(git log --pretty=format:"%s" --no-merges --reverse $previousTag..HEAD -- .)"

# Filter out chore commits (commits starting with "chore:" or "chore(")
filtered_commits=$(echo "$raw_commits" | grep -v -E "^chore(\(|:)")

markdown_commits=$(echo "$filtered_commits" | sed -En "s/\(#([0-9]+)\)/([#\1](https:\/\/github.com\/renancaraujo\/dependabot_gen\/pull\/\1))/p")

if [[ "$markdown_commits" == "" ]]; then
  echo "No commits since last tag, can't update."
  exit 0
fi
commits=$(echo "$markdown_commits" | sed -En "s/^/- /p")

sed -i '' "s/version: $old_version/version: $new_version/g" pubspec.yaml

dart run build_runner build --delete-conflicting-outputs > /dev/null

if grep -q $new_version "CHANGELOG.md"; then
  echo "CHANGELOG already contains version $new_version."
  exit 1
fi


# Add a new version entry with the found commits to the CHANGELOG.md.
echo "# ${new_version}\n\n${commits}\n\n$(cat CHANGELOG.md)" > CHANGELOG.md
echo "CHANGELOG  generated, validate entries here: $(pwd)/CHANGELOG.md"

echo "Creating git branch for $new_version"
git checkout -b "chore/$new_version" > /dev/null

git add pubspec.yaml CHANGELOG.md 
if [ -f lib/version.dart ]; then
  git add lib/version.dart
fi


echo ""
echo "Run the following command if you wish to commit the changes:"
echo "git commit -m \"chore: $new_version\""
