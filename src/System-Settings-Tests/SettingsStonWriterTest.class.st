"
A SettingsStonWriterTest is a test class for testing the behavior of SettingsStonWriter
"
Class {
	#name : #SettingsStonWriterTest,
	#superclass : #TestCase,
	#instVars : [
		'writer',
		'fileStream',
		'fileReference'
	],
	#category : #'System-Settings-Tests'
}

{ #category : #running }
SettingsStonWriterTest >> setUp [
	super setUp.
	fileReference := (FileSystem memory root / 'preferences.ston.txt') asFileReference.
	writer := SettingsStonWriter new.
	fileStream := fileReference writeStream.
	writer stream: fileStream
]

{ #category : #running }
SettingsStonWriterTest >> tearDown [
	fileStream close.
	super tearDown
]

{ #category : #tests }
SettingsStonWriterTest >> testBasic [
	"Checking that no error occur"

	SettingsStonWriter new store
]

{ #category : #tests }
SettingsStonWriterTest >> testEmptyStream [
	fileStream flush.
	self assertEmpty: fileReference contents
]

{ #category : #tests }
SettingsStonWriterTest >> testStore [

	| settingNode |
	settingNode := MockSettings booleanSettingNode.
	writer addSetting: (StoredSettingsFactory new from: settingNode).
	writer store.
	fileStream flush.
	self assert: fileReference contents equals: (OSPlatform current lineEnding join: MockSettings oneStoredSettingSTONString lines)
]

{ #category : #tests }
SettingsStonWriterTest >> testStoreShouldNotCloseBackingStream [

	| settingNode |
	settingNode := MockSettings booleanSettingNode.
	writer addSetting: (StoredSettingsFactory new from: settingNode).
	writer store.
	self deny: fileStream closed.
	fileStream flush.
	self assert: fileReference contents equals: (OSPlatform current lineEnding join: MockSettings oneStoredSettingSTONString lines)
]

{ #category : #tests }
SettingsStonWriterTest >> testStoreTwoObjects [

	| settingNode1 settingNode2 |
	settingNode1 := MockSettings booleanSettingNode.
	settingNode2 := MockSettings rangeSettingNode.
	writer addSetting: ((StoredSettingsFactory new from: settingNode1)
			 realValue: false;
			 yourself).
	writer addSetting: ((StoredSettingsFactory new from: settingNode2)
			 realValue: 55;
			 yourself).
	writer store.
	fileStream flush.
	self assert: fileReference contents equals: (OSPlatform current lineEnding join: MockSettings twoStoredSettingsSTONString lines)
]
