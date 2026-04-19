$basePath = "c:\cse489\night_out"

$dirs = @(
    "android",
    "ios",
    "lib/config",
    "lib/models",
    "lib/providers",
    "lib/screens/auth",
    "lib/screens/user",
    "lib/screens/admin",
    "lib/services",
    "lib/utils",
    "backend/src/config",
    "backend/src/controllers",
    "backend/src/middleware",
    "backend/src/models",
    "backend/src/routes",
    "backend/src/utils"
)

foreach ($dir in $dirs) { 
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
    }
}

$files = @(
    "lib/config/app_config.dart",
    "lib/models/user_model.dart",
    "lib/models/booking_model.dart",
    "lib/providers/auth_provider.dart",
    "lib/providers/user_provider.dart",
    "lib/screens/auth/login_screen.dart",
    "lib/screens/auth/register_screen.dart",
    "lib/screens/auth/admin_login_screen.dart",
    "lib/screens/user/home_screen.dart",
    "lib/screens/user/profile_screen.dart",
    "lib/screens/user/favorites_screen.dart",
    "lib/screens/admin/admin_dashboard.dart",
    "lib/screens/admin/manage_pubs.dart",
    "lib/screens/splash_screen.dart",
    "lib/services/api_service.dart",
    "lib/services/auth_service.dart",
    "lib/utils/constants.dart",
    "lib/main.dart",
    "backend/src/config/database.js",
    "backend/src/controllers/authController.js",
    "backend/src/controllers/userController.js",
    "backend/src/controllers/adminController.js",
    "backend/src/middleware/authMiddleware.js",
    "backend/src/middleware/roleMiddleware.js",
    "backend/src/models/User.js",
    "backend/src/models/Pub.js",
    "backend/src/models/Booking.js",
    "backend/src/routes/authRoutes.js",
    "backend/src/routes/userRoutes.js",
    "backend/src/routes/adminRoutes.js",
    "backend/src/utils/jwtHelper.js",
    "backend/src/server.js",
    "backend/package.json",
    "backend/.env",
    "pubspec.yaml",
    "README.md"
)

foreach ($file in $files) { 
    $fullPath = Join-Path $basePath $file
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType File -Force -Path $fullPath | Out-Null
    }
}

Write-Host "Scaffolding complete."
