class CommonService {
  static const String baseUrl = 'https://geosend.herokuapp.com';
  static const String deliveryUrl = baseUrl + '/api/deliveries';
  static const String loginUrl = baseUrl + '/auth/jwt/create';
  static const String usernameUrl = baseUrl + '/api/username';
  static const String refreshTokenUrl = baseUrl + '/auth/jwt/refresh';
  static const String verifyTokenUrl = baseUrl + '/auth/jwt/verify';
  static const String wsBaseUrl = 'wss://geosend.herokuapp.com/ws/deliveries';
  static const String creditsUrl = baseUrl + '/api/credits';
  static const String locationUpdateUrl = baseUrl + '/api/location';
}