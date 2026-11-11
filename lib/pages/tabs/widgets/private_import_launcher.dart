import 'package:flutter/material.dart';

import '../../../data/services/yt_dlp_service.dart';
import 'private_import_sheet.dart';

Future<bool> showPrivateImportSheet(
  BuildContext context, {
  YtDlpService? service,
}) async {
  final bool? imported = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return PrivateImportSheet(service: service ?? DirectYtDlpService());
    },
  );
  return imported ?? false;
}
