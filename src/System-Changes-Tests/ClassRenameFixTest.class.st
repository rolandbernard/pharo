Class {
	#name : #ClassRenameFixTest,
	#superclass : #AbstractEnvironmentTestCase,
	#category : #'System-Changes-Tests-Base'
}

{ #category : #accessing }
ClassRenameFixTest >> newClassName [

	^ #ClassRenameMockClass2
]

{ #category : #helpers }
ClassRenameFixTest >> packageName [

	^ 'ClassRenameFix-GeneradClass'
]

{ #category : #running }
ClassRenameFixTest >> setUp [

	super setUp.
	SystemAnnouncer uniqueInstance weak when: ClassRenamed send: #verifyRenameEvent: to: self
]

{ #category : #running }
ClassRenameFixTest >> tearDown [

	SystemAnnouncer uniqueInstance unsubscribe: self.
	(self packageName asPackageIfAbsent: [ nil ]) ifNotNil: [ :package | package removeFromSystem ].
	super tearDown
]

{ #category : #tests }
ClassRenameFixTest >> testRenameClassUsingClass [

	| createdClass foundClasses |
	createdClass := self class classInstaller make: [ :aBuilder |
		                aBuilder
			                name: #ClassRenameMockClass1;
			                package: self packageName ].

	createdClass rename: self newClassName.
	self assert: (testingEnvironment classNamed: #ClassRenameMockClass1) isNil.
	self assert: (testingEnvironment classNamed: self newClassName) isNotNil.
	foundClasses := testingEnvironment organization listAtCategoryNamed: self packageName.

	self assert: (foundClasses includes: self newClassName).
	self assert: createdClass name equals: self newClassName
]

{ #category : #helpers }
ClassRenameFixTest >> verifyRenameEvent: aRenamedEvent [

	| renamedClass |
	renamedClass := aRenamedEvent classRenamed.
	self assert: (testingEnvironment classNamed: self newClassName) name equals: self newClassName.
	self assert: renamedClass name equals: self newClassName
]
