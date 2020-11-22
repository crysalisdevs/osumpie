# Osum Pie

flutter build apk --release --target-platform android-arm64 --obfuscate --shrink --tree-shake-icons --split-debug-info build/debug

flutter packages pub run build_runner watch --delete-conflicting-outputs
