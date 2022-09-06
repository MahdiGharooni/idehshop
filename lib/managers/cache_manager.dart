import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CacheManager extends BaseCacheManager {
  static CacheManager _instance;
  static final key = 'customCache';
  static final int maxNumberOfFiles = 40;
  static final Duration cacheTimeout = Duration(hours: 72);

  /// it doesn't allow to make new instance for every new cache
  factory CacheManager() {
    if (_instance == null) {
      _instance = new CacheManager._();
    }
    return _instance;
  }

  /// it assigns our customized cache duration and number
  CacheManager._()
      : super(key,
            maxNrOfCacheObjects: maxNumberOfFiles,
            maxAgeCacheObject: cacheTimeout);

  /// it returns our cache local path
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }

  /// main method of our caching system to separates structures
  /// for connection status. When we have connection if our json is OK we
  /// replace it to old one bit when server is down it returns backup json file
  /// and when we doesn't have connection it returns our old data cache.
  /// When [cacheable] is false it gets json directly from internet.
  Future<dynamic> cache(String url, bool cacheable, bool hasConnection) async {
    if (cacheable) {
      if (hasConnection) {
        var oldCached = await getFileFromCache(url);
        var newCached = await downloadFile(url);
        if (newCached == null) {
          if (oldCached == null) return null;
          var backupJsonFile =
          json.decode(await File(oldCached.file.path).readAsString());
          putFile(url, backupJsonFile);
          return backupJsonFile;
        }
        var newFileMeta =
        json.decode(await File(newCached.file.path).readAsString())['meta'];
        if (newFileMeta != null) {
          if (newFileMeta['status'] != 200) {
            if (oldCached == null) return null;
            var backupJsonFile =
            json.decode(await File(oldCached.file.path).readAsString());
            putFile(url, backupJsonFile);
            return backupJsonFile;
          }
        }
        return json.decode(await File(newCached.file.path).readAsString());
      } else {
        var cached = await getFileFromCache(url);
        if (cached == null) return null;
        return json.decode(await File(cached.file.path).readAsString());
      }
    } else {
      return json.decode((await http.get(url)).body);
    }
  }

  /// this method checks is url cached in our database or not
  Future<bool> isEmpty(String url) async {
    if ((await getFileFromCache(url)) == null) return true;
    return false;
  }

  /// when it doesn't have internet hasCache() checks our json data is existed?
  Future<bool> hasCache(String url) async {
    bool _hasHomeNews = await isEmpty(url);
    if (_hasHomeNews) return false;
    return true;
  }
}
