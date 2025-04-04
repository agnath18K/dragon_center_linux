import 'dart:async';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';

class ECHelper {
  static const String _ecIoFile = '/dev/ec0';

  static final _lock = Lock();

  static Future<void> write(int address, int value) async {
    await _lock.synchronized(() async {
      logger.info('EC Write Operation:');
      logger.info('  Address: 0x${address.toRadixString(16).padLeft(2, '0')}');
      logger.info(
          '  Value: 0x${value.toRadixString(16).padLeft(2, '0')} ($value decimal)');

      final file = await File(_ecIoFile).open(mode: FileMode.write);
      try {
        await file.setPosition(address);
        await file.writeFrom([value]);
        logger.info('  Status: Success');
      } catch (e) {
        logger.severe('  Status: Failed');
        logger.severe('  Error: $e');
        rethrow;
      } finally {
        await file.close();
      }
    });
  }

  static Future<int> read(int address) async {
    return await _lock.synchronized(() async {
      logger.info('EC Read Operation:');
      logger.info('  Address: 0x${address.toRadixString(16).padLeft(2, '0')}');

      final file = await File(_ecIoFile).open();
      try {
        await file.setPosition(address);
        final value = await file.read(1);
        final result = value.isEmpty ? 0 : value[0];
        logger.info(
            '  Value: 0x${result.toRadixString(16).padLeft(2, '0')} ($result decimal)');
        logger.info('  Status: Success');
        return result;
      } catch (e) {
        logger.severe('  Status: Failed');
        logger.severe('  Error: $e');
        rethrow;
      } finally {
        await file.close();
      }
    });
  }

  static Future<int> readRPM(int address) async {
    return await _lock.synchronized(() async {
      logger.info('EC RPM Read Operation:');
      logger.info('  Address: 0x${address.toRadixString(16).padLeft(2, '0')}');

      final file = await File(_ecIoFile).open();
      try {
        await file.setPosition(address);
        final bytes = await file.read(2);
        if (bytes.length < 2) {
          logger.warning('  Status: Incomplete read');
          logger.warning('  Bytes read: ${bytes.length}');
          return 0;
        }
        final result = bytes[1];
        logger.info(
            '  Raw bytes: [0x${bytes[0].toRadixString(16).padLeft(2, '0')}, 0x${bytes[1].toRadixString(16).padLeft(2, '0')}]');
        logger.info('  Calculated RPM: $result');
        logger.info('  Status: Success');
        return result;
      } catch (e) {
        logger.severe('  Status: Failed');
        logger.severe('  Error: $e');
        rethrow;
      } finally {
        await file.close();
      }
    });
  }
}
