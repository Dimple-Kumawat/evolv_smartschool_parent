// attachment.dart

class Attachment {
  final String imageName;
  final double fileSize;

  Attachment({required this.imageName, required this.fileSize});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      imageName: json['image_name'],
      fileSize: double.tryParse(json['file_size'].toString()) ?? 0.0,
    );
  }
}
