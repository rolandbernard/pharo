"
I'm a type to handle structures. 
"
Class {
	#name : #FFIExternalStructureType,
	#superclass : #FFIExternalType,
	#instVars : [
		'objectClass'
	],
	#category : #'UnifiedFFI-Types'
}

{ #category : #private }
FFIExternalStructureType class >> naturalPointerArity [
	^ 1
]

{ #category : #'instance creation' }
FFIExternalStructureType class >> objectClass: aClass [
	^ self basicNew
		initializeObjectClass: aClass;
		yourself
]

{ #category : #private }
FFIExternalStructureType >> basicHandle: aHandle at: index [

	^ self objectClass fromHandle: (aHandle referenceStructAt: index length: self externalTypeSize)
]

{ #category : #private }
FFIExternalStructureType >> basicHandle: aHandle at: index put: value [
	^ LibC memCopy: value getHandle to: aHandle + (index - 1) size: self externalTypeSize
]

{ #category : #callbacks }
FFIExternalStructureType >> callbackReturnOn: callbackContext for: anObject [

	^ self error: 'Cannot return an external structure by copy. It is not yet implemented'
]

{ #category : #accessing }
FFIExternalStructureType >> callbackValueFor: anAlien at: index [
	"This is the value for a callback.
	since the callbacks comunicates as Aliens, I receive the struct, but with an Alien
	reference (which does not work for UFFI structires, they needs to be ExternalAddress)"
	self isPointer ifTrue: [ ^ anAlien pointerAt: index ].
	^ self objectClass fromHandle: anAlien asExternalAddress
]

{ #category : #'stack parameter classification' }
FFIExternalStructureType >> emitFlatStructureLayoutFieldInto: flatStructureLayout [
	objectClass emitFlatStructureLayoutFieldInto: flatStructureLayout
]

{ #category : #accessing }
FFIExternalStructureType >> externalType [
	^ ExternalType structTypeNamed: self objectClass name
]

{ #category : #accessing }
FFIExternalStructureType >> externalTypeAlignment [
	^ self objectClass structureAlignment
]

{ #category : #accessing }
FFIExternalStructureType >> externalTypeSize [
	^ self objectClass structureSize
]

{ #category : #extracting }
FFIExternalStructureType >> extractFromCallbackOn: aCallbackArgumentReader [

	aCallbackArgumentReader extractStructType: self
]

{ #category : #initialization }
FFIExternalStructureType >> initializeObjectClass: aClass [
	objectClass := aClass.
	self initialize
]

{ #category : #testing }
FFIExternalStructureType >> isExternalStructure [

	^ true
]

{ #category : #accessing }
FFIExternalStructureType >> objectClass [
	^ objectClass
]

{ #category : #'emitting code' }
FFIExternalStructureType >> offsetReadFieldAt: offsetVariableName [
	"Return a string defining the accessor to an entity of the receiver type starting at the given byte offset. "
	self isPointer ifTrue: [ ^ super offsetReadFieldAt: offsetVariableName ].
	^ self offsetReadReferenceAt: offsetVariableName
]

{ #category : #'emitting code' }
FFIExternalStructureType >> offsetReadReferenceAt: offsetVariableName [
	^ '^ {1} fromHandle: (handle referenceStructAt: {2} length: {1} byteSize)'
		format: { self objectClass name. offsetVariableName }
]

{ #category : #initialization }
FFIExternalStructureType >> prepareAsSelfFromCalloutDeclaration [
	"self starts with pointer arity 1 (regardless how is declared later)"
	self pointerArity: 1
]

{ #category : #'emitting code' }
FFIExternalStructureType >> readFieldAt: byteOffset [
	"Return a string defining the accessor to an entity of the receiver type starting at the given byte offset. "
	self isPointer ifTrue: [ ^ super readFieldAt: byteOffset ].
	^ self readReferenceAt: byteOffset
]

{ #category : #'emitting code' }
FFIExternalStructureType >> readReferenceAt: byteOffset [
	^ '^ {1} fromHandle: (handle referenceStructAt: {2} length: {1} byteSize)'
		format: {
			self objectClass name.
			byteOffset }
]

{ #category : #'stack parameter classification' }
FFIExternalStructureType >> stackValueParameterClass [
	^ #structure
]
