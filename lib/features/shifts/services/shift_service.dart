import '../models/shift_handover_model.dart';
import '../models/shift_model.dart';
import '../models/shift_request_model.dart';

class ShiftService {
  Future<List<ShiftModel>> fetchWeeklySchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const <ShiftModel>[
      ShiftModel(
        name: 'Nguyễn Thị Lan',
        time: '07:00 - 15:00',
        status: 'Ca sáng',
      ),
      ShiftModel(
        name: 'Trần Văn Minh',
        time: '15:00 - 22:00',
        status: 'Ca chiều',
      ),
      ShiftModel(name: 'Lê Thị Hoa', time: 'Nghỉ phép', status: 'Nghỉ phép'),
    ];
  }

  Future<List<ShiftRequestModel>> fetchRequests(ShiftRequestType type) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    switch (type) {
      case ShiftRequestType.changeShift:
        return const <ShiftRequestModel>[
          ShiftRequestModel(
            name: 'Trần Văn Minh',
            description: 'muốn đổi ca với Nguyễn Thị Lan',
            type: ShiftRequestType.changeShift,
            status: ShiftRequestStatus.pending,
          ),
        ];
      case ShiftRequestType.leave:
        return const <ShiftRequestModel>[
          ShiftRequestModel(
            name: 'Lê Thị Hoa',
            description: 'xin nghỉ 10/07/2025',
            type: ShiftRequestType.leave,
            status: ShiftRequestStatus.pending,
          ),
        ];
    }
  }

  Future<ShiftHandoverModel> fetchHandover() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const ShiftHandoverModel(
      currentShift: 'Ca sáng 07:00 - 15:00',
      cashier: 'Trần Văn Minh',
      invoiceCount: 128,
      systemCash: '8.500.000đ',
      qrPayment: '12.300.000đ',
      cardPayment: '4.200.000đ',
      totalRevenue: '25.000.000đ',
    );
  }
}
