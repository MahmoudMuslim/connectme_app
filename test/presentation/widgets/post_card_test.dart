import 'package:connectme_app/core/theme/app_theme.dart';
import 'package:connectme_app/domain/entities/post.dart';
import 'package:connectme_app/presentation/widgets/post_card.dart';
import 'package:connectme_app/presentation/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

Post _post({
  String authorName = 'Bruno Pham',
  String content = 'Hello community',
  int likeCount = 12,
  int commentCount = 4,
  bool isLiked = false,
  DateTime? createdAt,
}) {
  return Post(
    id: 'p1',
    authorId: 'u1',
    authorName: authorName,
    content: content,
    createdAt: createdAt ?? DateTime.now().subtract(const Duration(hours: 1)),
    likeCount: likeCount,
    commentCount: commentCount,
    isLikedByCurrentUser: isLiked,
  );
}

void main() {
  group('PostCard', () {
    testWidgets('shows the author name, the content and the counters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(PostCard(post: _post(), onLike: () {})));

      expect(find.text('Bruno Pham'), findsOneWidget);
      expect(find.text('Hello community'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders the relative timestamp of the design', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(PostCard(post: _post())));

      // The Figma frame shows "1 hour ago".
      expect(find.text('1h ago'), findsOneWidget);
    });

    testWidgets('invokes onLike when the like button is tapped', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(PostCard(post: _post(), onLike: () => taps++)),
      );

      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('uses the filled heart when the post is already liked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(PostCard(post: _post(isLiked: true))));

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('replaces the timestamp with a delete button for own posts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(PostCard(post: _post(), isOwnPost: true, onDelete: () {})),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('1h ago'), findsNothing);
    });
  });

  group('UserAvatar', () {
    testWidgets('falls back to the initials when no photo is set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserAvatar(fullName: 'Bruno Pham')));

      expect(find.text('BP'), findsOneWidget);
    });

    testWidgets('renders the initials when the photo URL fails to load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const UserAvatar(
            fullName: 'Amira Hassan',
            photoUrl: 'https://example.invalid/missing.png',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('AH'), findsOneWidget);
    });
  });
}
