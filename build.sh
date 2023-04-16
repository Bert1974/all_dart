mkdir publish
cd data
dart pub get
dart run build_runner build
cd ..
cd server
dart pub get
dart run build_runner build
dart compile exe ./bin/server.dart -o ../publish/server.exe
cp lib/objectbox.* ../publish/
cd ..
cd main
flutter pub get
flutter gen-l10n
flutter build web
cp -r ./build/web ../publish/
cd ..