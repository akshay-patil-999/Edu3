# Google Sign-In Fix Script
# This script helps fix ApiException: 10 by generating SHA-1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Google Sign-In Fix Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check JAVA_HOME
Write-Host "Step 1: Checking JAVA_HOME..." -ForegroundColor Yellow

$javaHome = $env:JAVA_HOME

if ([string]::IsNullOrEmpty($javaHome)) {
    Write-Host "❌ JAVA_HOME is not set!" -ForegroundColor Red
    Write-Host "`nPlease install Java JDK 17:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor White
    Write-Host "2. Install JDK 17" -ForegroundColor White
    Write-Host "3. Set JAVA_HOME environment variable" -ForegroundColor White
    Write-Host "`nOr use Android Studio's JDK:" -ForegroundColor Yellow
    Write-Host '[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Android\Android Studio\jbr", "Machine")' -ForegroundColor White
    Write-Host "`nAfter setting JAVA_HOME, restart terminal and run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ JAVA_HOME: $javaHome" -ForegroundColor Green

# Check if Java exists
if (-not (Test-Path "$javaHome\bin\java.exe")) {
    Write-Host "❌ Java executable not found at: $javaHome\bin\java.exe" -ForegroundColor Red
    Write-Host "`nJAVA_HOME points to an invalid directory." -ForegroundColor Yellow
    Write-Host "Please update JAVA_HOME to point to your JDK installation." -ForegroundColor Yellow
    exit 1
}

# Verify Java version
Write-Host "`nChecking Java version..." -ForegroundColor Yellow
$javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
Write-Host "✓ $javaVersion" -ForegroundColor Green

# Step 2: Generate SHA-1
Write-Host "`nStep 2: Generating SHA-1 fingerprint..." -ForegroundColor Yellow
Write-Host "Running Gradle signingReport...`n" -ForegroundColor Yellow

$androidPath = "c:\Qo App\Vedo\android"
Set-Location $androidPath

try {
    $output = & ".\gradlew" signingReport 2>&1
    Write-Host $output -ForegroundColor White
    
    # Extract SHA1 from output
    $sha1Match = $output | Select-String "SHA1:\s*([A-F0-9:]{59})"
    
    if ($sha1Match) {
        $sha1 = $sha1Match.Matches[0].Groups[1].Value
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  SHA-1 Fingerprint Found!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "$sha1" -ForegroundColor Yellow
        Write-Host "`nCopy this SHA-1 and add it to Firebase Console:" -ForegroundColor Yellow
        Write-Host "1. Go to: https://console.firebase.google.com/" -ForegroundColor White
        Write-Host "2. Select project: vedo-01" -ForegroundColor White
        Write-Host "3. Click ⚙️ → Project settings" -ForegroundColor White
        Write-Host "4. Select Android app: com.vedo.vedo" -ForegroundColor White
        Write-Host "5. Add SHA certificate fingerprint" -ForegroundColor White
        Write-Host "6. Download updated google-services.json" -ForegroundColor White
        Write-Host "7. Replace: c:\Qo App\Vedo\android\app\google-services.json" -ForegroundColor White
    } else {
        Write-Host "`n❌ Could not extract SHA-1 from output" -ForegroundColor Red
        Write-Host "Try running manually: .\gradlew signingReport" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error running Gradle: $_" -ForegroundColor Red
    Write-Host "`nTry alternative method:" -ForegroundColor Yellow
    Write-Host 'keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android' -ForegroundColor White
}

# Step 3: Verify google-services.json
Write-Host "`nStep 3: Verifying google-services.json..." -ForegroundColor Yellow

$servicesJson = "c:\Qo App\Vedo\android\app\google-services.json"
if (Test-Path $servicesJson) {
    Write-Host "✓ google-services.json exists" -ForegroundColor Green
    
    # Check package name
    $content = Get-Content $servicesJson -Raw
    if ($content -match '"package_name":\s*"([^"]+)"') {
        $packageName = $matches[1]
        Write-Host "✓ Package name: $packageName" -ForegroundColor Green
        
        if ($packageName -eq "com.vedo.vedo") {
            Write-Host "✓ Package name matches!" -ForegroundColor Green
        } else {
            Write-Host "⚠ Package name mismatch! Expected: com.vedo.vedo" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ google-services.json not found!" -ForegroundColor Red
    Write-Host "Download from Firebase Console and place at: $servicesJson" -ForegroundColor Yellow
}

# Step 4: Next steps
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1. Copy SHA-1 fingerprint above" -ForegroundColor White
Write-Host "2. Add it to Firebase Console" -ForegroundColor White
Write-Host "3. Download updated google-services.json" -ForegroundColor White
Write-Host "4. Run these commands:" -ForegroundColor White
Write-Host "   cd 'c:\Qo App\Vedo'" -ForegroundColor Gray
Write-Host "   flutter clean" -ForegroundColor Gray
Write-Host "   flutter pub get" -ForegroundColor Gray
Write-Host "   flutter run" -ForegroundColor Gray

Write-Host "`n✅ After completing these steps, Google Sign-In should work!" -ForegroundColor Green

Set-Location "c:\Qo App\Vedo"
