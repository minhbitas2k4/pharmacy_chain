import 'package:flutter/material.dart';

import '../core/constants/app_roles.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/login_screen.dart';
import '../core/constants/app_strings.dart';
import '../features/dashboard/screens/chain_dashboard_screen.dart';
import '../features/purchase_orders/screens/purchase_order_screen.dart';
import '../features/inventory/screens/warehouse_alert_screen.dart';
import '../features/inventory/screens/inventory_review_screen.dart';
import '../features/inventory/screens/stock_in_out_screen.dart';
import '../features/branches/screens/branch_screen.dart';
import '../features/shifts/screens/shift_management_screen.dart';
import '../features/shifts/screens/shift_handover_screen.dart';
import '../features/suppliers/screens/supplier_screen.dart';
import '../features/user_permissions/screens/user_permission_screen.dart';
import '../features/audit_logs/screens/audit_log_screen.dart';
import '../features/system_config/screens/system_config_screen.dart';
import '../features/notifications/screens/maintenance_notice_screen.dart';
import '../features/pricing_policy/screens/pricing_policy_screen.dart';
import '../features/drugs/screens/drug_catalog_screen.dart';
import '../features/pharmacist/screens/pharmacist_drug_lookup_screen.dart';
import '../features/pos/screens/pos_screen.dart';
import '../features/pos/models/cart_item_model.dart';
import '../features/payment/screens/payment_screen.dart';
import '../features/invoices/screens/invoice_screen.dart';
import '../features/employees/screens/employee_profile_screen.dart';
import '../features/schedules/screens/work_schedule_screen.dart';
import '../features/home/screens/home_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const chainDashboard = '/chain-dashboard';
  static const purchaseOrders = '/purchase-orders';
  static const warehouseAlert = '/warehouse-alert';
  static const inventoryReview = '/inventory-review';
  static const stockInOut = '/stock-in-out';
  static const suppliers = '/suppliers';
  static const userPermissions = '/user-permissions';
  static const auditLogs = '/audit-logs';
  static const systemConfig = '/system-config';
  static const maintenanceNotice = '/maintenance-notice';
  static const notifications = '/notifications';
  static const pricingPolicy = '/pricing-policy';
  static const drugCatalog = '/drug-catalog';
  static const drugLookup = '/drug-lookup';
  static const drugs = '/drugs';
  static const inventory = '/inventory';
  static const branch = '/branch';
  static const branches = '/branches';
  static const shiftManagement = '/shift-management';
  static const shiftHandover = '/shift-handover';
  static const shifts = '/shifts';
  static const pos = '/pos';
  static const payment = '/payment';
  static const invoice = '/invoice';
  static const invoices = '/invoices';
  static const employeeProfile = '/employee-profile';
  static const employees = '/employees';
  static const workSchedule = '/work-schedule';
  static const schedules = '/schedules';
  static const home = "/home";

  /// Map roles to their permitted routes
  static const Map<String, List<String>> rolePermissions = {
    AppRoles.systemAdmin: [
      systemConfig,
      userPermissions,
      auditLogs,
      maintenanceNotice,
      notifications,
    ],
    AppRoles.chainManager: [
      chainDashboard,
      pricingPolicy,
      drugCatalog,
      drugs,
      warehouseAlert,
      inventory,
    ],
    AppRoles.branchManager: [
      branch,
      branches,
      inventoryReview,
      shiftManagement,
      shiftHandover,
      shifts,
    ],
    AppRoles.purchasingManager: [
      purchaseOrders,
      suppliers,
      payment,
    ],
    AppRoles.pharmacist: [
      drugLookup,
    ],
    AppRoles.cashier: [
      pos,
      payment,
      invoice,
      invoices,
    ],
    AppRoles.warehouseStaff: [
      stockInOut,
      inventory,
    ],
    AppRoles.hrAdmin: [
      employeeProfile,
      employees,
      workSchedule,
      schedules,
      shiftManagement,
    ],
  };

  static String getHomeRoute(String role) {
    // If it's a manager role that has a dashboard, go there
    if (role == AppRoles.chainManager) return chainDashboard;
    // Otherwise, all roles go to the common Home/Hub screen which will be filtered
    return home;
  }

  static bool hasAccess(String role, String route) {
    if (route == login || route == home) return true;
    final allowed = rolePermissions[role];
    return allowed?.contains(route) ?? false;
  }

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    dashboard: (_) => const ChainDashboardScreen(),
    chainDashboard: (_) => const ChainDashboardScreen(),
    purchaseOrders: (_) => const PurchaseOrderScreen(),
    warehouseAlert: (_) => const WarehouseAlertScreen(),
    inventory: (_) => const WarehouseAlertScreen(),
    inventoryReview: (_) => const InventoryReviewScreen(),
    stockInOut: (_) => const StockInOutScreen(),
    suppliers: (_) => const SupplierScreen(),
    userPermissions: (_) => const UserPermissionScreen(),
    auditLogs: (_) => const AuditLogScreen(),
    systemConfig: (_) => const SystemConfigScreen(),
    maintenanceNotice: (_) => const MaintenanceNoticeScreen(),
    notifications: (_) => const MaintenanceNoticeScreen(),
    pricingPolicy: (_) => const PricingPolicyScreen(),
    drugCatalog: (_) => const DrugCatalogScreen(),
    drugLookup: (_) => const PharmacistDrugLookupScreen(),
    drugs: (_) => const DrugCatalogScreen(),
    branch: (_) => const BranchScreen(),
    branches: (_) => const BranchScreen(),
    shiftManagement: (_) => const ShiftManagementScreen(),
    shiftHandover: (_) => const ShiftHandoverScreen(),
    shifts: (_) => const ShiftManagementScreen(),
    pos: (_) => const PosScreen(),
    // payment: (_) => const PaymentScreen(cartTotal: 0, items: <CartItemModel>[]),
    invoice: (_) => const InvoiceScreen(),
    invoices: (_) => const InvoiceScreen(),
    employeeProfile: (_) => const EmployeeProfileScreen(),
    employees: (_) => const EmployeeProfileScreen(),
    workSchedule: (_) => const WorkScheduleScreen(),
    schedules: (_) => const WorkScheduleScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final WidgetBuilder? builder = routes[settings.name];
    
    // Check access
    if (settings.name != login && settings.name != null) {
      final user = AuthController().currentUser;
      if (user != null && !hasAccess(user.role, settings.name!)) {
        return MaterialPageRoute<void>(
          builder: (_) => _AccessDeniedScreen(routeName: settings.name!),
          settings: settings,
        );
      }
    }

    if (builder == null) {
      return MaterialPageRoute<void>(
        builder: (_) => const _StubScreen(title: AppStrings.appName),
        settings: settings,
      );
    }
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  final String routeName;
  const _AccessDeniedScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truy cập bị từ chối')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Bạn không có quyền truy cập vào chức năng này.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title đang được hoàn thiện',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
