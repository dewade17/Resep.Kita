@echo off

flutter analyze --no-pub
if %errorlevel% neq 0 {
  echo Found error, fix before build
  exit \b 1
}

flutter build apk --release