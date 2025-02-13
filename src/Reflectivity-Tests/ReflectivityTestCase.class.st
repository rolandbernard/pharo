Class {
	#name : #ReflectivityTestCase,
	#superclass : #AbstractEnvironmentTestCase,
	#category : #'Reflectivity-Tests-Base'
}

{ #category : #running }
ReflectivityTestCase >> tearDown [
	self class package methods do: [ :m |
		m hasMetaLinks ifTrue: [
			m recompile.
			self fail: 'Leaked metalinks' ] ].
	super tearDown
]
