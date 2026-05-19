import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';

/// Routes to subscribe when logged in, otherwise to login.
void navigateToSubscribe(BuildContext context, WidgetRef ref) {
  navigateToSubscribeIfLoggedIn(context, ref.read(authProvider).isLoggedIn);
}

void navigateToSubscribeIfLoggedIn(BuildContext context, bool isLoggedIn) {
  if (isLoggedIn) {
    context.push('/menu/subscribe');
  } else {
    context.push('/login');
  }
}
