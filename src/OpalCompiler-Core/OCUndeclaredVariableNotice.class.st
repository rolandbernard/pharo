Class {
	#name : #OCUndeclaredVariableNotice,
	#superclass : #RBErrorNotice,
	#category : #'OpalCompiler-Core-FrontEnd'
}

{ #category : #testing }
OCUndeclaredVariableNotice >> isUndeclaredNotice [

	^ true
]

{ #category : #correcting }
OCUndeclaredVariableNotice >> reparator [

	^ OCCodeReparator new node: self node
]
