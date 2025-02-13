Extension { #name : #RBMethodNode }

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> bcToASTCache [
	^ bcToASTCache ifNil: [ bcToASTCache := OCBytecodeToASTCache generateForNode: self ]
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> compiledMethod [
	"Retrieve the associated CompiledMethod (cached version).
	If no CompiledMethod was generated, nil is returned.

	When the AST is recompiled (see `generateMethod`), the cache is updated.
	However, the cache is not reset if the AST is modified."

	^ self propertyAt: #compiledMethod ifAbsent: [ nil ]
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> compiledMethod: aCompiledMethod [

	self propertyAt: #compiledMethod put: aCompiledMethod
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> compiler [
	"Return a compiler configured with self as the AST"

	| class |
	class := self methodClass ifNil: [ nil class ].
	^ class compiler ast: self
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> doSemanticAnalysis [

	self compiler doSemanticAnalysis
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> doSemanticAnalysisIn: behavior [

	behavior compiler
		ast: self
		doSemanticAnalysis
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> ensureCachedArgumentNames [
	^self methodPropertyAt: #argumentNames put: self argumentNames
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode class >> errorMethodNode: selector errorMessage: messageText [
	| message |
	message := RBMessageNode
		receiver: RBVariableNode selfNode
		selector: #error:
		arguments: {RBLiteralNode value: messageText}.
	^ self
		selector: selector
		arguments: ((1 to: selector numArgs) collect: [ :i | RBVariableNode named: 't' , i asString ])
		body: (RBSequenceNode statements: {message})
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> firstPcForNode: aNode [

	^ self bcToASTCache firstBcOffsetForNode: aNode
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> generate [

	self deprecated: 'Use generateMethod. Beware that there are limitations so read the comments.' transformWith: '`@receiver generate' -> '`@receiver generateMethod'.

	^ self generateMethod
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> generate: trailer [
	"if the bytecode is regenerated, we need to reset the cache"
	bcToASTCache := nil.
	^ self generateIR compiledMethodWith: trailer
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> generateIR [
	"Generate an IRMethod. See `ir` for the chached version."

	| ir |
	scope ifNil: [self doSemanticAnalysis].

	self pragmaNamed: #opalBytecodeMethod ifPresent: [ :pragma | | copy |
		"We need to copy the AST node to avoid the recursive `generateIR` call from re-entering this condition"
		copy := self copy.
		copy removePragmaNamed: pragma selector.
		ir := copy generateIR compiledMethod valueWithReceiver: nil arguments: (Array new: copy arguments size).
		ir sourceNode: self.
		^ ir
	].

 	ir := (self compilationContext astTranslatorClass new
			compilationContext: self compilationContext;
			visitNode: self)
			ir.
	^ ir
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> generateMethod [
	"Generate a CompiledMethod (uncached, see `compiledMethod` for the cached version).
	Important: the current state of the AST is not cheched, and specific controls or steps done
	by OpalCompiler in a full compilation chain might be missing.
	So use this method if you know what you are doing."

	| cm |
	cm := self generate: self compilationContext compiledMethodTrailer.
	self compiledMethod: cm.
	^ cm
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> ir [
	"Retrieve or generate an IRMethod (cached version)"

	^ self propertyAt: #ir ifAbsentPut: [ self generateIR ]
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> ir: aIRMethodNode [

	^ self propertyAt: #ir put: aIRMethodNode
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> irInstruction [
	^ self ir
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> lastPcForNode: aNode [

	^ self bcToASTCache lastBcOffsetForNode: aNode
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> methodProperties [
	^self propertyAt: #methodProperties ifAbsent: nil
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> methodPropertyAt: aKey [

	^self methodPropertyAt: aKey ifAbsent: [ self error: 'Property not found' ]
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> methodPropertyAt: aKey ifAbsent: absentBlock [
	| existingProperties |
	existingProperties := self propertyAt: #methodProperties ifAbsent: absentBlock.

	^existingProperties propertyAt: aKey ifAbsent: absentBlock
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> methodPropertyAt: aKey put: anObject [
	| existingProperties newProperties |
	existingProperties := self propertyAt: #methodProperties ifAbsentPut: [
		AdditionalMethodState forSelector: self selector].

	existingProperties at: aKey ifPresent: [:existingValue |
		existingProperties at: aKey put: anObject.
		^self].

	newProperties := existingProperties copyWith: aKey -> anObject.
	self propertyAt: #methodProperties put: newProperties
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> owningScope [
	^ self scope
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> pcsForNode: aNode [

	^ self bcToASTCache pcsForNode: aNode
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> primitiveFromPragma [
	^ pragmas
		detect: [ :each | each isPrimitive ]
		ifFound: [ :aPragmaPrimitive | aPragmaPrimitive asIRPrimitive ]
		ifNone: [ IRPrimitive null ]
]

{ #category : #'*OpalCompiler-Core' }
RBMethodNode >> sourceNodeForPC: anInteger [
	^ self bcToASTCache nodeForPC: anInteger
]
