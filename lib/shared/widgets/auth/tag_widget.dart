import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

enum TagType { required, optional }

class TagWidget extends StatelessWidget {
  final TagType type;

  const TagWidget({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isRequired = type == TagType.required;

    return Text(
      isRequired ? '[Required]' : '[Optional]',
      style: AppTypography.enLabelSmall.copyWith(
        color: isRequired ? AppColors.errorRed500 : AppColors.textTertiary,
      ),
    );
  }
}
