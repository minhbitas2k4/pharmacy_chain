import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/system_config_model.dart';

class SystemConfigService {
  SystemConfigService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  static const String _collectionName = 'system_configs';
  static const String _documentId = 'chain_defaults';

  FirebaseFirestore get _firestoreInstance {
    return _firestore ?? FirebaseFirestore.instance;
  }

  Future<SystemConfigModel> fetchConfig() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestoreInstance
        .collection(_collectionName)
        .doc(_documentId)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      return SystemConfigModel.fromMap(snapshot.data()!);
    }

    return const SystemConfigModel(
      startTime: '07:00',
      endTime: '22:00',
      appliedLabel: 'Đang áp dụng',
      daysLabel: 'Thứ 2 - CN',
      branchScope: 'Tất cả chi nhánh',
      roundingOption: 'Làm tròn 500đ',
      invoiceFormat: 'Định dạng hóa đơn chuẩn',
    );
  }

  Future<void> saveConfig(SystemConfigModel config, {String? updatedBy}) async {
    final data = config.toMap();
    data['config_key'] = 'store_open_hours';
    data['updated_at'] = FieldValue.serverTimestamp();
    if (updatedBy != null) {
      data['updated_by'] = updatedBy;
    }

    await _firestoreInstance.collection(_collectionName).doc(_documentId).set(
      data,
      SetOptions(merge: true),
    );
  }
}
