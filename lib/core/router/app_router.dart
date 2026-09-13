import 'package:go_router/go_router.dart';
import '../../feature/home/presentation/home_screen.dart';
import '../../feature/create_schedule/presentation/create_schedule_screen.dart';
import '../../feature/edit_schedule/presentation/edit_schedule_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateScheduleScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditScheduleScreen(taskId: id);
      },
    ),
  ],
);