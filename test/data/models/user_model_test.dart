import 'package:connectme_app/data/models/user_model.dart';
import 'package:connectme_app/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModelBuilder', () {
    test('only sets the fields that were provided (BUILDER PATTERN)', () {
      final UserModel user = UserModelBuilder()
          .id('uid-1')
          .fullName('Bruno Pham')
          .email('bruno@connectme.app')
          .build();

      // Fields never provided stay null instead of becoming placeholder strings.
      expect(user.deviceModel, isNull);
      expect(user.osVersion, isNull);
      expect(user.photoUrl, isNull);
      expect(user.joinedAt, isNull);
    });

    test('keeps every provided field', () {
      final UserModel user = UserModelBuilder()
          .id('uid-1')
          .fullName('Amira Hassan')
          .email('amira@connectme.app')
          .deviceModel('Pixel 8 Pro')
          .osVersion('Android 14 (API 34)')
          .photoUrl('data:image/png;base64,abc')
          .build();

      expect(user.deviceModel, 'Pixel 8 Pro');
      expect(user.osVersion, 'Android 14 (API 34)');
      expect(user.photoUrl, 'data:image/png;base64,abc');
    });

    test('normalises empty optional strings to null', () {
      final UserModel user = UserModelBuilder()
          .id('uid-1')
          .fullName('Yuki Tanaka')
          .email('yuki@connectme.app')
          .deviceModel('')
          .build();

      expect(user.deviceModel, isNull);
    });

    test('falls back to empty strings for mandatory fields', () {
      final UserModel user = UserModelBuilder().build();

      expect(user.id, '');
      expect(user.fullName, '');
      expect(user.email, '');
    });
  });

  group('UserModel JSON', () {
    final UserModel original = UserModelBuilder()
        .id('uid-42')
        .fullName('Lucas Ferreira')
        .email('lucas@connectme.app')
        .deviceModel('Galaxy S23')
        .osVersion('Android 13 (API 33)')
        .joinedAt(DateTime.utc(2026, 1, 15))
        .build();

    test('toJson -> fromJson round-trips every field', () {
      final UserModel restored = UserModel.fromJson(original.toJson());

      expect(restored, original);
      expect(restored.joinedAt, DateTime.utc(2026, 1, 15));
    });

    test('toJson omits optional fields that are null', () {
      final Map<String, dynamic> json = UserModelBuilder()
          .id('uid-1')
          .fullName('Thanh Pham')
          .email('thanh@connectme.app')
          .build()
          .toJson();

      expect(json.containsKey('deviceModel'), isFalse);
      expect(json.containsKey('osVersion'), isFalse);
      expect(json.containsKey('photoUrl'), isFalse);
      expect(json.containsKey('createdAt'), isFalse);
    });

    test('fromJson tolerates a completely empty payload', () {
      final UserModel user = UserModel.fromJson(<String, dynamic>{});

      expect(user.id, '');
      expect(user.fullName, '');
    });
  });

  group('User helpers', () {
    const User bruno = User(
      id: 'uid-1',
      fullName: 'Bruno Pham',
      email: 'bruno@connectme.app',
    );

    test('initials uses the first and last name', () {
      expect(bruno.initials, 'BP');
    });

    test('handle is derived from the last name', () {
      expect(bruno.handle, '@pham');
    });

    test('initials fall back to a single letter for a one-word name', () {
      const User solo = User(id: 'uid-2', fullName: 'Cher', email: 'c@c.c');
      expect(solo.initials, 'C');
    });

    test('initials fall back to "?" for an empty name', () {
      const User nobody = User(id: 'uid-3', fullName: '', email: '');
      expect(nobody.initials, '?');
    });

    test('hasPhoto is false until a picture is uploaded', () {
      expect(bruno.hasPhoto, isFalse);
    });
  });
}
