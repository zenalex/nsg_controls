import 'dart:async';
import 'dart:developer' as dev;

import 'package:cached_network_image_platform_interface/nsg_image_item.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class NsgImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'nsgImageCacheManager';

  /// Таймаут на отсутствие прогресса при скачивании. Если за это время
  /// не пришло ни DownloadProgress, ни FileInfo — стрим завершится ошибкой
  /// и downstream retry-логика перезапустит запрос.
  static const Duration _streamTimeout = Duration(seconds: 20);

  static final NsgImageCacheManager _instance = NsgImageCacheManager._();

  factory NsgImageCacheManager() {
    return _instance;
  }

  NsgImageCacheManager._() : super(Config(key));

  Stream<FileResponse> _withTimeout(Stream<FileResponse> source) {
    return source.timeout(_streamTimeout, onTimeout: (sink) {
      sink.addError(TimeoutException('NsgImageCacheManager: stalled download', _streamTimeout));
      sink.close();
    });
  }

  Stream<FileResponse> getFileStreamUsingDataItem(NsgImageItem image,
      {String? key, Map<String, String>? headers, bool withProgress = false, required ImageSize size}) async* {
    var newUrl = await _changeLink(image, size);

    yield* getFileStream(newUrl, key: key, headers: headers, withProgress: withProgress);
  }

  Stream<FileResponse> getImageFileUsingDataItem(NsgImageItem image,
      {String? key, Map<String, String>? headers, bool withProgress = false, required ImageSize size}) async* {
    var newUrl = await _changeLink(image, size);

    yield* getImageFile(newUrl, key: key, headers: headers, withProgress: withProgress);
  }

  @override
  Stream<FileResponse> getImageFile(String url, {String? key, Map<String, String>? headers, bool withProgress = false, int? maxHeight, int? maxWidth}) {
    return _withTimeout(super.getImageFile(url, key: key, headers: headers, withProgress: withProgress, maxHeight: maxHeight, maxWidth: maxWidth));
  }

  @override
  Stream<FileResponse> getFileStream(String url, {String? key, Map<String, String>? headers, bool withProgress = false}) {
    return _withTimeout(super.getFileStream(url, key: key, headers: headers, withProgress: withProgress));
  }

  Future<String> _changeLink(NsgImageItem image, ImageSize size) async {
    final url = image.globalFilePath(size);
    var newUrl = url;

    switch (size) {
      case ImageSize.medium:
        if (await isExist(image.globalFilePath(ImageSize.large))) {
          newUrl = image.globalFilePath(ImageSize.large);
        }
        break;

      case ImageSize.small:
        if (await isExist(image.globalFilePath(ImageSize.large))) {
          newUrl = image.globalFilePath(ImageSize.large);
          break;
        }
        if (await isExist(image.globalFilePath(ImageSize.medium))) {
          newUrl = image.globalFilePath(ImageSize.medium);
          break;
        }
        break;

      default:
        break;
    }

    if (newUrl != url) {
      dev.log('🔄 Подмена ссылки для кэша: \n оригинал: $url \n заменён:  $newUrl');
    }
    return newUrl;
  }

  Future<bool> isExist(String url) async {
    try {
      var cacheFile = await getFileFromCache(url);
      if (cacheFile != null) {
        return true;
      }
    } on Exception catch (ex) {
      dev.log(ex.toString());
    }
    return false;
  }
}
