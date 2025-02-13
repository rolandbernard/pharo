"
I am a styler for tests that will add instances of SHRBTextFlagAttributes to the nodes instead of the normal style to ease the testing.
"
Class {
	#name : #SHRBMockTextStyler,
	#superclass : #SHRBTextStyler,
	#classVars : [
		'PatternStyleDictionary'
	],
	#category : #'Shout-Tests-Styling'
}

{ #category : #styles }
SHRBMockTextStyler class >> patternStyleDictionary [

	^ PatternStyleDictionary ifNil: [
		  PatternStyleDictionary := self patternStyleTable
			                            collect: [ :x | x first -> x second ]
			                            as: Dictionary ]
]

{ #category : #styles }
SHRBMockTextStyler class >> patternStyleTable [
	"Associate each style name to a single character (not injective) for easy testing"

	^ #(
			(default 								$ )
			(invalid 								$X)

			(comment 								$")

			(character 							$$)
			(number 								$n)
			(symbol 								$#)
			(string 								$')

			(selector 							$s)

			(#self 								$k)
			(#super 								$k)
			(#true 								$k)
			(#false 								$k)
			(#nil 									$k)
			(#thisContext 						$k)
			(#return 								$^)
			(patternArg 							$A)
			(blockPatternArg 					$B)
			(blockArg 							$b)
			(argument 							$a)
			(blockTempVar 						$t)
			(blockPatternTempVar 				$T)
			(instVar 								$i)

			(tempVar 								$t)
			(patternTempVar 					$T)
			(poolConstant 						$v)
			(classVar 							$c)
			(globalVar 							$g)

			(incompleteIdentifier 			$i)
			(incompleteSelector 				$i)

			(undefinedIdentifier 				$u)
			(undefinedSelector 				$u)

			(patternSelector 					$p)
			(blockArgColon 						$:)
			(parenthesis 						$0)
			(parenthesis1 						$1)
			(parenthesis2 						$2)
			(parenthesis3 						$3)
			(parenthesis4 						$4)
			(parenthesis5 						$5)
			(parenthesis6 						$6)
			(parenthesis7 						$7)
			(block 								$0)
			(block1 								$1)
			(block2 								$2)
			(block3 								$3)
			(block4 								$4)
			(block5 								$5)
			(block6 								$6)
			(block7 								$7)
			(brace 								$0)
			(brace1 								$1)
			(brace2 								$2)
			(brace3 								$3)
			(brace4 								$4)
			(brace5 								$5)
			(brace6 								$6)
			(brace7 								$7)
			(cascadeSeparator 					$;)
			(statementSeparator 				$.)
			(methodTempBar 						$|)
			(blockTempBar 						$|)
			(blockArgsBar 						$|)

			(pragma 								$<))
]

{ #category : #private }
SHRBMockTextStyler >> attributesFor: aSymbol [

	^ { (SHRBTextFlagAttribute named: aSymbol) }
]
