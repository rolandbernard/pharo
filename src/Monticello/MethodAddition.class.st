"
I represent the addition of a method to a class.  I can produce the CompiledMethod, install it, and then notify the system that the method has been added.  This allows Monticello to implement atomic addition.  A loader can compile all classes and methods first and then install all methods only after they have been all compiled, and in a way that executes little code.
"
Class {
	#name : #MethodAddition,
	#superclass : #Object,
	#instVars : [
		'text',
		'category',
		'changeStamp',
		'logSource',
		'myClass',
		'selector',
		'compiledMethod',
		'priorMethodOrNil',
		'priorCategoryOrNil'
	],
	#category : #'Monticello-Loading'
}

{ #category : #compilation }
MethodAddition >> compile [
    "This method is the how compiling a method used to work.  All these steps were done at once.
     This method should not normally be used, because the whole point of MethodAddition is to let
	you first create a compiled method and then install the method later."
	self createCompiledMethod.
	self installMethod.
	self notifyObservers.
	^selector
]

{ #category : #compilation }
MethodAddition >> compile: aString classified: aString1 withStamp: aString2 logSource: aBoolean inClass: aClass [

	text := aString.
	category := aString1.
	changeStamp := aString2.
	logSource := aBoolean.
	myClass := aClass
]

{ #category : #operations }
MethodAddition >> createCompiledMethod [
	"CyrilFerlicot: Why do we need to explicitly write to the source? Why do we call the compiler?
	
	Can't we just call #compile:classfied: here?"
	compiledMethod := myClass compiler permitUndeclared: true; compile: text asString.
	selector := compiledMethod selector.
	self writeSourceToLog.
	priorMethodOrNil := myClass compiledMethodAt: selector ifAbsent: [ nil ].
	priorCategoryOrNil := myClass organization protocolNameOfElement: selector
]

{ #category : #operations }
MethodAddition >> installMethod [
	SystemAnnouncer uniqueInstance
		suspendAllWhile: [ myClass addSelector: selector withMethod: compiledMethod ]
]

{ #category : #notifying }
MethodAddition >> notifyObservers [
	SystemAnnouncer uniqueInstance 
		suspendAllWhile: [myClass organization classify: selector under: category].
	priorMethodOrNil 
		ifNil: [ SystemAnnouncer uniqueInstance
				methodAdded: compiledMethod
				configuredWith: [ :event | 
					event
						propertyAt: #eventSource
						put: #Monticello ] ]
		ifNotNil: [
			SystemAnnouncer uniqueInstance methodChangedFrom: priorMethodOrNil to: compiledMethod oldProtocol: priorCategoryOrNil.
			priorCategoryOrNil = category ifFalse: [
       			SystemAnnouncer uniqueInstance methodRecategorized: compiledMethod oldProtocol: priorCategoryOrNil ] ].
	"The following code doesn't seem to do anything."
	myClass instanceSide noteCompilationOf: compiledMethod meta: myClass isClassSide.

]

{ #category : #accessing }
MethodAddition >> priorCategoryOrNil [
	^ priorCategoryOrNil
]

{ #category : #accessing }
MethodAddition >> priorCategoryOrNil: anObject [
	priorCategoryOrNil := anObject
]

{ #category : #operations }
MethodAddition >> writeSourceToLog [

	logSource ifTrue: [
		myClass
			logMethodSource: text
			forMethod: compiledMethod
			inProtocol: (myClass ensureProtocol: category)
			withStamp: changeStamp ]
]
