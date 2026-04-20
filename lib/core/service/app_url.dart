

class AppUrl {
  AppUrl._();

  /// vps
  static const String _baseUrl = "http://206.162.244.144:6014/api/v1";

  ///loalal


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

  static String nearbyPings(double lat, double lng) {
    return "${_baseUrl}/ping?latitude=$lat&longitude=$lng";
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
      "$_baseUrl/connection/my-connection?page=$page&limit=$limit&search=$searchTerm";

  static String createPing = "$_baseUrl/ping/create";

  static String acceptedPings(int page, int limit) => "$_baseUrl/ping/accepted-by-me?page=$page&limit=$limit";

  static String myPings(int page, int limit) => "$_baseUrl/ping/my?page=$page&limit=$limit";

  static String getPing(int radius) => "$_baseUrl/ping?radius=$radius";

  static String deletePing(String pingId) => "$_baseUrl/ping/delete/$pingId";

  static String acceptPing(String pingId) => "$_baseUrl/ping/accept/$pingId";
  static String rejectPing(String pingId) => "$_baseUrl/ping/reject/$pingId";

  static String myConnections(int page, int limit) => "$_baseUrl/connection/my-connection?page=$page&limit=$limit";
  static String findUsers(int page, int limit) => "$_baseUrl/connection/find?page=$page&limit=$limit";
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

  ///end add by lisan


  static const String updateLocation = "$_baseUrl/auth/update/user-location";
  static const String setUpProfile = "$_baseUrl/users/set-profile";

  static const String deleteAccount = "$_baseUrl/users/delete-account";

  static const String sendOtp = "$_baseUrl/auth/send-otp";
  static const String otpVerification = "$_baseUrl/auth/verify-otp";
  static const String changePassword = "$_baseUrl/auth/change-password";
  static const String editProfile = "$_baseUrl/users/update-profile";
  static const String editProfilePicture = "$_baseUrl/users/update-profile-image";


  static const String getConversation = "$_baseUrl/chat/conversations";

  /// post section
  static const String createPost = "$_baseUrl/post/create";
  static const String getAllPost = "$_baseUrl/post/all";

  static String toggleLikeUnlike(String postId) =>
      "$_baseUrl/post/like-unlike/$postId";
  static const String commentPost = "$_baseUrl/post/comment";

  static String getCommentByPost(String postId) =>
      "$_baseUrl/post/comments/$postId";

  static String toggleLikeUnlikeComment(String commentId) =>
      "$_baseUrl/post/comment/like-unlike/$commentId";
  static const String createReply = "$_baseUrl/post/comment/reply";

  /// follow section
  static String toggleFollowUnFollow(String userId) =>
      "$_baseUrl/follower/toggle-follow-unfollow/$userId";
  static String getFollowerRequestList = "$_baseUrl/follower/request-list";

  static String acceptFollowerRequest(String requestId) =>
      "$_baseUrl/follower/accept-follow-request/$requestId";

  static String rejectFollowerRequest(String requestId) =>
      "$_baseUrl/follower/reject-follow-request/$requestId";

  /// notification
  static const String getAllNotification = "$_baseUrl/notification";

  static String updateNotificationStatus(String notificationId) =>
      "$_baseUrl/notification/$notificationId";
  static const String markAllRead = "$_baseUrl/notification/mark-all-read";

  /// Discovery flow
  static const String getOtherUser = "$_baseUrl/users/all";

  static String getUserDetails(String userId) =>
      "$_baseUrl/users/details/$userId";

  static String filterUser(String profession, String subProfession,
      String maxDistance) =>
      "$_baseUrl/users/all?profession=$profession&subProfession=$subProfession&maxDistance=$maxDistance";

  static String search(String search) => "$_baseUrl/users/all?search=$search";

  /// image upload for message
  static const String generateUrl = "$_baseUrl/users/generate-url";

  /// event Flow
  static const String createEvent = "$_baseUrl/event/create";
  static const String getEvent = "$_baseUrl/event/all";

  static String getEventByType(String eventCategory) =>
      "$_baseUrl/event/all?eventCategory=$eventCategory";

  static String eventDetails(String eventId) =>
      "$_baseUrl/event/details/$eventId";

  static String joinEvent(String eventId) => "$_baseUrl/event/join/$eventId";

  static String searchEvent(String search) =>
      "$_baseUrl/event/all?search=$search";

  static String filterEvent(String maxDistance) =>
      "$_baseUrl/event/all?maxDistance=$maxDistance";
  static const String userWiseEvent = "$_baseUrl/event/user-wise";
  static const String updateEvent = "$_baseUrl/event/update";

  static String deleteEvent(String eventId) =>
      "$_baseUrl/event/delete/$eventId";

  static String getNonInvitedUserList(String eventId) =>
      "$_baseUrl/event//non-invited-users/$eventId";
  static const String inviteUser = "$_baseUrl/event/invite";
  static const String getMyInvitedEvent = "$_baseUrl/event/join-history";
  static const String acceptRejectinvitation = "$_baseUrl/event/accept-reject-invite";

  /// story flow
  static const String createStory = "$_baseUrl/story/create";
  static const String getAllStory = "$_baseUrl/story/available";

  static get apiBaseUrl => null;

  static String storyPreview(String userId) => "$_baseUrl//story/user/$userId";

  static String toggleLikeUnlikeStory(String storyId) =>
      "$_baseUrl/story/like-unlike/$storyId";

}