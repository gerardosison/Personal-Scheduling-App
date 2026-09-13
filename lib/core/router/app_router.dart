import 'package:go_router/go_router.dart';
import '../../home/presentation/home_screen.dart';
import '../../home/create_schedule/presentation/create_schedule_screen.dart';

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
  ],
);