"
I model Globals. I am stored as a binding in the Smalltalk globals.

The compiler forwards bytecode generation to me for accessing the variable.
"
Class {
	#name : #GlobalVariable,
	#superclass : #LiteralVariable,
	#category : #'Kernel-Variables'
}

{ #category : #visiting }
GlobalVariable >> acceptVisitor: aProgramNodeVisitor node: aNode [
	^ aProgramNodeVisitor visitGlobalVariableNode: aNode
]

{ #category : #queries }
GlobalVariable >> definingClass [
	"The class defining the variable. For Globals, return nil"
	^nil
]

{ #category : #'code generation' }
GlobalVariable >> emitStore: methodBuilder [

	methodBuilder storeIntoLiteralVariable: self
]

{ #category : #'code generation' }
GlobalVariable >> emitValue: methodBuilder [
	methodBuilder pushLiteralVariable: self
]

{ #category : #testing }
GlobalVariable >> isDeprecated [

	^ (self propertyAt: #isDeprecated ifAbsent: [ false ]) or: [ self value isClass and: [ self value isDeprecated ] ]
]

{ #category : #accessing }
GlobalVariable >> isDeprecated: aBoolean [

	self propertyAt: #isDeprecated put: aBoolean
]

{ #category : #testing }
GlobalVariable >> isGlobalVariable [

	^ true
]

{ #category : #accessing }
GlobalVariable >> scope [
	"The scope of Globals is Smalltalk globals"
	^ Smalltalk globals
]
