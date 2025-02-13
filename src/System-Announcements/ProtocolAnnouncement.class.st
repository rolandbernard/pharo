"
I'm an abstract announcement for protocols
"
Class {
	#name : #ProtocolAnnouncement,
	#superclass : #SystemAnnouncement,
	#instVars : [
		'protocol',
		'classReorganized'
	],
	#category : #'System-Announcements-System-Protocols'
}

{ #category : #'class initialization' }
ProtocolAnnouncement class >> in: aClass protocol: aProtocolName [

	^ self new
		  classReorganized: aClass;
		  protocol: aProtocolName;
		  yourself
]

{ #category : #testing }
ProtocolAnnouncement >> affectsMethodTagIn: aClass [

	^self classAffected == aClass
]

{ #category : #accessing }
ProtocolAnnouncement >> classAffected [
	^self classReorganized
]

{ #category : #accessing }
ProtocolAnnouncement >> classReorganized [
	^ classReorganized
]

{ #category : #accessing }
ProtocolAnnouncement >> classReorganized: anObject [
	classReorganized := anObject
]

{ #category : #accessing }
ProtocolAnnouncement >> protocol [
	^ protocol
]

{ #category : #accessing }
ProtocolAnnouncement >> protocol: aString [
	protocol := aString
]
