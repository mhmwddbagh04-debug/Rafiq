import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:Rafiq/core/api/dio_client.dart';
import 'package:Rafiq/core/app_router.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. طلب الإذن (مهم لـ Android 13+ و iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // 2. إعدادات الإشعارات المحلية
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // التعامل مع النقر عند فتح الإشعار والتطبيق مفتوح (Foreground)
          if (response.payload != null) {
            try {
              Map<String, dynamic> data = jsonDecode(response.payload!);
              _handleMessageNavigation(data);
            } catch (e) {
              debugPrint("Error parsing notification payload: $e");
            }
          }
        },
      );

      // 3. إنشاء قناة إشعارات للأندرويد (مهم لإظهار الإشعارات في المقدمة)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 4. الاستماع للإشعارات أثناء فتح التطبيق (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ),
            payload: jsonEncode(message.data), // تمرير البيانات كـ JSON
          );
        }
      });

      // 5. التعامل مع النقر عند فتح الإشعار والتطبيق في الخلفية
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageNavigation(message.data);
      });

      // 6. التحقق مما إذا كان التطبيق قد فُتح عن طريق إشعار وهو مغلق تماماً
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageNavigation(initialMessage.data);
      }

      // الحصول على الـ Token
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print("Firebase Token: $token");
      }
    }
  }

  // وظيفة لإظهار إشعار محلي يدوياً
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  // وظيفة موحدة للتعامل مع التنقل بناءً على بيانات الإشعار
  static void _handleMessageNavigation(Map<String, dynamic> data) {
    debugPrint("Handling notification navigation with data: $data");
    
    if (data.containsKey('screen')) {
      String screen = data['screen'];
      if (screen == 'orders') {
        DioClient.navigatorKey.currentState?.pushNamed(AppRouter.orders);
      } else if (screen == 'cart') {
        DioClient.navigatorKey.currentState?.pushNamed(AppRouter.cart);
      } else if (screen == 'wishlist') {
        DioClient.navigatorKey.currentState?.pushNamed(AppRouter.wishlist);
      }
      // يمكنك إضافة المزيد من الصفحات هنا
    }
  }
}
