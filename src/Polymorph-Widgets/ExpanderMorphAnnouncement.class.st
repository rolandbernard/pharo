"
Common superclass for expander announcements
"
Class {
	#name : #ExpanderMorphAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'expanderMorph'
	],
	#category : #'Polymorph-Widgets-Announcements'
}

{ #category : #testing }
ExpanderMorphAnnouncement class >> isAbstract [

	 ^self == ExpanderMorphAnnouncement
]

{ #category : #'instance creation' }
ExpanderMorphAnnouncement class >> on: anExpanderMorph [
	"Answer a new announcement for the given expander."

	^self new expanderMorph: anExpanderMorph
]

{ #category : #accessing }
ExpanderMorphAnnouncement >> expanderMorph [

	^ expanderMorph
]

{ #category : #accessing }
ExpanderMorphAnnouncement >> expanderMorph: anObject [

	expanderMorph := anObject
]
