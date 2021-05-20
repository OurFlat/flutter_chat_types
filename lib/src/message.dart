import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'preview_data.dart' show PreviewData;
import 'util.dart';

/// All possible message types.
enum MessageType { file, image, text, audio }

/// All possible statuses message can have.
enum Status { delivered, error, read, sending }

/// An abstract class that contains all variables and methods
/// every message will have.
@immutable
abstract class Message extends Equatable implements Comparable {
  const Message(
    this.authorId,
    this.id,
    this.metadata,
    this.status,
    this.timestamp,
    this.type,
    this.editedAt,
  );

  /// Creates a particular message from a map (decoded JSON).
  /// Type is determined by the `type` field.
  factory Message.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'error';

    switch (type) {
      case 'file':
        return FileMessage.fromJson(json);
      case 'image':
        return ImageMessage.fromJson(json);
      case 'text':
        return TextMessage.fromJson(json);
      case 'audio':
        return AudioMessage.fromJson(json);
      default:
        throw ArgumentError('Unsupported message type');
    }
  }

  /// Should be able to update all fields
  Message copyWith({
    String? authorId,
    String? id,
    Map<String, dynamic>? metadata,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
  });

  /// Converts a particular message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson();

  /// ID of the user who sent this message
  final String authorId;

  /// Unique ID of the message
  final String id;

  /// Additional custom metadata or attributes related to the message
  final Map<String, dynamic>? metadata;

  /// Message [Status]
  final Status? status;

  /// Timestamp in milliseconds
  final int? timestamp;

  /// [MessageType]
  final MessageType type;

  /// The date when this message was last edited, used for cache
  final Timestamp? editedAt;

  @override
  // ignore: type_annotate_public_apis
  int compareTo(other) => other.timestamp.compareTo(timestamp);
}

/// A class that represents text message.
@immutable
class TextMessage extends Message {
  /// Creates a text message.
  const TextMessage({
    required String authorId,
    required String id,
    Map<String, dynamic>? metadata,
    this.previewData,
    Status? status,
    required this.text,
    int? timestamp,
    Timestamp? editedAt,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.text, editedAt);

  /// Creates a text message from a map (decoded JSON).
  TextMessage.fromJson(Map<String, dynamic> json)
      : previewData =
            json['previewData'] == null ? null : PreviewData.fromJson(json['previewData'] as Map<String, dynamic>),
        text = json['text'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.text,
          (json['editedAt'] as Timestamp?) ?? Timestamp.fromMillisecondsSinceEpoch(0),
        );

  /// See [PreviewData]
  final PreviewData? previewData;

  /// User's message
  final String text;

  /// Converts a text message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'id': id,
        'metadata': metadata,
        'previewData': previewData?.toJson(),
        'text': text,
        'timestamp': timestamp,
        'type': 'text',
        'editedAt': FieldValue.serverTimestamp(),
      };

  @override
  TextMessage copyWith({
    String? authorId,
    String? id,
    Map<String, dynamic>? metadata,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    PreviewData? previewData,
    String? text,
  }) =>
      TextMessage(
        authorId: authorId ?? this.authorId,
        id: id ?? this.id,
        metadata: metadata ?? this.metadata,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        editedAt: editedAt ?? this.editedAt,
        previewData: previewData ?? this.previewData,
        text: text ?? this.text,
      );

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        id,
        metadata,
        previewData,
        status,
        text,
        timestamp,
        editedAt,
      ];
}

/// A class that represents file message.
@immutable
class FileMessage extends Message {
  /// Creates a file message.
  const FileMessage({
    required String authorId,
    required this.fileName,
    required String id,
    Map<String, dynamic>? metadata,
    this.mimeType,
    required this.size,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    required this.uri,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.file, editedAt);

  /// Creates a file message from a map (decoded JSON).
  FileMessage.fromJson(Map<String, dynamic> json)
      : fileName = json['fileName'] as String,
        mimeType = json['mimeType'] as String?,
        size = json['size'].round() as int,
        uri = json['uri'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.file,
          (json['editedAt'] as Timestamp?) ?? Timestamp.fromMillisecondsSinceEpoch(0),
        );

  /// The name of the file
  final String fileName;

  /// Media type
  final String? mimeType;

  /// Size of the file in bytes
  final int size;

  /// The file source (either a remote URL or a local resource)
  final String uri;

  /// Converts a file message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'fileName': fileName,
        'id': id,
        'metadata': metadata,
        'mimeType': mimeType,
        'size': size,
        'timestamp': timestamp,
        'type': 'file',
        'uri': uri,
        'editedAt': FieldValue.serverTimestamp(),
      };

  @override
  FileMessage copyWith({
    String? authorId,
    String? id,
    Map<String, dynamic>? metadata,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    String? fileName,
    String? mimeType,
    int? size,
    String? uri,
  }) =>
      FileMessage(
        authorId: authorId ?? this.authorId,
        id: id ?? this.id,
        metadata: metadata ?? this.metadata,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        editedAt: editedAt ?? this.editedAt,
        fileName: fileName ?? this.fileName,
        mimeType: mimeType ?? this.mimeType,
        size: size ?? this.size,
        uri: uri ?? this.uri,
      );

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        fileName,
        id,
        metadata,
        mimeType,
        size,
        status,
        timestamp,
        uri,
        editedAt,
      ];
}

/// A class that represents image message.
@immutable
class ImageMessage extends Message {
  /// Creates an image message.
  const ImageMessage({
    required String authorId,
    this.height,
    required String id,
    required this.imageName,
    Map<String, dynamic>? metadata,
    required this.size,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    required this.uri,
    this.width,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.image, editedAt);

  /// Creates an image message from a map (decoded JSON).
  ImageMessage.fromJson(Map<String, dynamic> json)
      : height = json['height']?.toDouble() as double?,
        imageName = json['imageName'] as String,
        size = json['size'].round() as int,
        uri = json['uri'] as String,
        width = json['width']?.toDouble() as double?,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.image,
          (json['editedAt'] as Timestamp?) ?? Timestamp.fromMillisecondsSinceEpoch(0),
        );

  /// Image height in pixels
  final double? height;

  /// The name of the image
  final String imageName;

  /// Size of the image in bytes
  final int size;

  /// The image source (either a remote URL or a local resource)
  final String uri;

  /// Image width in pixels
  final double? width;

  /// Converts an image message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'height': height,
        'id': id,
        'imageName': imageName,
        'metadata': metadata,
        'size': size,
        'timestamp': timestamp,
        'type': 'image',
        'uri': uri,
        'width': width,
        'editedAt': FieldValue.serverTimestamp(),
      };

  @override
  ImageMessage copyWith({
    String? authorId,
    String? id,
    Map<String, dynamic>? metadata,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    double? height,
    String? imageName,
    int? size,
    String? uri,
    double? width,
  }) {
    return ImageMessage(
      authorId: authorId ?? this.authorId,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      height: height ?? this.height,
      imageName: imageName ?? this.imageName,
      size: size ?? this.size,
      uri: uri ?? this.uri,
      width: width ?? this.width,
    );
  }

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        height,
        id,
        imageName,
        metadata,
        size,
        status,
        timestamp,
        uri,
        width,
        editedAt,
      ];
}

/// A class that represents audio message.
@immutable
class AudioMessage extends Message {
  /// Creates an audio message.
  const AudioMessage({
    required String authorId,
    required this.length,
    required String id,
    Map<String, dynamic>? metadata,
    this.mimeType,
    this.waveForm,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    required this.uri,
  }) : super(authorId, id, metadata, status, timestamp, MessageType.audio, editedAt);

  /// Creates an audio message from a map (decoded JSON).
  AudioMessage.fromJson(Map<String, dynamic> json)
      : length = Duration(milliseconds: json['length'] as int),
        mimeType = json['mimeType'] as String?,
        waveForm = json['waveForm'] as List<double>,
        uri = json['uri'] as String,
        super(
          json['authorId'] as String,
          json['id'] as String,
          json['metadata'] as Map<String, dynamic>?,
          getStatusFromString(json['status'] as String?),
          json['timestamp'] as int?,
          MessageType.audio,
          (json['editedAt'] as Timestamp?) ?? Timestamp.fromMillisecondsSinceEpoch(0),
        );

  /// Converts an audio message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'length': length.inMilliseconds,
        'id': id,
        'metadata': metadata,
        'mimeType': mimeType,
        'waveForm': waveForm,
        'timestamp': timestamp,
        'type': 'audio',
        'uri': uri,
        'editedAt': FieldValue.serverTimestamp(),
      };

  @override
  AudioMessage copyWith({
    String? authorId,
    String? id,
    Map<String, dynamic>? metadata,
    Status? status,
    int? timestamp,
    Timestamp? editedAt,
    Duration? length,
    String? mimeType,
    List<double>? waveForm,
    String? uri,
  }) =>
      AudioMessage(
        authorId: authorId ?? this.authorId,
        id: id ?? this.id,
        metadata: metadata ?? this.metadata,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        editedAt: editedAt ?? this.editedAt,
        length: length ?? this.length,
        mimeType: mimeType ?? this.mimeType,
        waveForm: waveForm ?? this.waveForm,
        uri: uri ?? this.uri,
      );

  /// Equatable props
  @override
  List<Object?> get props => [
        authorId,
        length,
        id,
        metadata,
        mimeType,
        status,
        timestamp,
        uri,
        editedAt,
      ];

  /// The length of the audio
  final Duration length;

  /// Media type
  final String? mimeType;

  /// Wave form represented as a list of decibel level, each comprised between 0 and 120
  final List<double>? waveForm;

  /// The audio source (either a remote URL or a local resource)
  final String uri;
}
