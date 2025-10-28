import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/src/image_provider/nsg_image_cache_manager.dart';
import 'package:cached_network_image_platform_interface'
    '/cached_network_image_platform_interface.dart' as platform show ImageLoader;
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:cached_network_image_platform_interface/nsg_image_item.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// ImageLoader class to load images on IO platforms.
class ImageLoader implements platform.ImageLoader {
  @Deprecated('Use loadImageAsync instead')
  @override
  Stream<ui.Codec> loadBufferAsync(
    String url,
    String? cacheKey,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderBufferCallback decode,
    BaseCacheManager cacheManager,
    int? maxHeight,
    int? maxWidth,
    Map<String, String>? headers,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    VoidCallback evictImage,
  ) {
    return _load(
      url,
      cacheKey,
      chunkEvents,
      (bytes) async {
        final buffer = await ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      },
      cacheManager,
      maxHeight,
      maxWidth,
      headers,
      imageRenderMethodForWeb,
      evictImage,
    );
  }

  @override
  Stream<ui.Codec> loadImageAsync(
    String url,
    String? cacheKey,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
    BaseCacheManager cacheManager,
    int? maxHeight,
    int? maxWidth,
    Map<String, String>? headers,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    VoidCallback evictImage,
  ) {
    return _load(
      url,
      cacheKey,
      chunkEvents,
      (bytes) async {
        final buffer = await ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      },
      cacheManager,
      maxHeight,
      maxWidth,
      headers,
      imageRenderMethodForWeb,
      evictImage,
    );
  }

  Stream<ui.Codec> _load(
    String url,
    String? cacheKey,
    StreamController<ImageChunkEvent> chunkEvents,
    Future<ui.Codec> Function(Uint8List) decode,
    BaseCacheManager cacheManager,
    int? maxHeight,
    int? maxWidth,
    Map<String, String>? headers,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    VoidCallback evictImage,
  ) async* {
    try {
      assert(
        cacheManager is ImageCacheManager || (maxWidth == null && maxHeight == null),
        'To resize the image with a CacheManager the '
        'CacheManager needs to be an ImageCacheManager. maxWidth and '
        'maxHeight will be ignored when a normal CacheManager is used.',
      );

      final Stream<FileResponse> stream = cacheManager is ImageCacheManager
          ? cacheManager.getImageFile(url, maxHeight: maxHeight, maxWidth: maxWidth, withProgress: true, headers: headers, key: cacheKey)
          : cacheManager.getFileStream(url, withProgress: true, headers: headers, key: cacheKey);

      await for (final result in stream) {
        if (result is DownloadProgress) {
          chunkEvents.add(ImageChunkEvent(cumulativeBytesLoaded: result.downloaded, expectedTotalBytes: result.totalSize));
        }
        if (result is FileInfo) {
          final file = result.file;
          final bytes = await file.readAsBytes();
          final decoded = await decode(bytes);
          yield decoded;
        }
      }
    } on Object catch (error, stackTrace) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        evictImage();
      });
      yield* Stream.error(error, stackTrace);
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  Stream<ui.Codec> loadImageFromNsgItemAsync(
      NsgImageItem item,
      String? cacheKey,
      StreamController<ImageChunkEvent> chunkEvents,
      ImageDecoderCallback decode,
      BaseCacheManager cacheManager,
      int? maxHeight,
      int? maxWidth,
      Map<String, String>? headers,
      ImageRenderMethodForWeb imageRenderMethodForWeb,
      ui.VoidCallback evictImage,
      ImageSize size) {
    return _loadFromNsgImage(item, cacheKey, chunkEvents, (bytes) async {
      final buffer = await ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    }, cacheManager, maxHeight, maxWidth, headers, imageRenderMethodForWeb, evictImage, size);
  }

  // ignore: unused_element
  Stream<ui.Codec> _loadFromNsgImage(
      NsgImageItem item,
      String? cacheKey,
      StreamController<ImageChunkEvent> chunkEvents,
      Future<ui.Codec> Function(Uint8List) decode,
      BaseCacheManager cacheManager,
      int? maxHeight,
      int? maxWidth,
      Map<String, String>? headers,
      ImageRenderMethodForWeb imageRenderMethodForWeb,
      VoidCallback evictImage,
      ImageSize size) async* {
    try {
      assert(
        cacheManager is ImageCacheManager || (maxWidth == null && maxHeight == null),
        'To resize the image with a CacheManager the '
        'CacheManager needs to be an ImageCacheManager. maxWidth and '
        'maxHeight will be ignored when a normal CacheManager is used.',
      );
      assert(cacheManager is NsgImageCacheManager || (maxWidth == null && maxHeight == null), 'cacheManager должен быть NsgImageCacheManager');

      final Stream<FileResponse> stream = cacheManager is ImageCacheManager
          ? (cacheManager as NsgImageCacheManager).getImageFileUsingDataItem(
              item,
              size: size,
            )
          : (cacheManager as NsgImageCacheManager).getFileStreamUsingDataItem(
              item,
              size: size,
            );

      await for (final result in stream) {
        if (result is DownloadProgress) {
          chunkEvents.add(ImageChunkEvent(cumulativeBytesLoaded: result.downloaded, expectedTotalBytes: result.totalSize));
        }
        if (result is FileInfo) {
          final file = result.file;
          final bytes = await file.readAsBytes();
          final decoded = await decode(bytes);
          yield decoded;
        }
      }
    } on Object catch (error, stackTrace) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        evictImage();
      });
      yield* Stream.error(error, stackTrace);
    } finally {
      await chunkEvents.close();
    }
  }
}
