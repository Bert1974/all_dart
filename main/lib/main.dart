export 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'src/settings/authentication.dart';
export 'src/settings/theme_controller.dart';

export 'main.stub.dart'
    if (dart.library.io) 'main.desktop.dart'
    if (dart.library.js) 'main.web.dart';

export 'src/snackbar.dart';
