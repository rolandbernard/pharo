"
I'm a finalization registry.
My main responsibility is to know objects that are of interest for finalization.
That is, objects whose (garbage) collection is of interest and require to be notified.

I associate each object of interest to a finalizer.
When the object of interest is a candidate of garbage collection, I notify the finalizer with the #finalize message and remove the entry from the registry.
If no finalizer is specified, an object is its own finalizer.

For example, finalization is useful when managing external resource such as files.
When a file object is garbage collected, we want to be sure that it's corresponding OS file descriptor is closed.
Otherwise, the file descriptor would remain open and prevent the system to function correctly.
In this case, the file object can be registered with a finalizer that sends it the #close message when its collection is notified.

It's important that applications do not allow the collection of the registry.
Otherwise, if the registry is garbage collected, no finalization notification will arrive to the registered finalizers.

In case of an error during finalization, errors are handled by a configurable error handler implementing `#handlerErrorsDuring:`.
I'm my own default error handler, implementing `#handlerErrorsDuring:` with an `#on:fork:`.
The error handler can be overridden for purposes such as testing.

# Example of usage

```
registry := FinalizationRegistry new.

""Object is its own finalizer""
registry add: objectOfInterest.

""Object has another finalizer""
registry add: objectOfInterest finalizer: aFinalizer.
```

The registry provides also a system wide visible registry with the #default method, working as a singleton.
```
FinalizationRegistry default
```

# Implementation Details

I am implemented internally as a collection of ephemerons, instances of `FinalizationRegistryEntry`, which are hidden to the user.
Each `FinalizationRegistryEntry` will have the object of interest as key, the finalizer as value, and a back pointer its container (myself).
When the GC detects an object of interest is going to be collected, the `FinalizationRegistryEntry` is sent the message #mourn, and it delegates finalization in myself.
I procceed to send #finalize to the finalizer, and remove the entry from myself.
"
Class {
	#name : #FinalizationRegistry,
	#superclass : #Object,
	#instVars : [
		'ephemeronCollection',
		'semaphore',
		'errorHandler'
	],
	#classVars : [
		'Default'
	],
	#category : #'System-Finalization-Registry'
}

{ #category : #accessing }
FinalizationRegistry class >> default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : #adding }
FinalizationRegistry >> add: anObject [

	^ self add: anObject finalizer: anObject finalizer
]

{ #category : #adding }
FinalizationRegistry >> add: anObject executor: finalizer [

	self
		deprecated: 'Please use #add:finalizer: instead'
		transformWith: '`@receiver add: `@object executor: `@executor'
			-> '`@receiver add: `@object finalizer: `@executor'.
	^ self add: anObject finalizer: finalizer
]

{ #category : #adding }
FinalizationRegistry >> add: anObject finalizer: finalizer [

	self protected: [ 
		ephemeronCollection add:
			(FinalizationRegistryEntry key: anObject value: finalizer container: self) ].
	^ anObject
]

{ #category : #finalization }
FinalizationRegistry >> errorHandler [
	
	^ errorHandler ifNil: [ self ]
]

{ #category : #accessing }
FinalizationRegistry >> errorHandler: anErrorHandler [ 
	errorHandler := anErrorHandler
]

{ #category : #finalization }
FinalizationRegistry >> finalizeEphemeron: anEphemeron [

	"Finalize the ephemeron finalizer and remove it from myself.
	Avoid errors during the finalization to let the finalization process proceed"
	
	self removeEphemeron: anEphemeron.
	errorHandler handleErrorsDuring: [ 
		anEphemeron value finalize ]
]

{ #category : #'private - synchronization' }
FinalizationRegistry >> handleErrorsDuring: aBlock [

	aBlock	 on: Error fork: [ :e | e pass ]
]

{ #category : #testing }
FinalizationRegistry >> includes: anObject [

    ^ ephemeronCollection anySatisfy: [ :entry | entry key == anObject ]
]

{ #category : #initialization }
FinalizationRegistry >> initialize [

	super initialize.
	ephemeronCollection := IdentitySet new.
	semaphore := Semaphore forMutualExclusion.
	errorHandler := self.
]

{ #category : #testing }
FinalizationRegistry >> isEmpty [
	
	^ ephemeronCollection isEmpty
]

{ #category : #adding }
FinalizationRegistry >> keys [

	^ ephemeronCollection collect: [ :e | e key ]
]

{ #category : #copying }
FinalizationRegistry >> postCopy [
	"should we prohibit any attempts to copy receiver?"
	self protected: [
		semaphore := Semaphore forMutualExclusion.
		ephemeronCollection := ephemeronCollection copy
	]
]

{ #category : #'private - synchronization' }
FinalizationRegistry >> protected: aBlock [
	"Execute aBlock protected by the accessLock"

	^ semaphore
		critical: aBlock
		ifError: [ :err | err signal ]
]

{ #category : #adding }
FinalizationRegistry >> remove: anEphemeron ifAbsent: aBlock [

	^ self protected: [ ephemeronCollection remove: anEphemeron ifAbsent: aBlock ]
]

{ #category : #adding }
FinalizationRegistry >> removeEphemeron: anEphemeron [

	self protected: [ ephemeronCollection remove: anEphemeron ]
]

{ #category : #accessing }
FinalizationRegistry >> size [

	^ ephemeronCollection size
]
