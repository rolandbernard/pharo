"
This class manages the class comment and a protocol organizer
"
Class {
	#name : #ClassOrganization,
	#superclass : #Object,
	#instVars : [
		'organizedClass',
		'protocols'
	],
	#category : #'Kernel-Protocols'
}

{ #category : #'instance creation' }
ClassOrganization class >> forClass: aClass [
	^ self basicNew
		initializeClass: aClass;
		yourself
]

{ #category : #accessing }
ClassOrganization >> addProtocol: aProtocol [

	| oldProtocols protocol |
	
	(self hasProtocol: aProtocol) ifTrue: [
		^ self protocolNamed: (aProtocol isString ifTrue: [ aProtocol ] ifFalse: [ aProtocol name ]) ].

	protocol := aProtocol isString ifTrue: [ Protocol name: aProtocol ] ifFalse: [ aProtocol ].

	oldProtocols := self protocolNames copy.

	protocols := protocols copyWith: protocol.

	SystemAnnouncer announce: (ProtocolAdded in: self organizedClass protocol: protocol).
	self notifyOfChangedProtocolNamesFrom: oldProtocols to: self protocolNames.
	^ protocol
]

{ #category : #'backward compatibility' }
ClassOrganization >> allMethodSelectors [

	^ self protocols flatCollect: [ :p | p methodSelectors ]
]

{ #category : #classification }
ClassOrganization >> classify: selector under: aProtocol [

	| oldProtocolName forceNotify oldProtocol protocolName |
	"The next section deserve more cleanings.
	
	Some code was added to make it possible to classify giving a real protocol.
	Here to keep a small change, I just ask the name to the protocol and use that for compatibility.
	Later, I plan to update this code once more to directly use the actual object I'm givin instead of doing this little trick."
	protocolName := aProtocol
		                ifNil: [ Protocol unclassified ]
		                ifNotNil: [
			                aProtocol isString
				                ifTrue: [ aProtocol ]
				                ifFalse: [ aProtocol name ] ].
	forceNotify := (self includesSelector: selector) not.
	oldProtocolName := self protocolNameOfElement: selector.
	(forceNotify or: [ oldProtocolName ~= protocolName or: [ protocolName ~= Protocol unclassified ] ]) ifFalse: [ ^ self ].
	oldProtocol := self protocolOfSelector: selector.

	self silentlyClassify: selector under: protocolName.
	oldProtocolName ifNotNil: [ self notifyOfChangedSelector: selector from: oldProtocolName to: protocolName ]
]

{ #category : #cleanup }
ClassOrganization >> cleanUpProtocolsForClass: aClass [
	"remove all entries that have no methods"

	self allMethodSelectors do: [ :each | (aClass includesSelector: each) ifFalse: [ self removeElement: each ] ]
]

{ #category : #copying }
ClassOrganization >> copyFrom: otherOrganization [

	protocols := otherOrganization protocols copy
]

{ #category : #accessing }
ClassOrganization >> ensureProtocol: aProtocol [
	"I can take a Protocol or a protocol name as paramater.
	
	If my parameter is a name, I'll return a protocol associated with it. A new one if needed.
	If my parameter is a Protocol, I'll ensure that it comes from me, else I'll throw an error.
	If I receive nil, I return the unclassified protocol"

	aProtocol ifNil: [ ^ self ensureProtocol: Protocol unclassified ].

	aProtocol isString ifFalse: [
		(self protocols includes: aProtocol)
			ifTrue: [ ^ aProtocol ]
			ifFalse: [ self error: 'I received a real protocol but this one is not part of me.' ] ].
	^ self protocolNamed: aProtocol ifAbsent: [ self addProtocol: aProtocol ]
]

{ #category : #accessing }
ClassOrganization >> extensionProtocols [
	^ self protocols select: #isExtensionProtocol
]

{ #category : #testing }
ClassOrganization >> hasProtocol: aProtocol [

	| protocolName |
	protocolName := aProtocol isString ifTrue: [ aProtocol ] ifFalse: [ aProtocol name ].
	^ self protocols anySatisfy: [ :each | each name = protocolName ]
]

{ #category : #testing }
ClassOrganization >> includesSelector: selector [

	^ self protocols anySatisfy: [ :each | each includesSelector: selector ]
]

{ #category : #initialization }
ClassOrganization >> initialize [

	super initialize.
	self reset
]

{ #category : #initialization }
ClassOrganization >> initializeClass: aClass [

	self initialize.
	organizedClass := aClass.
	organizedClass selectors do: [ :each | self classify: each under: Protocol unclassified ]
]

{ #category : #accessing }
ClassOrganization >> methodSelectorsInProtocol: aName [

	^ (self protocolNamed: aName ifAbsent: [ ^ #(  ) ]) methodSelectors asArray
]

{ #category : #private }
ClassOrganization >> moveMethodsFrom: fromProtocolNamed to: toProtocolNamed [

	| fromProtocol toProtocol |
	fromProtocol := self protocolNamed: fromProtocolNamed.
	toProtocol := self protocolNamed: toProtocolNamed.

	toProtocol addAllMethodsFrom: fromProtocol.
	fromProtocol resetMethodSelectors.

	^ toProtocol
]

{ #category : #notifications }
ClassOrganization >> notifyOfChangedProtocolNamesFrom: oldProtocols to: newProtocols [

	oldProtocols ~= newProtocols ifTrue: [ SystemAnnouncer announce: (ClassReorganized class: self organizedClass) ]
]

{ #category : #notifications }
ClassOrganization >> notifyOfChangedSelector: element from: oldProtocolName to: newProtocolName [

	oldProtocolName ~= newProtocolName ifTrue: [ self organizedClass notifyOfRecategorizedSelector: element from: oldProtocolName to: newProtocolName ]
]

{ #category : #accessing }
ClassOrganization >> organizedClass [

	^ organizedClass ifNil: [ self error: 'ClassOrganization should always have an organized class associated.' ]
]

{ #category : #printing }
ClassOrganization >> printOn: aStream [

	super printOn: aStream.

	aStream
		nextPutAll: ' (';
		print: self organizedClass;
		nextPut: $)
]

{ #category : #accessing }
ClassOrganization >> protocolNameOfElement: aSelector [

	^ self protocolNameOfElement: aSelector ifAbsent: nil
]

{ #category : #accessing }
ClassOrganization >> protocolNameOfElement: aSelector ifAbsent: aBlock [

	^ (self protocolOfSelector: aSelector)
		  ifNil: [ (organizedClass includesSelector: aSelector) ifTrue: [ Protocol unclassified ] ifFalse: [ aBlock value ] ]
		  ifNotNil: [ :protocol | protocol name ]
]

{ #category : #accessing }
ClassOrganization >> protocolNamed: aString [

	^ self protocolNamed: aString ifAbsent: [ NotFound signalFor: aString ]
]

{ #category : #accessing }
ClassOrganization >> protocolNamed: aString ifAbsent: aBlock [

	^ self protocols
		  detect: [ :e | e name = aString ]
		  ifNone: aBlock
]

{ #category : #accessing }
ClassOrganization >> protocolNames [

	^ self protocols collect: [ :protocol | protocol name ]
]

{ #category : #protocol }
ClassOrganization >> protocolOfSelector: aSelector [

	^ self protocols
		  detect: [ :each | each includesSelector: aSelector ]
		  ifNone: [ nil ]
]

{ #category : #accessing }
ClassOrganization >> protocols [

	^ protocols
]

{ #category : #removing }
ClassOrganization >> removeElement: aSymbol [

	| oldProtocol |
	oldProtocol := self protocolNameOfElement: aSymbol.
	self protocols
		select: [ :protocol | protocol includesSelector: aSymbol ]
		thenDo: [ :p | p removeMethodSelector: aSymbol ].
	self notifyOfChangedSelector: aSymbol from: oldProtocol to: (self protocolNameOfElement: aSymbol)
]

{ #category : #removing }
ClassOrganization >> removeEmptyProtocols [

	"We copy protocols because it is usually bad to remove elements of a collection while iterating on it"
	self protocols copy do: [ :protocol | self removeProtocolIfEmpty: protocol ]
]

{ #category : #removing }
ClassOrganization >> removeProtocolIfEmpty: aProtocol [
	"I take a protocol or a protocol name and remvoe it if it is empty."

	| protocol oldProtocolNames |
	protocol := aProtocol isString
		            ifTrue: [ self protocolNamed: aProtocol ifAbsent: [ ^ self ] ]
		            ifFalse: [ aProtocol ].

	protocol isEmpty ifFalse: [ ^ self ].

	oldProtocolNames := self protocolNames copy.
	protocols := protocols copyWithout: protocol.
	SystemAnnouncer announce: (ProtocolRemoved in: self organizedClass protocol: protocol).
	self notifyOfChangedProtocolNamesFrom: oldProtocolNames to: self protocolNames
]

{ #category : #removing }
ClassOrganization >> renameProtocolNamed: oldName toBe: newName [

	(oldName isNil or: [ newName isNil ]) ifTrue: [ ^ self ].
	oldName = newName ifTrue: [ ^ self ].

	(self hasProtocol: oldName) ifFalse: [ ^ self ].

	(self hasProtocol: newName)
		ifTrue: [
			self moveMethodsFrom: oldName to: newName.
			self removeProtocolIfEmpty: oldName ]
		ifFalse: [ (self protocolNamed: oldName) name: newName ].

	"Announce the changes in the system"
	self notifyOfChangedProtocolNamesFrom: oldName to: newName.
	SystemAnnouncer announce: (ProtocolRenamed in: self organizedClass from: oldName to: newName).

	"I need to notify also the selector changes, otherwise RPackage will not notice"
	(self protocolNamed: newName) methodSelectors do: [ :each | self notifyOfChangedSelector: each from: oldName to: newName ]
]

{ #category : #initialization }
ClassOrganization >> reset [

	protocols := Array new
]

{ #category : #'backward compatibility' }
ClassOrganization >> setSubject: anObject [

	organizedClass := anObject
]

{ #category : #classification }
ClassOrganization >> silentlyClassify: aSelector under: aProtocol [

	(self protocolOfSelector: aSelector) ifNotNil: [ :oldProtocol |
		oldProtocol removeMethodSelector: aSelector.
		self removeProtocolIfEmpty: oldProtocol ].


	(self ensureProtocol: aProtocol) addMethodSelector: aSelector
]
