import 'dart:io';

import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/routing/app_routes.dart';
import 'package:coffee_card/ui/core/responsive_layout.dart';
import 'package:coffee_card/ui/features/cards/view_models/coffee_card_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CoffeeCardFormView extends StatefulWidget {
  const CoffeeCardFormView({super.key, this.cardId});

  final int? cardId;

  @override
  State<CoffeeCardFormView> createState() => _CoffeeCardFormViewState();
}

class _CoffeeCardFormViewState extends State<CoffeeCardFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  int _rating = 3;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(CoffeeCardFormViewModel viewModel) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      viewModel.setPickedImage(file.path);
    }
  }

  Future<void> _submit(CoffeeCardFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await viewModel.submit(
      title: _titleController.text,
      description: _descriptionController.text,
      rating: _rating,
    );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoffeeCardFormViewModel(
        context.read<AuthRepository>(),
        context.read<CoffeeCardRepository>(),
        cardId: widget.cardId,
      )..load(),
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<CoffeeCardFormViewModel>();

          if (!_initialized && !viewModel.isLoading && viewModel.isEdit) {
            _titleController.text = viewModel.initialTitle;
            _descriptionController.text = viewModel.initialDescription;
            _rating = viewModel.initialRating;
            _initialized = true;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                viewModel.isEdit ? 'Edit coffee card' : 'New coffee card',
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ResponsiveCenter(
                    maxWidth: kFormMaxWidth,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          if (viewModel.errorMessage != null) ...[
                            Text(
                              viewModel.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildPreview(viewModel),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: viewModel.isSubmitting
                                    ? null
                                    : () => _pickImage(viewModel),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Choose image'),
                              ),
                              if (viewModel.previewImagePath != null) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: viewModel.isSubmitting
                                      ? null
                                      : viewModel.clearImage,
                                  child: const Text('Remove'),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('card_title'),
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('card_description'),
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rating',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Slider(
                            value: _rating.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '$_rating',
                            onChanged: viewModel.isSubmitting
                                ? null
                                : (value) {
                                    setState(() => _rating = value.round());
                                  },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : () => _submit(viewModel),
                            child: viewModel.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    viewModel.isEdit
                                        ? 'Save changes'
                                        : 'Save card',
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(CoffeeCardFormViewModel viewModel) {
    final path = viewModel.previewImagePath;
    if (path == null || path.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.local_cafe_outlined, size: 56)),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
