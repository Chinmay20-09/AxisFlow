ImportService added: lib/data/services/import_service.dart
UI screen: lib/ui/screens/import_screen.dart
Remember to run:
  flutter pub get
to fetch file_picker dependency added to pubspec.yaml.

Notes:
- The ImportScreen uses FilePicker to select CSV files exported by AxisFlow.
- The ImportService.previewCsv parses and validates rows. ImportService.importTransactions writes to TransactionDB and optionally calls a provided callback to reload the controller.
- The settings screen was updated to provide a "Import CSV" action.

Next steps: run flutter analyze and flutter test locally to verify compile.
