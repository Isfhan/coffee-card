import 'package:coffee_card/routing/app_routes.dart';
import 'package:coffee_card/ui/features/auth/view_models/auth_view_model.dart';
import 'package:coffee_card/ui/features/auth/views/login_view.dart';
import 'package:coffee_card/ui/features/auth/views/register_view.dart';
import 'package:coffee_card/ui/features/cards/views/coffee_card_form_view.dart';
import 'package:coffee_card/ui/features/cards/views/coffee_cards_home_view.dart';
import 'package:coffee_card/ui/features/splash/splash_view.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({required AuthViewModel authViewModel}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final isInitializing = authViewModel.isInitializing;
      final isAuthenticated = authViewModel.isAuthenticated;
      final location = state.matchedLocation;

      if (isInitializing) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;

      if (!isAuthenticated) {
        if (isAuthRoute || location == AppRoutes.splash) {
          return location == AppRoutes.splash ? AppRoutes.login : null;
        }
        return AppRoutes.login;
      }

      if (isAuthRoute || location == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const CoffeeCardsHomeView(),
      ),
      GoRoute(
        path: AppRoutes.cardNew,
        builder: (context, state) => const CoffeeCardFormView(),
      ),
      GoRoute(
        path: AppRoutes.cardEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CoffeeCardFormView(cardId: id);
        },
      ),
    ],
  );
}
