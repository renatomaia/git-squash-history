#!/bin/bash

SQUASHED=origin/squashed
HISTORY=origin/devel

current=$(git rev-parse ${HISTORY})
while read squashed
do
	while read history
	do
		if git diff --quiet ${history} ${squashed}
		then
			echo ${history} ${squashed}
			commit=${history}
			break
		fi
	done < <(git rev-list ${current})
	commit=$(git rev-parse ${current}~1) || exit
done < <(git rev-list ${SQUASHED})


# 2be57260445b6d9dd02b3b3be61797f71319d21b 47be89a2048009134c08e8cb37c33d503051c4fb
# 72554f75c897f7f60b84b4b30791dac3a57f245e 1e253e9c97a73ce3d3e76b80d867bbe785321821
# e0a4e66430392bf123bbdb81d6616febec934be1 46d4b0968c6f66c5522a448c02f33710dc49ad4e
# 7df246e1c0db51782e2b2f5955cf79befc963ddc 34136e813f6d2eec6954136ccad91e9870e81ba7
# 775152e3b71706c8a42d10c9fed11609b85ff4dd 2a42297a13a01b9b401f51c5c7f6bfef71e2f152
# 9a3ce9d984ba3ff415b2c312790f48c551b53a79 d3ac8d7229c312a950f42a6e9c7cf7fb8ca85a3b
# b38d83333e1a998cef7e750d8e9f18e6b7664cb8 e240fe54d7fc6f4e0179ebaf6f092d882c6466b9
# 779fa6503174afcecdbac19a774bb0a381819a3c 892ed7bb17e766c11e9ee0dbe656dc3b7d01062a
# 3c8f42d0aee2d836a5eabedf9dd8ab98b90806ff 401edc54ac7766f8ee9435b7fb43657d3bf4e6aa
# 833c60061442036b470b8bd108c157c1c64051b7 c316f8d04fa8a187a6640de553c1f819240914fc
# 0be7ed89e07d0297015130370a410c6396d462a6 b2cf80abfb7f61a99ddfe3fe99a050e749c6289b
# 55093ffec93815b1f0a0b674d592e5c031e9ba72 d10a6404ed4c8918979219171c4b0d5daca4b893
# 9c045c332550095171951871d5ccfd409b5af487 58a6b7f3792f658a4c1e9beaa38fe2b61338ab48
