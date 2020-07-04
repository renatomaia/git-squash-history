#!/bin/bash

FREEZED=master
SQUASHED=squashed
HISTORY=devel
CHANGES=${1:-`git rev-parse --abbrev-ref HEAD`}

if [ -z "$(git branch --contains ${SQUASHED} --list ${CHANGES})" ]
then
	echo "Please choose a branch based on '${SQUASHED}'"
	git branch --contains ${SQUASHED} --list
	exit 3
fi

while read line
do
	if grep -Fx "$line" < <(git log --format=%s ${SQUASHED}..${CHANGES})
	then
		echo "Please squash local commit: ${line}"
		exit 1
	fi
done < <(git log --format=%s ${SQUASHED}..${CHANGES} | grep "fixup!" | sort | uniq | sed 's/fixup! //g')

git fetch origin ${HISTORY} ${SQUASHED}
if ! git diff --quiet origin/${HISTORY} origin/${SQUASHED}
then
	echo "Error: branches 'origin/${HISTORY}' and 'origin/${SQUASHED}' differ"
	exit 2
fi

if [ -z "$(git branch --contains origin/${SQUASHED} --list ${CHANGES})" ]
then
	echo "Please rebase your work to 'origin/${SQUASHED}':"
	echo "$ git rebase -i --autosquash --onto=origin/${SQUASHED} ${SQUASHED}"
	exit 3
fi

while read line
do
	if ! grep -Fx "$line" < <(git log --format=%s origin/${FREEZED}..${SQUASHED})
	then
		echo "Error: fixup commit referecing commit on 'origin/${FREEZED}': ${line}"
		exit 5
	fi
done < <(git log --format=%s origin/${SQUASHED}..${CHANGES} | grep "fixup!" | sort | uniq | sed 's/fixup! //g')

git checkout ${SQUASHED}

if ! git diff --quiet ${SQUASHED} ${CHANGES} && ! git merge --ff-only ${CHANGES}
then
	echo "Critical: unable to update branch '${SQUASHED}"
	exit 7
fi

if grep "fixup!" < <(git log --format=%s origin/${FREEZED}..${SQUASHED})
then
	echo "Please squash your work on '${CHANGES}':"
	echo "$ git rebase -i --autosquash ${FREEZED}"
	exit 8
fi

echo "Saving changes to branch '${HISTORY}' ..."
git checkout ${HISTORY} &&
git reset --hard ${CHANGES} &&
git rebase --onto=origin/${HISTORY} origin/${SQUASHED} &&
! git diff --quiet ${HISTORY} ${CHANGES} &&
echo "Critical: failed to update branch '${HISTORY}" && exit 6

#if git push ${HISTORY}
#then
#	git push --force ${SQUASHED}
#fi
