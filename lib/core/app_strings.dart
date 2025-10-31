abstract class AppStrings {
  static const String appTitle = 'Collectors App';
  static const String login = 'Увійти';
  static const String register = 'Зареєструватися';
  static const String email = 'Email';
  static const String password = 'Пароль';
  static const String name = "Ім'я";
  static const String noAccount = 'Немає акаунту? Зареєструйтеся';
  static const String hasAccount = 'Вже є акаунт? Увійти';
  static const String emailRequired = 'Введіть email';
  static const String emailInvalid = 'Невірний формат email';
  static const String emailExample = 'example@gmail.com';
  static const String passwordRequired =
      'Введіть пароль, пароль не може містити пробілів';
  static const String passwordMin = 'Пароль має бути не менше 6 символів';
  static const String passwordExample = '••••••••';
  static const String nameRequired = "Введіть ім'я";
  static const String loginFailed = 'Помилка входу. Перевірте дані.';
  static const String registerFailed = 'Помилка реєстрації. Спробуйте ще раз.';
  static const String welcome = 'Авторизація успішна!';
  static const String googleLoginFailed =
      'Помилка входу через Google. Спробуйте ще раз!';
  static const String googleLoginCanceled = 'Вхід скасовано';
  static const String checkInputFields = 'Будь ласка заповніть усі поля';
  static const String googleLogin = 'Увійти через Google';

  static String authSuccess(String text) => 'Вхід через $text успішний!';

  const AppStrings._();
}
