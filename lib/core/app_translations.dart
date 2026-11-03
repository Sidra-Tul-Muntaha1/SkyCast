
import 'package:Sky_Cast/core/app_preferences.dart';

class AppTranslations {
  AppTranslations._();

  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // Home screen and weather
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'feels_like': 'Feels like',
      'hourly_forecast': "Today's Forecast",
      'hourly_forecast_title': 'Hourly Forecast',
      'daily_forecast': '5-Day Forecast',
      'five_day_forecast': '5 Day Forecast',
      'weather_details': 'Weather Details',
      'humidity': 'Humidity',
      'wind': 'Wind',
      'visibility': 'Visibility',
      'pressure': 'Pressure',
      'sunrise': 'Sunrise',
      'sunset': 'Sunset',
      'last_observation': 'Last observation',
      'weather_unavailable': 'Weather unavailable',
      'conditions_unavailable': 'Conditions unavailable',
      'try_again': 'Try again',
      'demo_mode':
          'Demo mode: showing sample weather, not live conditions.',
      'sample_hourly': 'Sample hourly conditions',
      'weather_throughout_day': 'Weather throughout the day',
      'forecast_unavailable': 'Hourly forecast unavailable',
      'forecast_data_unavailable':
          'Forecast data is not available yet.',
      'sample_forecast': 'Sample forecast · Not live data',
      'sample_forecast_not_live': 'Sample forecast · Not live data',
      'upcoming_weather': 'Your upcoming weather',
      'daily_unavailable': 'Daily forecast is not available.',
      'daily_forecast_unavailable': 'Daily forecast is not available.',
      'hourly_forecast_unavailable':
          'Hourly forecast is not available.',
      'today': 'Today',
      'now': 'Now',
      'high': 'High',
      'low': 'Low',
      'sunrise_sunset': 'Sunrise & Sunset',
      'pressure_unit': 'Pressure',
      'visibility_unit': 'Visibility',
      'refresh_weather': 'Refresh weather',
      'use_location': 'Use my current location',
      'toggle_theme': 'Toggle light/dark theme',

      // Search screen
      'search_city': 'Search City',
      'search_cities': 'Search cities',
      'find_your_city': 'Find your city',
      'search_city_description':
          'Check the weather anywhere in the world.',
      'search_city_hint': 'Search city name...',
      'search': 'Search',
      'popular_cities': 'Popular Cities',
      'cities': 'cities',
      'empty_city_error': 'Please enter a city name.',
      'city_search_error':
          'Unable to search this city. Please try again.',
      'pakistan': 'Pakistan',
      'united_kingdom': 'United Kingdom',
      'united_arab_emirates': 'United Arab Emirates',
      'united_states': 'United States',

      // Days
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',

      // General
      'back': 'Back',
      'settings': 'Settings',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'english': 'English',
      'urdu': 'Urdu',
      'skycast': 'SkyCast',
      'skycast_your_weather_always': 'SkyCast · Your Weather, Always',
      'personalize': 'Personalize your experience',
      'personalize_your_experience': 'Personalize your experience',

      // Settings
      'temperature_unit': 'Temperature Unit',
      'notifications': 'Notifications',
      'notification_preference': 'Notification preference',
      'default_city': 'Default City',
      'city_name': 'City name',
      'city_hint': 'e.g. Islamabad',
      'language': 'Language',
      'choose_language': 'Choose Language',
      'app_preferences': 'App Preferences',
      'refresh_preference': 'Refresh preference',
      'about_app': 'About App',
      'about_skycast': 'About SkyCast',
      'current_location': 'Current Location',
      'current_weather_location': 'Current weather location',
      'change_home': 'Change it from the Home Screen.',
      'change_from_home_screen': 'Change it from the Home Screen',
      'default_city_saved': 'Default city saved',
      'could_not_save_preference':
          'Could not save this preference.',
      'refresh_preference_saved': 'Refresh preference saved.',
      'refresh_saved': 'Refresh preference saved.',
      'manual_refresh_note':
          'Automatic background refresh is not enabled yet.',
      'notifications_enabled': 'Notifications',

      // Refresh interval options
      'every_15_minutes': 'Every 15 minutes',
      'every_30_minutes': 'Every 30 minutes',
      'every_hour': 'Every hour',
      'manual_only': 'Manual only',

      // About dialog
      'your_weather_always': 'Your Weather, Always',
      'about_description':
          'SkyCast provides weather information, hourly forecasts, and five-day forecasts.',
    },

    'Urdu': {
      // Home screen and weather
      'good_morning': 'صبح بخیر',
      'good_afternoon': 'دوپہر بخیر',
      'good_evening': 'شام بخیر',
      'feels_like': 'محسوس ہونے والا درجہ حرارت',
      'hourly_forecast': 'آج کی پیش گوئی',
      'hourly_forecast_title': 'گھنٹہ وار پیش گوئی',
      'daily_forecast': '5 دن کی پیش گوئی',
      'five_day_forecast': '5 دن کی پیش گوئی',
      'weather_details': 'موسم کی تفصیلات',
      'humidity': 'نمی',
      'wind': 'ہوا',
      'visibility': 'حدِ نگاہ',
      'pressure': 'فضائی دباؤ',
      'sunrise': 'طلوع آفتاب',
      'sunset': 'غروب آفتاب',
      'last_observation': 'آخری مشاہدہ',
      'weather_unavailable': 'موسم کی معلومات دستیاب نہیں',
      'conditions_unavailable': 'موسمی صورتحال دستیاب نہیں',
      'try_again': 'دوبارہ کوشش کریں',
      'demo_mode':
          'ڈیمو موڈ: نمونہ موسم دکھایا جا رہا ہے، حقیقی موسم نہیں۔',
      'sample_hourly': 'نمونہ گھنٹہ وار موسم',
      'weather_throughout_day': 'دن بھر کا موسم',
      'forecast_unavailable': 'گھنٹہ وار پیش گوئی دستیاب نہیں',
      'forecast_data_unavailable':
          'پیش گوئی کی معلومات ابھی دستیاب نہیں ہیں۔',
      'sample_forecast': 'نمونہ پیش گوئی · حقیقی معلومات نہیں',
      'sample_forecast_not_live':
          'نمونہ پیش گوئی · براہِ راست ڈیٹا نہیں',
      'upcoming_weather': 'آنے والے دنوں کا موسم',
      'daily_unavailable': 'روزانہ کی پیش گوئی دستیاب نہیں۔',
      'daily_forecast_unavailable':
          'روزانہ کی پیش گوئی دستیاب نہیں ہے۔',
      'hourly_forecast_unavailable':
          'گھنٹہ وار پیش گوئی دستیاب نہیں ہے۔',
      'today': 'آج',
      'now': 'ابھی',
      'high': 'زیادہ',
      'low': 'کم',
      'sunrise_sunset': 'طلوع اور غروب آفتاب',
      'pressure_unit': 'فضائی دباؤ',
      'visibility_unit': 'حدِ نگاہ',
      'refresh_weather': 'موسم تازہ کریں',
      'use_location': 'میرا موجودہ مقام استعمال کریں',
      'toggle_theme': 'روشن یا تاریک تھیم تبدیل کریں',

      // Search screen
      'search_city': 'شہر تلاش کریں',
      'search_cities': 'شہر تلاش کریں',
      'find_your_city': 'اپنا شہر تلاش کریں',
      'search_city_description':
          'دنیا میں کہیں بھی موسم کی معلومات دیکھیں۔',
      'search_city_hint': 'شہر کا نام لکھیں...',
      'search': 'تلاش کریں',
      'popular_cities': 'مشہور شہر',
      'cities': 'شہر',
      'empty_city_error': 'براہِ کرم شہر کا نام درج کریں۔',
      'city_search_error':
          'اس شہر کو تلاش نہیں کیا جا سکا۔ دوبارہ کوشش کریں۔',
      'pakistan': 'پاکستان',
      'united_kingdom': 'برطانیہ',
      'united_arab_emirates': 'متحدہ عرب امارات',
      'united_states': 'ریاستہائے متحدہ امریکہ',

      // Days
      'monday': 'پیر',
      'tuesday': 'منگل',
      'wednesday': 'بدھ',
      'thursday': 'جمعرات',
      'friday': 'جمعہ',
      'saturday': 'ہفتہ',
      'sunday': 'اتوار',

      // General
      'back': 'واپس',
      'settings': 'ترتیبات',
      'loading': 'لوڈ ہو رہا ہے...',
      'error': 'کچھ غلط ہو گیا',
      'retry': 'دوبارہ کوشش کریں',
      'cancel': 'منسوخ کریں',
      'save': 'محفوظ کریں',
      'english': 'انگریزی',
      'urdu': 'اردو',
      'skycast': 'اسکائی کاسٹ',
      'skycast_your_weather_always':
          'اسکائی کاسٹ · آپ کا موسم، ہمیشہ',
      'personalize': 'اپنی پسند کے مطابق بنائیں',
      'personalize_your_experience':
          'اپنے تجربے کو اپنی پسند کے مطابق بنائیں',

      // Settings
      'temperature_unit': 'درجہ حرارت کی اکائی',
      'notifications': 'اطلاعات',
      'notification_preference': 'اطلاعات کی ترجیحات',
      'default_city': 'ڈیفالٹ شہر',
      'city_name': 'شہر کا نام',
      'city_hint': 'مثلاً اسلام آباد',
      'language': 'زبان',
      'choose_language': 'زبان منتخب کریں',
      'app_preferences': 'ایپ کی ترجیحات',
      'refresh_preference': 'تازہ کاری کی ترجیح',
      'about_app': 'ایپ کے بارے میں',
      'about_skycast': 'اسکائی کاسٹ کے بارے میں',
      'current_location': 'موجودہ مقام',
      'current_weather_location': 'موجودہ موسم کا مقام',
      'change_home': 'اسے ہوم اسکرین سے تبدیل کریں۔',
      'change_from_home_screen': 'اسے ہوم اسکرین سے تبدیل کریں',
      'default_city_saved': 'ڈیفالٹ شہر محفوظ ہو گیا',
      'could_not_save_preference':
          'یہ ترجیح محفوظ نہیں ہو سکی۔',
      'refresh_preference_saved':
          'تازہ کاری کی ترجیح محفوظ ہو گئی۔',
      'refresh_saved': 'تازہ کاری کی ترجیح محفوظ ہو گئی۔',
      'manual_refresh_note':
          'خودکار پس منظر کی تازہ کاری ابھی فعال نہیں ہے۔',
      'notifications_enabled': 'اطلاعات',

      // Refresh interval options
      'every_15_minutes': 'ہر 15 منٹ بعد',
      'every_30_minutes': 'ہر 30 منٹ بعد',
      'every_hour': 'ہر گھنٹے',
      'manual_only': 'صرف دستی طور پر',

      // About dialog
      'your_weather_always': 'آپ کا موسم، ہمیشہ',
      'about_description':
          'اسکائی کاسٹ موسم کی معلومات، گھنٹہ وار پیش گوئی اور پانچ دن کی پیش گوئی فراہم کرتا ہے۔',
    },
  };

  static String text(String key) {
    final language = AppPreferences.language.value;

    return _translations[language]?[key] ??
        _translations['English']![key] ??
        key;
  }

  static String weatherDescription(String description) {
    if (AppPreferences.language.value != 'Urdu') {
      return description.isEmpty
          ? description
          : description[0].toUpperCase() + description.substring(1);
    }

    final text = description.toLowerCase().trim();

    const urduDescriptions = <String, String>{
      'clear sky': 'صاف آسمان',
      'few clouds': 'ہلکے بادل',
      'scattered clouds': 'بکھرے ہوئے بادل',
      'broken clouds': 'گھنے بادل',
      'overcast clouds': 'ابر آلود',
      'partly cloudy': 'جزوی طور پر ابر آلود',
      'clouds': 'بادل',
      'light rain': 'ہلکی بارش',
      'moderate rain': 'درمیانی بارش',
      'heavy intensity rain': 'تیز بارش',
      'very heavy rain': 'بہت تیز بارش',
      'extreme rain': 'شدید بارش',
      'freezing rain': 'جمنے والی بارش',
      'light intensity shower rain': 'ہلکی بارش کی بوچھاڑ',
      'shower rain': 'بارش کی بوچھاڑ',
      'heavy intensity shower rain': 'تیز بارش کی بوچھاڑ',
      'drizzle': 'بوندا باندی',
      'light intensity drizzle': 'ہلکی بوندا باندی',
      'heavy intensity drizzle': 'تیز بوندا باندی',
      'thunderstorm': 'گرج چمک کے ساتھ طوفان',
      'snow': 'برف باری',
      'light snow': 'ہلکی برف باری',
      'heavy snow': 'شدید برف باری',
      'mist': 'دھند',
      'fog': 'گہری دھند',
      'haze': 'دھندلا پن',
      'smoke': 'دھواں',
      'dust': 'گرد و غبار',
      'sand': 'ریت',
      'squalls': 'تیز جھکڑ',
      'tornado': 'بگولا',
    };

    return urduDescriptions[text] ?? description;
  }
}
