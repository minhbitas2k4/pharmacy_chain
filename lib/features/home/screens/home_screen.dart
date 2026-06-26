import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthController().currentUser;
    final role = user?.role ?? '';
    final allowedRoutes = AppRoutes.rolePermissions[role] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        onProfilePressed: () {
          // TODO: Navigate to profile
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Xin chào, ${user?.displayName ?? 'Người dùng'}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getRoleLabel(role),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.pharmaGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: allowedRoutes.length,
                itemBuilder: (context, index) {
                  final route = allowedRoutes[index];
                  final feature = _getFeatureInfo(route);
                  
                  return _FeatureCard(
                    title: feature.title,
                    icon: feature.icon,
                    color: feature.color,
                    onTap: () => Navigator.pushNamed(context, route),
                  );
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Đăng xuất',
                onPressed: () async {
                   await AuthController().logout();
                   if (context.mounted) {
                     Navigator.pushReplacementNamed(context, AppRoutes.login);
                   }
                },
                backgroundColor: Colors.grey[200],
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'SystemAdmin': return 'Quản trị hệ thống';
      case 'ChainManager': return 'Quản lý chuỗi';
      case 'BranchManager': return 'Quản lý chi nhánh';
      case 'PurchasingManager': return 'Quản lý mua hàng';
      case 'Pharmacist': return 'Dược sĩ';
      case 'Cashier': return 'Thu ngân';
      case 'WarehouseStaff': return 'Nhân viên kho';
      case 'HrAdmin': return 'Nhân sự / Admin';
      default: return 'Nhân viên';
    }
  }

  _FeatureInfo _getFeatureInfo(String route) {
    switch (route) {
      case AppRoutes.systemConfig:
        return _FeatureInfo('Cấu hình hệ thống', Icons.settings_outlined, Colors.blue);
      case AppRoutes.userPermissions:
        return _FeatureInfo('Phân quyền', Icons.admin_panel_settings_outlined, Colors.indigo);
      case AppRoutes.auditLogs:
        return _FeatureInfo('Nhật ký hệ thống', Icons.history_outlined, Colors.grey);
      case AppRoutes.maintenanceNotice:
      case AppRoutes.notifications:
        return _FeatureInfo('Thông báo bảo trì', Icons.notification_important_outlined, Colors.orange);
      case AppRoutes.chainDashboard:
        return _FeatureInfo('Dashboard', Icons.dashboard_outlined, Colors.teal);
      case AppRoutes.pricingPolicy:
        return _FeatureInfo('Chính sách giá', Icons.payments_outlined, Colors.green);
      case AppRoutes.drugCatalog:
      case AppRoutes.drugs:
        return _FeatureInfo('Danh mục thuốc', Icons.medication_outlined, Colors.blue);
      case AppRoutes.warehouseAlert:
        return _FeatureInfo('Cảnh báo kho', Icons.warning_amber_outlined, Colors.red);
      case AppRoutes.branch:
      case AppRoutes.branches:
        return _FeatureInfo('Chi nhánh', Icons.storefront_outlined, Colors.purple);
      case AppRoutes.inventoryReview:
        return _FeatureInfo('Duyệt kho', Icons.check_circle_outline, Colors.teal);
      case AppRoutes.shiftManagement:
      case AppRoutes.shifts:
        return _FeatureInfo('Quản lý ca', Icons.schedule_outlined, Colors.cyan);
      case AppRoutes.shiftHandover:
        return _FeatureInfo('Bàn giao ca', Icons.sync_alt_outlined, Colors.blueGrey);
      case AppRoutes.purchaseOrders:
        return _FeatureInfo('Đơn mua hàng', Icons.shopping_cart_outlined, Colors.amber);
      case AppRoutes.suppliers:
        return _FeatureInfo('Nhà cung cấp', Icons.business_outlined, Colors.deepOrange);
      case AppRoutes.drugLookup:
        return _FeatureInfo('Tra cứu thuốc', Icons.search_outlined, Colors.blue);
      case AppRoutes.pos:
        return _FeatureInfo('Bán hàng (POS)', Icons.point_of_sale_outlined, Colors.green);
      case AppRoutes.invoice:
      case AppRoutes.invoices:
        return _FeatureInfo('Hóa đơn', Icons.receipt_long_outlined, Colors.blueGrey);
      case AppRoutes.stockInOut:
        return _FeatureInfo('Nhập/Xuất kho', Icons.swap_vert_outlined, Colors.brown);
      case AppRoutes.inventory:
        return _FeatureInfo('Kiểm kê kho', Icons.inventory_2_outlined, Colors.orange);
      case AppRoutes.employeeProfile:
      case AppRoutes.employees:
        return _FeatureInfo('Hồ sơ nhân sự', Icons.people_outline, Colors.indigo);
      case AppRoutes.workSchedule:
      case AppRoutes.schedules:
        return _FeatureInfo('Lịch làm việc', Icons.calendar_today_outlined, Colors.deepPurple);
      default:
        return _FeatureInfo('Chức năng', Icons.extension_outlined, Colors.blueGrey);
    }
  }
}

class _FeatureInfo {
  final String title;
  final IconData icon;
  final Color color;

  _FeatureInfo(this.title, this.icon, this.color);
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Add a simple AppButton since I might not have imported it correctly or it might be needed
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.pharmaGreen,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
