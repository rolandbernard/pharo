"
Checks for any unary ""accessing"" methods without explicit return statements.
"
Class {
	#name : #ReUnaryAccessingMethodWithoutReturnRule,
	#superclass : #ReAbstractRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #testing }
ReUnaryAccessingMethodWithoutReturnRule class >> checksMethod [
	^ true
]

{ #category : #accessing }
ReUnaryAccessingMethodWithoutReturnRule class >> uniqueIdentifierName [

	^ 'UnaryAccessingMethodWithoutReturnRule'
]

{ #category : #running }
ReUnaryAccessingMethodWithoutReturnRule >> basicCheck: aMethod [

	(aMethod numArgs > 0 or: [ aMethod isAbstract ]) ifTrue: [ ^ false ].
	(aMethod protocol beginsWith: 'accessing') ifFalse: [ ^ false ].
	^ aMethod ast allChildren noneSatisfy: [ :each | each isReturn ]
]

{ #category : #accessing }
ReUnaryAccessingMethodWithoutReturnRule >> group [
	^ 'Potential Bugs'
]

{ #category : #accessing }
ReUnaryAccessingMethodWithoutReturnRule >> name [
	^ 'Unary "accessing" method without explicit return'
]
