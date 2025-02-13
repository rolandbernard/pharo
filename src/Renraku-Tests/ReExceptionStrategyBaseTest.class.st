"
A super test case that (re)stores  the setting value
"
Class {
	#name : #ReExceptionStrategyBaseTest,
	#superclass : #TestCase,
	#instVars : [
		'currentStrategy'
	],
	#category : #'Renraku-Tests'
}

{ #category : #testing }
ReExceptionStrategyBaseTest class >> isAbstract [

	^ self = ReExceptionStrategyBaseTest
]

{ #category : #helpers }
ReExceptionStrategyBaseTest >> errorMessage [

	^ 'test message'
]

{ #category : #running }
ReExceptionStrategyBaseTest >> setUp [
	super setUp.
	currentStrategy := ReExceptionStrategy current
]

{ #category : #running }
ReExceptionStrategyBaseTest >> tearDown [

	ReExceptionStrategy current: currentStrategy.
	super tearDown
]
