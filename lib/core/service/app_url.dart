

class AppUrl {
  AppUrl._();

  /// vps
  static const String _baseUrl = "http://206.162.244.144:6014/api/v1";
  static const String baseUrl = "http://206.162.244.144:6014/api/v1";

  ///local


  /// local socket url
  static const String socketUrl = "ws://206.162.244.144:6014";

  /// auth section

  static const String createUser = "$_baseUrl/user/create";
  static const String userVerifyOtp = "$_baseUrl/user/verify";
  static const String login = "$_baseUrl/auth/login";
  static const String forgetPasswordOtp = "$_baseUrl/auth/send-forgot-otp";
  static const String verifyForgotOtp = "$_baseUrl/auth/verify-forgot-otp";
  static const String resetPassword = "$_baseUrl/auth/reset-password";
  static const String getMe = "$_baseUrl/auth/me";
  static const String updateProfile = "$_baseUrl/auth/me/update";
  static const String deleteUser = "$_baseUrl/auth/delete-account";
  static const String socialLogin = "$_baseUrl/auth/social-login";
  static const String googleLogin = "$_baseUrl/auth/google";
  static const String appleLogin = "$_baseUrl/auth/apple";

  static String nearbyPings(double lat, double lng) {
    return "$_baseUrl/ping?latitude=$lat&longitude=$lng";
  }


  static String pingFilterByRadius(int radius) =>
      "$_baseUrl/ping?radius=$radius";

  static String pingFilterByCategory(String category) =>
      "$_baseUrl/ping?category=$category";

  static String pingFilterByRadiusAndCategory(int radius, String category) =>
      "$_baseUrl/ping?radius=$radius&category=$category";

  static String getMyAllConnection(int page, int limit) =>
      "$_baseUrl/connection/my-connection?page=$page&limit=$limit";

  static String getMyConnectionBySearch(int page, int limit, String searchTerm) =>
      "$_baseUrl/connection/my-connection?page=$page&limit=$limit&searchTerm=$searchTerm";

  static String createPing = "$_baseUrl/ping/create";

  static String acceptedPings(int page, int limit) => "$_baseUrl/ping/accepted-by-me?page=$page&limit=$limit";

  static String myPings(int page, int limit) => "$_baseUrl/ping/my?page=$page&limit=$limit";

  static String getPing(int radius) => "$_baseUrl/ping?radius=$radius";

  static String deletePing(String pingId) => "$_baseUrl/ping/delete/$pingId";

  static String acceptPing(String pingId) => "$_baseUrl/ping/accept/$pingId";
  static String rejectPing(String pingId) => "$_baseUrl/ping/reject/$pingId";

  static String myConnections(int page, String search,int limit) =>
      "$_baseUrl/connection/my-connection?page=$page&limit=$limit&searchTerm=$search";


  static String findUsers(int page, String search,int limit) =>
      "$_baseUrl/connection/find?searchTerm=$search&page=$page&limit=$limit";

  static String pendingConnections(int page, int limit) => "$_baseUrl/connection/pending-request?page=$page&limit=$limit";

  static String notifications (int page, int limit,String isRead) => "$_baseUrl/notify/my?limit=$limit&page=$page&isRead=$isRead";
  static String markAllAsReadNotification = "$_baseUrl/notify/mark-all";
  static String singleNotificationRead(String notificationId) => "$_baseUrl/notify/single/$notificationId";

  static String sendConnectionRequest(String connectionId) => "$_baseUrl/connection/send-request/$connectionId";
  static String acceptConnection(String connectionId) => "$_baseUrl/connection/response/$connectionId";
  static String rejectConnection(String connectionId) => "$_baseUrl/connection/response/$connectionId";

  static String myConnectionCount = "$_baseUrl/connection/count";

  static String sendRequests = "$_baseUrl/connection/sent-requests";

  static String cancelRequest(String connectionId) => "$_baseUrl/connection/cancel/$connectionId";

  static String removeConnection(String connectionId) => "$_baseUrl/connection/remove/$connectionId";

  static String changePassword = "$_baseUrl/auth/change-pass";

  ///end add by lisan




  /// message
  static  String getConversationList(String searchTerm) => "$_baseUrl/chat/conversations?searchTerm=$searchTerm";
  static const String uploadImage = "$_baseUrl/chat/upload-files";
}