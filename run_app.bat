@echo off
echo ========================================
echo   Kolam Ikan - Firebase Setup Guide
echo ========================================
echo.

echo 1. Checking Flutter installation...
flutter --version
echo.

echo 2. Cleaning project...
flutter clean
echo.

echo 3. Getting dependencies...
flutter pub get
echo.

echo 4. Available run options:
echo   - Android: flutter run (requires emulator or device)
echo   - Web: flutter run -d chrome --web-renderer html
echo   - Windows: flutter run -d windows (requires Windows build tools)
echo.

echo 5. To test the app, you can:
echo   a) Launch Android emulator: flutter emulators --launch flutter_emulator
echo   b) Run on web: flutter run -d chrome --web-renderer html
echo   c) Run on connected device: flutter run
echo.

echo 6. Test credentials:
echo   Admin: admin@kolamikan.com / admin123
echo   User:  user@kolamikan.com / user123
echo.

echo NOTE: If you get symlink errors on Windows, use Android emulator or enable Developer Mode
echo.

pause