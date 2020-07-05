#!/bin/bash

FREEZED=master
SQUASHED=squashed
HISTORY=history
WORKING=${1:-`git rev-parse --abbrev-ref HEAD`}

if [[ "${WORKING}" == "${FREEZED}" || "${WORKING}" == "${SQUASHED}" || "${WORKING}" == "${HISTORY}" ]]
then
	echo "Please checkout a non-reserved branch (${FREEZED}, ${HISTORY}, ${SQUASHED})"
	exit 1
fi

if [ "$(git rev-parse ${HISTORY})" != "$(git rev-parse origin/${HISTORY})" ]
then
	echo "Please update ${HISTORY}"
	exit 2
fi

#while read line
#do
#	if grep -Fx "$line" < <(git log --format=%s ${SQUASHED}..${WORKING})
#	then
#		echo "Please squash local commit: ${line}"
#		exit 3
#	fi
#done < <(git log --format=%s ${SQUASHED}..${WORKING} | grep "fixup!" | sort | uniq | sed 's/fixup! //g')

git fetch origin ${HISTORY} ${SQUASHED}
if ! git diff --quiet origin/${HISTORY} origin/${SQUASHED}
then
	echo "Error: branches 'origin/${HISTORY}' and 'origin/${SQUASHED}' differ."
	exit 4
fi

if ! git merge-base --is-ancestor origin/${SQUASHED} ${WORKING}
then
	echo "Please rebase your work to 'origin/${SQUASHED}':"
	echo "$ git rebase -i --autosquash --onto=origin/${SQUASHED} ${SQUASHED}"
	exit 5
fi

while read line
do
	if grep -Fx "$line" < <(git log --format=%s origin/${FREEZED}..origin/${SQUASHED})
	then
		echo "Error: fixup commit referecing commit on 'origin/${FREEZED}': ${line}"
		exit 6
	fi
done < <(git log --format=%s origin/${SQUASHED}..${WORKING} | grep "fixup!" | sort | uniq | sed 's/fixup! //g')

git checkout ${SQUASHED}

if ! git diff --quiet ${SQUASHED} ${WORKING}
then
	git merge --ff-only ${WORKING} ||
	( echo "Critical: unable to update branch '${SQUASHED}." && exit 7 )
fi

if grep "fixup!" < <(git log --format=%s origin/${FREEZED}..${SQUASHED})
then
	echo "Please squash your work on '${WORKING}':"
	echo "  $ git rebase -i --autosquash ${FREEZED}"
	exit 8
fi

echo "Saving changes to branch '${HISTORY}' ..."
git checkout ${HISTORY} &&
git reset --hard ${WORKING} &&
git rebase --onto=origin/${HISTORY} origin/${SQUASHED} &&
git diff --quiet ${HISTORY} ${WORKING} &&
git diff --quiet ${HISTORY} ${SQUASHED} ||
( echo "Critical: failed to update branch '${HISTORY}" && exit 9 )

if grep "fixup!" < <(git log --format=%s origin/${HISTORY}..${HISTORY})
then
	git merge --no-edit ${SQUASHED} ||
	( echo "Critical: failed to update branch '${HISTORY}" && exit 10 )
fi

echo "Pushing changes to remote '${HISTORY}' ..."
git push origin ${HISTORY} &&
git push origin --force ${SQUASHED} ||
( echo "Error: unable to push to remote." && exit 11 )

git checkout ${WORKING}
