import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/app/routes/app_router.dart';
import 'package:field_track/app/theme/app_theme.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_track/app/di/injection_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<LocationBloc>(
          create: (_) => sl<LocationBloc>(),
        ),
        BlocProvider<TodoBloc>(
          create: (_) => sl<TodoBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'FieldTrack',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
