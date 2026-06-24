import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/repositories/progress_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressRepository.init();
  runApp(
    const ProviderScope(
      child: BaghKhamoshApp(),
    ),
  );
}
