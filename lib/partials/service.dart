import 'package:bsi_dart/bsi_dart.dart';

class OsumPieService extends Service {
  /// The private generative constructor for singleton implementation.
  OsumPieService._();

  /// The singleton instance of OsumPieService.
  static final instance = OsumPieService._();

  /// Factory constructor that redirects to the singleton instance.
  factory OsumPieService() => instance;

  @override
  ServiceReference get reference => ServiceReference.root('osumpie');
}
