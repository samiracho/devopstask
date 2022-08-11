#!/bin/bash

# https://gist.github.com/CSTDev/08c127680e3b5fae38c051da3e489351

#get highest tag number
VERSION=$(git describe --abbrev=0 --tags 2>/dev/null)

#replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}
VNUM1=$(echo $VNUM1 | sed 's/v//')

# Check for #major or #minor in commit message and increment the relevant version number
MAJOR=$(git log --format=%B -n 1 HEAD | grep '#major')
MINOR=$(git log --format=%B -n 1 HEAD | grep '#minor')

if [ "$MAJOR" ]; then
    echo "Update major version"
    VNUM1=$((VNUM1+1))
    VNUM2=0
    VNUM3=0
elif [ "$MINOR" ]; then
    echo "Update minor version"
    VNUM2=$((VNUM2+1))
    VNUM3=0
else
    echo "Update patch version"
    VNUM3=$((VNUM3+1))
fi


#create new tag
NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"

if [ "$NEW_TAG" = "v..1" ]; then NEW_TAG='v1.0.0'; fi

echo "Updating $VERSION to $NEW_TAG"

#get current hash and see if it already has a tag
GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains $GIT_COMMIT 2>/dev/null)

#only tag if no tag already
if [ -z "$NEEDS_TAG" ]; then
    
    git tag $NEW_TAG
    git push --tags
    echo "Tagged with $NEW_TAG"
else
    echo "Already a tag on this commit"
fi