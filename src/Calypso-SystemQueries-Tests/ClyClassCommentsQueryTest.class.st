"
I am a test case which describes the ClyClassCommentQuery.
It should find all classes which comments includes the given string.
In tests I use following substring:
	it should be in the comment of this class to test class comment query
which should be found
"
Class {
	#name : #ClyClassCommentsQueryTest,
	#superclass : #ClyClassQueryTest,
	#category : #'Calypso-SystemQueries-Tests-Queries'
}

{ #category : #running }
ClyClassCommentsQueryTest >> createQuery [
	^ ClyClassCommentsQuery
		withString: self expectedClassCommentSubstring
		from: (ClyPackageScope of: Object package in: environment)
]

{ #category : #running }
ClyClassCommentsQueryTest >> expectedClassCommentSubstring [
	^'it should be in the comment of this class to test class comment query'
]

{ #category : #tests }
ClyClassCommentsQueryTest >> testCheckIfEmpty [
	query scope: (ClyClassScope of: self class in: environment).
	self deny: query checkEmptyResult.

	query scope: (ClyClassScope of: self class superclass in: environment).
	self assert: query checkEmptyResult
]

{ #category : #tests }
ClyClassCommentsQueryTest >> testComparison [
	self assert: (ClyClassCommentsQuery withString: 'test substring') equals: (ClyClassCommentsQuery withString: 'test ' , 'substring').

	self assert: (ClyClassCommentsQuery withString: 'test substring') hash equals: (ClyClassCommentsQuery withString: 'test ' , 'substring') hash.

	self deny: (ClyClassCommentsQuery withString: 'test substring') equals: (ClyClassCommentsQuery withString: 'another substring')
]

{ #category : #tests }
ClyClassCommentsQueryTest >> testFromClassScope [

	self queryFromScope: ClyClassScope ofAll: { self class. self class superclass }.

	self assert: resultItems size equals: 1.

	self assert: resultItems first equals: (ClyClassComment of: self class)
]

{ #category : #tests }
ClyClassCommentsQueryTest >> testThisClassShouldIncludeExpectedComment [

	self assert: (self class comment
		includesSubstring: self expectedClassCommentSubstring caseSensitive: false)
]
