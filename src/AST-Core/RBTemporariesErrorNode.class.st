"
This is a particular englobing node that is a temporaries.
Exemple : | temporaries node |
Can be created by forgetting 
the closure : | temporaries node .
Forgetting the opening will be assumed to be a binary selector.
"
Class {
	#name : #RBTemporariesErrorNode,
	#superclass : #RBEnglobingErrorNode,
	#category : #'AST-Core-Nodes - ErrorNodes'
}

{ #category : #construction }
RBTemporariesErrorNode class >> error: aToken withNodes: aCollection [
	"A RBTemporariesErrorNode can only be created from the opening token by choice.
	 Since the closure is a |, the default assumption is that it's a binary selector."
	"If the collection is empty, there is only the token in the error."
	^aCollection isEmpty
		ifTrue: [ self new contents: aCollection; start: aToken start; stop: aToken stop; errorMessage: '''|'' or variable expected' ]
		ifFalse: [ self new contents: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: '''|'' or variable expected' ]
]

{ #category : #testing }
RBTemporariesErrorNode >> hasTemporaries [
	^true
]

{ #category : #testing }
RBTemporariesErrorNode >> isTemporariesError [
	^true
]

{ #category : #accessing }
RBTemporariesErrorNode >> temporaries [
	"Consider the content to act as bad temporaries variables"

	^ contents
]
