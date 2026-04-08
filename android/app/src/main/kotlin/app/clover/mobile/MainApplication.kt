package app.clover.mobile

import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterApplication

// Ключ MapKit: https://developer.tech.yandex.ru/ → создайте ключ для Android SDK.
class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("2f22c733-43bd-48eb-a2ae-5d66aebfd4ef")
    }
}
