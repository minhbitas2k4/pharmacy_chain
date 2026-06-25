// import '../models/shift_model.dart';
import '../models/work_schedule_model.dart';

class ScheduleService {
  Future<List<WorkScheduleModel>> fetchMonth() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return List<WorkScheduleModel>.generate(
      31,
      (int index) =>
          WorkScheduleModel(day: index + 1, isSelected: index + 1 == 10),
    );
  }

  // Future<List<ShiftModel>> fetchTodayShifts() async {
  //   await Future<void>.delayed(const Duration(milliseconds: 450));
  //   return const <ShiftModel>[
  //     ShiftModel(
  //       name: 'Nguyễn Thị Lan',
  //       time: '07:00-15:00',
  //       status: 'Ca sáng',
  //     ),
  //     ShiftModel(
  //       name: 'Trần Văn Minh',
  //       time: '15:00-22:00',
  //       status: 'Ca chiều',
  //     ),
  //     ShiftModel(name: 'Lê Thị Hoa', time: 'Nghỉ phép', status: 'Nghỉ phép'),
  //   ];
  // }
}
