import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../blocs/post/post_cubit.dart';
import '../blocs/post/post_state.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/connectme_snack_bar.dart';
import '../widgets/profile_gate.dart';
import '../widgets/user_avatar.dart';

/// Composer opened by the centre gradient FAB.
///
/// Requirement 2: "Add a floating action button that opens a form to create and
/// save a new post to Firestore."
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _contentController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('New post'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Responsive.constrainContent(
          context,
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _AuthorRow(),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _contentController,
                  autofocus: true,
                  maxLines: 6,
                  maxLength: AppConstants.maxPostLength,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (String? value) => Validators.postContent(
                    value,
                    maxLength: AppConstants.maxPostLength,
                  ),
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    hintText: 'Share something with your community...',
                    alignLabelWithHint: true,
                    counterStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const Spacer(),
                _CharacterCounter(controller: _contentController),
                const SizedBox(height: AppSpacing.md),
                BlocConsumer<PostCubit, PostState>(
                  listenWhen: (PostState previous, PostState current) =>
                      previous.isSubmitting != current.isSubmitting,
                  listener: (BuildContext context, PostState state) {
                    if (state.errorMessage != null) {
                      ConnectMeSnackBar.showError(context, state.errorMessage!);
                      context.read<PostCubit>().clearError();
                    }
                  },
                  builder: (BuildContext context, PostState state) {
                    return AppPrimaryButton(
                      label: 'Publish',
                      icon: Icons.send_rounded,
                      isLoading: state.isSubmitting,
                      onPressed: _publish,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final author = ProfileGate.currentUser(context);
    final bool published = await context.read<PostCubit>().publish(
      authorId: author.id,
      authorName: author.fullName,
      content: _contentController.text,
      authorPhotoUrl: author.photoUrl,
    );
    if (published && mounted) {
      Navigator.of(context).pop();
      ConnectMeSnackBar.showSuccess(context, 'Your post is live.');
    }
  }
}

/// Shows who is publishing, using the Figma post-card header.
class _AuthorRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final author = ProfileGate.currentUser(context);
    return Row(
      children: <Widget>[
        UserAvatar(
          fullName: author.fullName,
          photoUrl: author.photoUrl,
          size: 40,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            author.fullName,
            style: AppTypography.sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Live counter of the remaining characters.
class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final int remaining = AppConstants.maxPostLength - controller.text.length;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$remaining characters left',
        style: AppTypography.caption.copyWith(
          color: remaining < 20 ? AppColors.error : AppColors.textTertiary,
        ),
      ),
    );
  }
}
