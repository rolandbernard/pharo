Extension { #name : #RPackage }

{ #category : #'*CodeExport' }
RPackage >> fileOut [

	| internalStream |
	internalStream := (String new: 1000) writeStream.

	self classTags do: [ :each | self systemOrganization fileOutCategory: each categoryName on: internalStream ].

	classExtensionSelectors keysAndValuesDo: [ :className :selectors |
		selectors do: [ :selector |
			| extendedClass |
			extendedClass := self class environment classNamed: className.
			extendedClass fileOutMethod: selector on: internalStream ] ].

	metaclassExtensionSelectors keysAndValuesDo: [ :className :selectors |
		selectors do: [ :selector |
			| extendedClass |
			extendedClass := self class environment classNamed: className.
			extendedClass classSide fileOutMethod: selector on: internalStream ] ].

	^ CodeExporter writeSourceCodeFrom: internalStream baseName: self name isSt: true
]
