mkdir publish
cd data
dart pub get
dart run build_runner build
cd ..
cd server
dart pub get
bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-go/main/install.sh)
dart run build_runner build
dart compile exe bin/server.dart -o ../publish/server.exe
cp lib/objectbox.* ../publish/
cp objectboxlib/lib/objectbox.* ../publish/
cp config.json ../publish/
ls lib
cd ..
cd main
flutter pub get
flutter gen-l10n
flutter build web
cp -r ./build/web ../publish/
cd ..
cp start.sh publish/