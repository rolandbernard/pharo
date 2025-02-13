Extension { #name : #RBCodeSnippet }

{ #category : #'*Shout-Tests' }
RBCodeSnippet >> mockedStyledText [

	| text |
	text := self source asText.
	SHRBMockTextStyler new style: text ast: self doSemanticAnalysis.

	^ (1 to: text size)
		  collect: [ :index |
			  SHRBMockTextStyler patternStyleDictionary at:
				  (text attributesAt: index) anyOne name ]
		  as: String
]

{ #category : #'*Shout-Tests' }
RBCodeSnippet >> styledText [

	| text |
	text := self source asText.
	SHRBTextStyler new style: text ast: self doSemanticAnalysis.
	^ text
]
