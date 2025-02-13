Class {
	#name : #SycRenameArgOrTempCommandTest,
	#superclass : #TestCase,
	#category : #'SystemCommands-MethodCommands-Tests'
}

{ #category : #tests }
SycRenameArgOrTempCommandTest >> testCanExecuteOnArgumentNode [

	| argNode sourceCodeContext |
	"we don't need to set the tools"
	argNode := RBVariableNode new variable: ArgumentVariable new.
	sourceCodeContext := ClySourceCodeContext for: nil selectedNode: argNode.
	self assert: (SycRenameArgOrTempCommand canBeExecutedInContext: sourceCodeContext)
]

{ #category : #tests }
SycRenameArgOrTempCommandTest >> testCanExecuteOnTemporaryNode [

	| sourceCodeContext tempNode |
	"we don't need to set the tools"
	tempNode := RBVariableNode new variable: TemporaryVariable new.
	sourceCodeContext := ClySourceCodeContext for: nil selectedNode: tempNode.
	self assert: (SycRenameArgOrTempCommand canBeExecutedInContext: sourceCodeContext)
]
