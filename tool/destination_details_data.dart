import 'destination_detail_entry.dart';
import 'destination_details_part1.dart';
import 'destination_details_part2.dart';
import 'destination_details_part3.dart';
import 'destination_details_part4.dart';

export 'destination_detail_entry.dart';

/// Dataset Lengkap 50 Destinasi Wisata Indonesia TRIDE:
/// - 50 Short Descriptions
/// - 150 Hal Menarik (Attractions)
/// - 150 Tempat Menginap (Accommodations)
/// - 150 Kuliner Lokal (Local Foods)
final List<DestinationDetailEntry> destinationDetailsData = [
  ...javaDetails,
  ...baliNusaDetails,
  ...sumatraKalimantanDetails,
  ...sulawesiMalukuPapuaDetails,
];
