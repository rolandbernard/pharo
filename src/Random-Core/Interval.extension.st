Extension { #name : #Interval }

{ #category : #'*Random-Core' }
Interval >> shuffled [
	"Return an array that contains my elements shuffled in a random order"
	^ self asArray shuffle
]
