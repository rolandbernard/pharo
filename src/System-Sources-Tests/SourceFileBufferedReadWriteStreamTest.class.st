Class {
	#name : #SourceFileBufferedReadWriteStreamTest,
	#superclass : #TestCase,
	#instVars : [
		'classFactory'
	],
	#category : #'System-Sources-Tests'
}

{ #category : #running }
SourceFileBufferedReadWriteStreamTest >> setUp [
	super setUp.

	classFactory := ClassFactoryForTestCase new
]

{ #category : #running }
SourceFileBufferedReadWriteStreamTest >> tearDown [
	classFactory cleanUp.

	super tearDown
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testBuffering [
	| stream |
	stream := SourceFileBufferedReadWriteStream on: '01234567890123456789' readStream.
	stream sizeBuffer: 8.
	self deny: stream atEnd.
	self assert: (stream next: 10) equals: '0123456789'.
	self deny: stream atEnd.
	self assert: (stream next: 10) equals: '0123456789'.
	self assert: stream atEnd
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testEnsureWrittenPositionFlushesCompleteChunk [
	"This test covers https://github.com/pharo-project/pharo/issues/6063.
	When flushing is deferred but the internal write buffer overlows during
	compilation, part of a chunk may have been written to disk while the rest
	of the chunk is still in the buffer only. #ensureWrittenPosition used to
	check only whether the start position of the chunk had been written and
	a read stream would then read the complete chunk from disk. That chunk would
	then be incomplete of course.

	See #testEnsureWrittenPositionFlushesCompleteChunkDuringCompilation for a complete
	example of what happens when loading code."

	| stringStream stream |
	stringStream := ReadWriteStream with: ''.
	stream := SourceFileBufferedReadWriteStream on: stringStream.
	stream sizeBuffer: 15.

	stream nextPutAll: 'before flush - after flush'.
	self assert: stringStream contents equals: 'before flush - '.

	"this must force a flush to ensure that we can read a complete chunk"
	stream ensureWrittenPosition: 10.
	self assert: stringStream contents equals: 'before flush - after flush'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testEnsureWrittenPositionFlushesCompleteChunkDuringCompilation [
	"This test covers https://github.com/pharo-project/pharo/issues/6063.
	When flushing is deferred but the internal write buffer overlows during
	compilation, part of a chunk may have been written to disk while the rest
	of the chunk is still in the buffer only. #ensureWrittenPosition used to
	check only whether the start position of the chunk had been written and
	a read stream would then read the complete chunk from disk. That chunk would
	then be incomplete of course."
	| trait |
	trait := classFactory newTrait.
	"force recompilation"
	trait addInstVarNamed: 'var'.
	classFactory
		newSubclassOf: classFactory defaultSuperclass
		using: trait.

	"Need to know the length of the author name"
	Author
		useAuthor: 'a'
		during: [
			| preambleLength |
			"<cr>
			!TraitForTestToBeDeleted1 methodsFor: 'a' stamp: 'a 6/5/2020 14:47'!
			<cr>"
			preambleLength := 2 + trait name size + 13 + 3 + 9 + Author changeStamp size + 3.

			SourceFiles changesWriteStreamDo: [ :sourceFile |
				| stream |
				[ "We want the internal buffer to be flushed after
				writing the first two characters of the method selector"
				stream := ((sourceFile instVarNamed: 'stream') instVarNamed: 'writeStream') wrappedStream.
				stream sizeBuffer: preambleLength + 2.

				"This happens in MCPackageLoader>>basicLoad:"
				SourceFiles deferFlushDuring: [
					"Compiling a method in a trait with users will lead to
					the source of the compiled method being read again for
					compilation in the using class which would read an incomplete
					chunk and lead to an error."

					"It's difficult to align the buffer properly to the file size, as
					we'd need to set the new buffer size first and then check whether
					the buffer is aligned and then adjust the buffer size again. Instead,
					we just compile enough methods so that we know we'll eventually end up
					in a situation were the buffer is flushed and we end up with a partial
					chunk in memory"
					1
						to: 10
						do: [ :index |
							"Need to know the length of the category name"
							trait
								compile: 'aMethod', index asString
								classified: 'a' ] ] ] ensure: [
									stream sizeBuffer: stream defaultBufferSize ] ] ]
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testNextPutAllStartingAt [
	| stringStream |

	stringStream := ReadWriteStream with: String new.

	SourceFileBufferedReadWriteStream on: stringStream do: [ : bufferedStream |
		bufferedStream sizeBuffer: 8.
		bufferedStream next: 5 putAll: '--012345--' startingAt: 3.
		bufferedStream next: 5 putAll: '0123456789XX' startingAt: 6.
		bufferedStream next: 5 putAll: '--012345--' startingAt: 3.
		bufferedStream next: 5 putAll: '0123456789XX' startingAt: 6.] .

	self assert: stringStream contents equals: '01234567890123456789'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testPeek [
	| stream |
	stream := SourceFileBufferedReadWriteStream on: '0123456789' readStream.
	stream sizeBuffer: 8.
	'0123456789' do: [ :each |
		self deny: stream atEnd.
		self assert: stream peek equals: each.
		self assert: stream next equals: each ].
	self assert: stream atEnd.
	self assert: stream peek isNil.
	self assert: stream next isNil
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testReadInto [
	| stream buffer count |
	stream := SourceFileBufferedReadWriteStream on: '0123456789' readStream.
	stream sizeBuffer: 8.
	buffer := String new: 6 withAll: Character space.
	stream skip: 1.
	stream readInto: buffer startingAt: 4 count: 3.
	self assert: buffer equals: '   123'.
	stream readInto: buffer startingAt: 1 count: 3.
	self assert: buffer equals: '456123'.
	count := stream readInto: buffer startingAt: 1 count: 100.
	self assert: count equals: 3.
	self assert: buffer equals: '789123'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testReadIntoLarger [
	| stream buffer count |
	stream := SourceFileBufferedReadWriteStream on: '0123456789' readStream.
	stream sizeBuffer: 4.
	buffer := String new: 10.
	count := stream readInto: buffer startingAt: 1 count: 10.
	self assert: count equals: 10.
	self assert: buffer equals: '0123456789'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testReadThenWrite [
	| stream stringStream |

	((SystemVersion current major < 7) or: [ SystemVersion current build < 690 ])
		ifTrue: [ ^ self skip ].

	stringStream := ReadWriteStream with: '0123456789' copy.
	stringStream reset.
	stream := SourceFileBufferedReadWriteStream on: stringStream.
	stream sizeBuffer: 8.

	stream next: 4.
	self assert: stream position equals: 4.

	stream nextPutAll: 'ABCD'.
	self assert: stream position equals: 8.

	self assert: stream peek equals: $8.
	self assert: stream upToEnd equals: '89'.
	self assert: stream atEnd.

	self assert: stringStream contents equals: '0123ABCD89'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testReadUpTo [
	| stream |
	stream := SourceFileBufferedReadWriteStream on: '0123456789' readStream.
	stream sizeBuffer: 8.
	self assert: (stream upTo: $5) equals: '01234'.
	self assert: stream upToEnd equals: '6789'.
	self assert: stream atEnd
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testReadUpToEnd [
	| stream |
	stream := SourceFileBufferedReadWriteStream on: '0123456789' readStream.
	stream sizeBuffer: 4.
	stream next: 2.
	self assert: stream upToEnd equals: '23456789'.
	self assert: stream atEnd
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testSetAtEnd [

	| stream originalStream|

	stream := SourceFileBufferedReadWriteStream on: (originalStream := ReadWriteStream with: '0123456789' copy).
	originalStream reset.

	stream setToEnd.

	stream nextPut: $A.
	stream flush.

	self assert: originalStream contents equals: '0123456789A'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testWriteThenRead [
	| stream stringStream |

	((SystemVersion current major < 7) or: [ SystemVersion current build < 690 ])
		ifTrue: [ ^ self skip ].

	stringStream := ReadWriteStream with: '0123456789' copy.
	stringStream reset.
	stream := SourceFileBufferedReadWriteStream on: stringStream.
	stream sizeBuffer: 8.

	stream nextPutAll: 'ABCD'.

	self assert: stream peek equals: $4.
	self assert: stream position equals: 4.
	self assert: stream upToEnd equals: '456789'.
	self assert: stream position equals: 10.
	self assert: stream atEnd.

	self assert: stringStream contents equals: 'ABCD456789'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testWriting [
	| stringStream bufferedStream |
	stringStream := ReadWriteStream with: String new.

	bufferedStream := SourceFileBufferedReadWriteStream on: stringStream.
	0 to: 9 do: [ :each | bufferedStream nextPut: (Character digitValue: each) ].
	bufferedStream flush.

	self assert: stringStream contents equals: '0123456789'
]

{ #category : #tests }
SourceFileBufferedReadWriteStreamTest >> testWritingOverflow [
	| stringStream bufferedStream |

	stringStream := ReadWriteStream with: String new.
	bufferedStream := SourceFileBufferedReadWriteStream on: stringStream.
	bufferedStream sizeBuffer: 8.
	0 to: 9 do: [ :each | bufferedStream nextPut: (Character digitValue: each) ].
	bufferedStream nextPutAll: '0123'; nextPutAll: '4567'; nextPutAll: '89'.
	bufferedStream nextPutAll: '0123456789'; nextPutAll: '0123456789'.
	bufferedStream flush.

	self assert: stringStream contents equals: '0123456789012345678901234567890123456789'
]
