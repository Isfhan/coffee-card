abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const cardNew = '/cards/new';
  static const cardEdit = '/cards/:id/edit';

  static String cardEditPath(int id) => '/cards/$id/edit';
}
