import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/api_client.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/task_detail_screen.dart';
import 'presentation/screens/task_form_screen.dart';

class EmployeeTaskApp extends StatelessWidget {
  const EmployeeTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authRepository = AuthRepository(apiClient);
    final taskRepository = TaskRepository(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
      ],
      child: MaterialApp.router(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/tasks/new', builder: (_, __) => const TaskFormScreen()),
    GoRoute(
      path: '/tasks/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TaskDetailScreen(taskId: id);
      },
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TaskFormScreen(taskId: id);
      },
    ),
  ],
);
