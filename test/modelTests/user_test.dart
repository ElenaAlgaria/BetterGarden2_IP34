import 'package:biodiversity/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_storage_provider.dart';

const testName = 'Muster';
const testSurname = 'Müller';
const testNickname = 'littleTester1234';
const testPassword = '123456';
const testMail = 'muster.mueller@tester.com';
const testImageURL = 'https://bit.ly/3xfxbnW';
const testFavoredObjects = ['Bee', 'Hedgehog', 'Pile of branches'];

void main() {
  test('Empty User is empty', () {
    final testUser = User.empty(storageProvider: MockStorageProvider());
    expect(testUser.name, '', reason: 'name was not empty');
    expect(testUser.surname, '', reason: 'surname was not empty');
    expect(testUser.nickname, '', reason: 'nickname was not empty');
    expect(testUser.showNameOnMap, isTrue,
        reason: 'showNameOnMap was not set to default true');
    expect(testUser.showGardenImageOnMap, isTrue,
        reason: 'showGardenImageOnMap was not set to default true');
    expect(testUser.imageURL, '', reason: 'imageURL was not empty');
    expect(testUser.mail, '', reason: 'mail was not empty');
    expect(testUser.isLoggedIn, isFalse,
        reason: 'user should not be logged in');
  }, skip: 'Mock class does not support the current auth fields yet');

  test('User attributes change and save', () async {
    final storage = MockStorageProvider();
    final testUser = User.empty(storageProvider: storage);
    // some_random_id is specified that way in the Mock of the Auth User
    // see firebase_auth_mocks -> mock_user for details
    await storage.database.doc('users/some_random_id').set({
      'nickname': 'wrong',
      'name': 'wrong',
      'surname': 'wrong',
      'mail': 'wrong',
      'imageURL': 'wrong',
    });
    await testUser.signInWithEmail(testMail, testPassword);
    testUser.updateUserData(
        newName: testName,
        newSurname: testSurname,
        newNickname: testNickname,
        newMail: testMail,
        newImageURL: testImageURL,
        doesShowGardenImageOnMap: false,
        doesShowNameOnMap: false);
    expect(testUser.name, testName, reason: 'name was set wrong');
    expect(testUser.surname, testSurname, reason: 'Surname was set wrong');
    expect(testUser.nickname, testNickname, reason: 'Nickname was set wrong');
    expect(testUser.mail, testMail, reason: 'Email was set wrong');
    expect(testUser.imageURL, testImageURL, reason: 'imageUrl was set wrong');
    expect(testUser.showGardenImageOnMap, isFalse,
        reason: 'showGardenImageOnMap was set wrong');
    expect(testUser.showNameOnMap, isFalse,
        reason: 'showNameOnMap was set wrong');

    await testUser.saveUser();
    final snapshot = await storage.database.doc('users/some_random_id').get();
    final map = snapshot.data();
    expect(map['name'], testName, reason: 'name not saved to the database');
    expect(map['surname'], testSurname,
        reason: 'surname not saved to the database');
    expect(map['nickname'], testNickname,
        reason: 'nickname not saved to the database');
    expect(map['mail'], testMail, reason: 'mail not saved to the database');
    expect(map['imageURL'], testImageURL,
        reason: 'imageURL not saved to the database');
    expect(map['showNameOnMap'] as bool, isFalse,
        reason: 'showNameOnMap was not saved to the database');
    expect(map['showGardenImageOnMap'] as bool, isFalse,
        reason: 'showGardenImageOnMap was not saved to the database');
  }, skip: 'Mock class does not support the current auth fields yet');

  test('User like element', () async {
    final storage = MockStorageProvider();
    final testUser = User.empty(storageProvider: storage);
    expect(testUser.doesLikeElement('plant'), false,
        reason: 'Should not like element before it is liked');
    testUser.likeUnlikeElement('plant');
    expect(testUser.doesLikeElement('plant'), true,
        reason: 'Should like element after like action');
    testUser.likeUnlikeElement('plant');
    expect(testUser.doesLikeElement('plant'), false,
        reason: 'Should not like element anymore after unlike action');
  });

  test('User email login and details loading', () async {
    final storage = MockStorageProvider();
    final testUser = User.empty(storageProvider: storage);
    expect(testUser.nickname, '', reason: 'Nickname was not empty');
    expect(testUser.name, '', reason: 'Name was not empty');
    expect(testUser.surname, '', reason: 'Surname was not empty');
    expect(testUser.imageURL, '', reason: 'ImageURL was not empty');
    await storage.database.doc('users/some_random_id').set({
      'nickname': testNickname,
      'name': testName,
      'surname': testSurname,
      'mail': testMail,
      'imageURL': testImageURL,
      'gardens': [],
      'favoredObjects': testFavoredObjects,
    });
    await testUser.signInWithEmail(testMail, testPassword);
    expect(testUser.nickname, testNickname, reason: 'Nickname was not loaded');
    expect(testUser.name, testName, reason: 'Name was not loaded');
    expect(testUser.surname, testSurname, reason: 'Surname was not loaded');
    expect(testUser.imageURL, testImageURL, reason: 'ImageURL was not loaded');
  }, skip: 'Mock class does not support the current auth fields yet');

  test('User sign out test', () async {
    final storage = MockStorageProvider();
    final user = User.empty(storageProvider: storage);
    await storage.database.doc('users/some_random_id').set({
      'nickname': testNickname,
      'name': testName,
      'surname': testSurname,
      'mail': testMail,
      'imageURL': testImageURL,
      'gardens': ['testgarden'],
      'favoredObjects': testFavoredObjects
    });
    await user.signInWithEmail(testMail, testPassword);
    await user.signOut();
    final emptyUser = User.empty(storageProvider: storage);
    expect(user.name, emptyUser.name,
        reason: 'name was not the same as in User.empty');
    expect(user.surname, emptyUser.surname,
        reason: 'surname was not the same as in User.empty');
    expect(user.nickname, emptyUser.nickname,
        reason: 'nickname was not the same as in User.empty');
    expect(user.mail, emptyUser.mail,
        reason: 'mail was not the same as in User.empty');
    expect(user.isLoggedIn, emptyUser.isLoggedIn,
        reason: 'isLoggedIn was not the same as in User.empty');
    expect(user.showGardenImageOnMap, emptyUser.showGardenImageOnMap,
        reason: 'showGardenImageOnMap was not the same as in User.empty');
    expect(user.showNameOnMap, emptyUser.showNameOnMap,
        reason: 'showNameOnMap was not the same as in User.empty');
    expect(user.imageURL, emptyUser.imageURL,
        reason: 'imageURL was not the same as in User.empty');
  }, skip: 'Mock class does not support the current auth fields yet');

  test('Google sign in', () async {
    final storage = MockStorageProvider();
    final user = User.empty(storageProvider: storage);
    final result = await user.signInWithGoogle();
    expect(result, isNotNull,
        reason: 'Login without registration should not work');
    expect(result.isRegistered, isFalse, reason: 'should not be registered');
    expect(result.isEmailConfirmed, isFalse,
        reason: 'email should not be confirmed');
    expect(result.message, 'Bitte registrieren Sie sich zuerst.',
        reason: 'wrong error message');
  }, skip: 'Mock class does not support the current auth fields yet');
}
