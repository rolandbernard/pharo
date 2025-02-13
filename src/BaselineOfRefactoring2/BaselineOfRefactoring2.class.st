Class {
	#name : #BaselineOfRefactoring2,
	#superclass : #BaselineOf,
	#category : #BaselineOfRefactoring2
}

{ #category : #baselines }
BaselineOfRefactoring2 >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec 
			package: 'Refactoring-Changes';
			package: 'Refactoring2-Transformations';
			package: 'Refactoring2-Transformations-Tests'.
		spec 
			group: 'Core' with: #('Refactoring-Changes' 'Refactoring2-Transformations');
			group: 'Tests' with: #('Refactoring2-Transformations-Tests');
			group: 'default' with: #('Core' 'Tests') ]
]
