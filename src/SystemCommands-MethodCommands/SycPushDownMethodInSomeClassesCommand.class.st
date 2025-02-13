"
I am a command that pushes down methods in some classes.

I am responsible for delegating execution to `RBPushDownMethodInSomeClassesDriver`.
"
Class {
	#name : #SycPushDownMethodInSomeClassesCommand,
	#superclass : #SysRefactoringMethodCommand,
	#instVars : [
		'refactoringScopes'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #converting }
SycPushDownMethodInSomeClassesCommand >> asRefactorings [

	self shouldNotImplement
]

{ #category : #accessing }
SycPushDownMethodInSomeClassesCommand >> defaultMenuIconName [
	^ #down
]

{ #category : #accessing }
SycPushDownMethodInSomeClassesCommand >> defaultMenuItemName [
	^'Push down in some classes'
]

{ #category : #execution }
SycPushDownMethodInSomeClassesCommand >> executeRefactorings [

	(RBPushDownMethodInSomeClassesDriver
		model: model
		scopes: refactoringScopes
		pushDown: methods) execute
]

{ #category : #testing }
SycPushDownMethodInSomeClassesCommand >> isComplexRefactoring [ 

	^ false
]

{ #category : #execution }
SycPushDownMethodInSomeClassesCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	refactoringScopes := aToolContext refactoringScopes

]
