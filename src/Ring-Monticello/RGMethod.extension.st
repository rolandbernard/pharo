Extension { #name : #RGMethod }

{ #category : #'*Ring-Monticello' }
RGMethod >> asMCDefinition [

	^ MCMethodDefinition
		className: self parent instanceSide name
		classIsMeta: self parent isMeta
		selector: self name
		category: self protocol
		timeStamp: ''
		source: self sourceCode
]
