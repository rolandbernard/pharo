"
SUnit tests for key map builder
"
Class {
	#name : #KMKeymapBuilderTest,
	#superclass : #AbstractKeymappingTest,
	#category : #'Keymapping-Tests'
}

{ #category : #tests }
KMKeymapBuilderTest >> testAddKeymapCreatesCategory [
	self assertEmpty: KMRepository default categories.

	KMRepository default
		initializeKeymap: #test
		executingOn: $r ctrl , $r asKeyCombination , $r asKeyCombination
		doing: [ :receiver | "nothing" ]
		inCategory: #Testing
		platform: #all.

	self assert: (KMRepository default includesCategoryNamed: #Testing).
	self assert: KMRepository default categories size equals: 1
]

{ #category : #tests }
KMKeymapBuilderTest >> testAddKeymapCreatesShortcut [
	KMRepository default
		initializeKeymap: #test
		executingOn: $r ctrl, $r asKeyCombination, $r asKeyCombination
		doing: [ :receiver | "nothing" ]
		inCategory: #Testing
		platform: #all.

	self assert: (KMRepository default categoryForName: #Testing) allEntries size equals: 1
]

{ #category : #tests }
KMKeymapBuilderTest >> testAttachKeymapAndExecuteExecutes [
	| executed morphToTest |
	executed := false.

	KMFactory keymapContainer
		initializeKeymap: #test
		executingOn: $a asKeyCombination, $a asKeyCombination, $a asKeyCombination
		doing: [ :receiver | executed := true ]
		inCategory: #Testing
		platform: #all.

	"KMFactory keymapContainer attachCategoryName: #Testing to: Morph."

	morphToTest := Morph new.
	morphToTest attachKeymapCategory: #Testing.

	{self eventKey: $a. self eventKey: $a. self eventKey: $a}
		do: [:e | morphToTest dispatchKeystrokeForEvent: e].

	self assert: executed
]
