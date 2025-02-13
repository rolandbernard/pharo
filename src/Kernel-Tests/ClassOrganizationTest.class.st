"
SUnit tests for class organization
"
Class {
	#name : #ClassOrganizationTest,
	#superclass : #TestCase,
	#instVars : [
		'organization',
		'class'
	],
	#category : #'Kernel-Tests-Protocols'
}

{ #category : #accessing }
ClassOrganizationTest >> organization [
	^ organization
]

{ #category : #running }
ClassOrganizationTest >> runCase [
	SystemAnnouncer uniqueInstance
		suspendAllWhile: [ super runCase ]
]

{ #category : #running }
ClassOrganizationTest >> setUp [

	super setUp.

	class := self class classInstaller make: [ :aBuilder |
		         aBuilder
			         name: #ClassForTests;
			         package: 'ClassOrganizer-Tests' ].

	organization := ClassOrganization forClass: class.
	organization addProtocol: 'empty'.
	organization addProtocol: 'one'.
	organization classify: #one under: 'one'
]

{ #category : #running }
ClassOrganizationTest >> tearDown [
	class removeFromSystem.
	super tearDown
]

{ #category : #tests }
ClassOrganizationTest >> testAddProtocol [

	self organization addProtocol: 'test-protocol'.

	self assert: (self organization hasProtocol: 'test-protocol')
]

{ #category : #tests }
ClassOrganizationTest >> testClassifyUnder [
	"Set the base for the test"

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one ).

	"Lets create a new protocol via classification"
	self organization classify: #king under: #owl.
	self organization classify: #luz under: #owl.

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king #luz ).

	"Move a method"
	self organization classify: #luz under: #one.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz ).

	"Move last method"
	self organization classify: #king under: #two.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #two ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz ).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( #king ).

	"Nothing should change if the new protocol is the same than the old one"
	self organization classify: #king under: #two.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #two ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz ).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( #king )
]

{ #category : #tests }
ClassOrganizationTest >> testClassifyUnderWithNil [
	"Set the base for the test"
	| unclassified|
	unclassified := Protocol unclassified.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one ).

	self organization classify: #king under: nil.

	self assertCollection: self organization protocolNames hasSameElements: { #empty. #one. unclassified }.
	self assertCollection: (self organization protocolNamed: unclassified ) methodSelectors hasSameElements: #( #king ).
	
	self organization classify: #luz under: #owl.

	self assertCollection: self organization protocolNames hasSameElements: { #empty. #one. unclassified . #owl }.
	self assertCollection: (self organization protocolNamed: #owl ) methodSelectors hasSameElements: #( #luz ).
	
	"Now let's test the behavior if we already have a protocol.
	The behavior should change to not change the protocol but this test will ensure that the change is intentional and not a regression."
	self organization classify: #luz under: nil.

	self assertCollection: self organization protocolNames hasSameElements: { #empty. #one. unclassified }.
	self assertCollection: (self organization protocolNamed: unclassified ) methodSelectors hasSameElements: #( #king #luz ).
]

{ #category : #tests }
ClassOrganizationTest >> testClassifyUnderWithProtocol [
	"Set the base for the test"

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one ).

	"Lets create a new protocol via classification"
	self organization classify: #king under: #owl.
	self organization classify: #luz under: (self organization protocolNamed: #owl).

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king #luz )
]

{ #category : #tests }
ClassOrganizationTest >> testCopyFrom [

    | newOrganization |
    "First lets check the current state of the org."
    self assertCollection: self organization protocolNames hasSameElements: #( 'empty' 'one' ).
    self assertCollection: (self organization protocolNamed: 'one') methodSelectors hasSameElements: #( 'one' ).
    self assertEmpty: (self organization protocolNamed: 'empty') methodSelectors.

    "Now lets check that the new org has the same"
    newOrganization := ClassOrganization new
                           setSubject: self organization organizedClass;
                           copyFrom: self organization;
                           yourself.

    self assertCollection: newOrganization protocolNames hasSameElements: #( 'empty' 'one' ).
    self assertCollection: (newOrganization protocolNamed: 'one') methodSelectors hasSameElements: #( 'one' ).
    self assertEmpty: (newOrganization protocolNamed: 'empty') methodSelectors.

    "And now lets check that updating one does not update the other."
    self organization addProtocol: 'two'.
    newOrganization classify: 'new' under: 'init'.

    self assertCollection: self organization protocolNames hasSameElements: #( 'empty' 'one' 'two' ).
    self assertCollection: (self organization protocolNamed: 'one') methodSelectors hasSameElements: #( 'one' ).
    self assertEmpty: (self organization protocolNamed: 'empty') methodSelectors.
    self assertEmpty: (self organization protocolNamed: 'two') methodSelectors.

    self assertCollection: newOrganization protocolNames hasSameElements: #( 'empty' 'one' 'init' ).
    self assertCollection: (newOrganization protocolNamed: 'one') methodSelectors hasSameElements: #( 'one' ).
    self assertEmpty: (newOrganization protocolNamed: 'empty') methodSelectors.
    self assertCollection: (newOrganization protocolNamed: 'init') methodSelectors hasSameElements: #( 'new' )
]

{ #category : #tests }
ClassOrganizationTest >> testMethodSelectorsInProtocol [

	| methods |
	methods := self organization methodSelectorsInProtocol: 'empty'.
	self assertEmpty: methods.

	methods := self organization methodSelectorsInProtocol: 'one'.
	self assert: methods size equals: 1.
	self assert: methods first equals: #one
]

{ #category : #tests }
ClassOrganizationTest >> testProtocolNamed [

	self assert: (self organization protocolNamed: 'empty') name equals: 'empty'.
	self should: [ self organization protocolNamed: 'non existing' ] raise: NotFound
]

{ #category : #tests }
ClassOrganizationTest >> testProtocolNames [

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one )
]

{ #category : #tests }
ClassOrganizationTest >> testRemoveNonExistingProtocol [

	self organization removeProtocolIfEmpty: 'non-existent'
]

{ #category : #tests }
ClassOrganizationTest >> testRemoveProtocolIfEmpty [

	self assert: self organization protocolNames size equals: 2.
	"just ignore removing of non empty categories"
	self organization removeProtocolIfEmpty: 'one'.
	self assert: self organization protocolNames size equals: 2.
	self organization removeProtocolIfEmpty: 'empty'.
	self assert: self organization protocolNames size equals: 1.
	self assert: self organization protocolNames first equals: 'one'
]

{ #category : #tests }
ClassOrganizationTest >> testRenameProtocolIntoWithExistingProtocol [

	self organization classify: 'king' under: 'two'.

	self assert: (self organization hasProtocol: #one).
	self assert: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' ).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( 'king' ).
	self organization renameProtocolNamed: #one toBe: #two.

	self assert: (self organization hasProtocol: #two).
	self deny: (self organization hasProtocol: #one).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( 'one' 'king' )
]

{ #category : #tests }
ClassOrganizationTest >> testRenameProtocolIntoWithNil [

	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' ).

	self organization renameProtocolNamed: #one toBe: nil.
	"Check that nothing changed."
	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' )
]

{ #category : #tests }
ClassOrganizationTest >> testRenameProtocolIntoWithNil2 [

	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' ).

	self organization renameProtocolNamed: nil toBe: #two.
	"Check that nothing changed."
	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' )
]

{ #category : #tests }
ClassOrganizationTest >> testRenameProtocolIntoWithNil3 [

	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' ).

	self organization renameProtocolNamed: nil toBe: nil.
	"Check that nothing changed."
	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' )
]

{ #category : #tests }
ClassOrganizationTest >> testRenameProtocolNamedToBe [

	self assert: (self organization hasProtocol: #one).
	self deny: (self organization hasProtocol: #two).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( 'one' ).
	self organization renameProtocolNamed: #one toBe: #two.

	self assert: (self organization hasProtocol: #two).
	self deny: (self organization hasProtocol: #one).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( 'one' ).
]

{ #category : #tests }
ClassOrganizationTest >> testSilentlyClassifyUnder [
	"Set the base for the test"

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one ).

	"Lets create a new protocol via classification"
	self organization silentlyClassify: #king under: #owl.
	self organization silentlyClassify: #luz under: #owl.

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king #luz).

	"Move a method"
	self organization silentlyClassify: #luz under: #one.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz).

	"Move last method"
	self organization silentlyClassify: #king under: #two.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #two ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( #king ).

	"Nothing should change if the new protocol is the same than the old one"
	self organization silentlyClassify: #king under: #two.
	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #two ).
	self assertCollection: (self organization protocolNamed: #one) methodSelectors hasSameElements: #( #one #luz).
	self assertCollection: (self organization protocolNamed: #two) methodSelectors hasSameElements: #( #king )
]

{ #category : #tests }
ClassOrganizationTest >> testSilentlyClassifyUnderWithProtocol [
	"Set the base for the test"

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one ).

	"Lets create a new protocol via classification"
	self organization silentlyClassify: #king under: #owl.
	self organization silentlyClassify: #luz under: (self organization protocolNamed: #owl).

	self assertCollection: self organization protocolNames hasSameElements: #( #empty #one #owl ).
	self assertCollection: (self organization protocolNamed: #owl) methodSelectors hasSameElements: #( #king #luz )
]
