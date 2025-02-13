Class {
	#name : #ClyTraitFirstSortFunctionTest,
	#superclass : #ClySortFunctionTest,
	#category : #'Calypso-SystemPlugins-Traits-Queries-Tests'
}

{ #category : #tests }
ClyTraitFirstSortFunctionTest >> testAscending [

	function := ClyTraitFirstSortFunction ascending.

	self assert: (function value: ClyTraitRoot1 value: ClyTraitRoot2 ).
	self deny: (function value: ClyTraitRoot2 value: ClyTraitRoot1 ).
	self deny: (function value: ClyClass1FromP1Mock value: ClyTraitRoot1).
	self assert: (function value: ClyTraitRoot1 value: ClyClass1FromP1Mock ).
	self assert: (function value: ClyTraitRoot1 value: ClyTraitRoot1 ).
	self assert: (function value: ClyClass1FromP1Mock value: ClyClass1FromP1Mock )
]
