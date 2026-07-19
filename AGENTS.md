# AGENTS.md - Pharmacy Chain Project Context

## Project Overview
- **Tên:** PharmaChain - Hệ thống quản lý chuỗi nhà thuốc
- **Framework:** Flutter (Dart SDK ^3.11.5)
- **Backend:** Firebase BaaS (Firestore + Firebase Auth)
- **Firebase Project:** `pharmacy-chain-managemen-ff760`
- **Architecture:** Feature-first + ChangeNotifier state management
- **Locale:** Vietnamese

## Technology Stack
- `firebase_core: ^4.4.0`
- `firebase_auth: ^6.1.4`
- `cloud_firestore: ^6.0.1`
- Material 3 (`useMaterial3: true`)

## User Roles (5 roles)
1. **SystemAdmin** - System config, RBAC, Audit Log, Push Notification
2. **ChainManager** - Dashboard, pricing policy, drug catalog, expiry alerts
3. **BranchManager** - Branch overview, inventory, shifts, handover
4. **Pharmacist** - Drug lookup, drug interaction warnings, POS/payment
5. **HrAdmin** - Employee profiles, work schedules, attendance

## Firestore Live Schema (Verified 2026-07-19)

> **IMPORTANT:** All branch-scoped queries use `branch_id = "branch_hcm_q1"`.
> Many numeric fields are stored as **String** in Firestore and parsed in Dart code.
> Use `firebase-admin` SDK (Node.js) to query Firestore from scripts: `serviceAccountKey.json` in project root.

### users/{uid} — 6 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| uid | string | `Ikdw7Hbh0vgosRqE6SpGqF2evz83` | = document ID |
| email | string | `branchmanager@pharmacy.com` | |
| displayName | string | `Branch Manager` | |
| role | string | `branch_manager` | **Lowercase only**: `system_admin`, `chain_manager`, `branch_manager`, `pharmacist`, `cashier`, `warehouse_staff` |
| status | string | `ACTIVE` | `ACTIVE` or `active` |
| branchId | string? | `branch_hcm_q1` | `null` for system-wide roles (system_admin, chain_manager) |
| phone | string? | `0901234567` | |

**Documents:**
- `Ikdw7Hbh0vgosRqE6SpGqF2evz83` → branch_manager, branch_hcm_q1
- `RqK8Yr7GymafZZfSYqoHr9hWZ8d2` → system_admin, branchId=null
- `vEC8noEOHefBIEnlgqaJ2B38TA43` → chain_manager, branchId=null
- `user_002` → cashier, branch_hcm_q1
- `user_003` → pharmacist, branch_hcm_q1
- `user_004` → warehouse_staff, branch_hcm_q1

### branches/{branch_id} — 1 doc

| Field | Type | Example | Notes |
|---|---|---|---|
| branch_name | string | `Chi nhanh Quan 1` | |
| address | string | `123 Nguyen Hue, Quan 1, TP.HCM` | |
| manager_id | string | `Ikdw7Hbh0vgosRqE6SpGqF2evz83` | → users.uid |
| phone | string | `02812345678` | |
| status | string | `active` | |

**Documents:**
- `branch_hcm_q1` → Chi nhanh Quan 1

### products/{product_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| product_name | string | `Paracetamol 500mg` | |
| active_ingredient | string | `Paracetamol` | Used in product_interactions |
| dosage | string | `500mg` | |
| indications | string | `Giam dau, ha sot` | |
| shift_location | string | `Quay A` | Where the product is displayed |

**Documents:**
- `product_001` → Paracetamol 500mg, Quay A
- `product_002` → Amoxicillin 250mg, Quay B
- `product_003` → Ibuprofen 200mg, Quay A

### product_prices/{price_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| product_id | string | `product_001` | → products.product_id |
| branch_id | string? | `branch_hcm_q1` | `null` = global price, set = branch override |
| base_price | string | `125000` | **Stored as String**, parse with double.tryParse() |
| promo_price | string | `110000` | **Stored as String** |
| approved_by | string | `vEC8noEOHefBIEnlgqaJ2B38TA43` | → users.uid |

**Documents:**
- `price_001` → product_001, base: 125000, promo: 110000
- `price_002` → product_002, base: 60000, promo: 55000
- `price_003` → product_003, base: 45000, promo: 40000

### product_interactions/{interaction_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| ingredient_a | string | `Ibuprofen` | Must match products.active_ingredient |
| ingredient_b | string | `Aspirin` | Must match products.active_ingredient |
| severity | string | `high` | `high`, `medium`, `low` |
| warning_message | string | `Khong nen dung cung...` | Vietnamese |

**Documents:**
- `interaction_001` → Ibuprofen + Aspirin, HIGH, chống chỉ định nặng
- `interaction_002` → Paracetamol + Amoxicillin, LOW, có thể dùng cùng
- `interaction_003` → Amoxicillin + Ibuprofen, MEDIUM, giảm hiệu quả

### orders/{order_id} — 4 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| branch_id | string | `branch_hcm_q1` | → branches.branch_id |
| cashier_id | string | `user_002` | → users.uid |
| created_at | **Timestamp** | `2026-07-19T01:30:00Z` | Only field using native Timestamp |
| customer_phone | string? | `0912345678` | |
| total_amount | string | `250000` | **Stored as String** |
| final_amount | string | `250000` | **Stored as String**, parsed with double.tryParse() |
| payment_method | string? | `cash` | Values: `cash`, `vietqr`, `card` |
| status | string | `completed` | `completed`, `serving`, `pending`, `approved`, `rejected` |
| items | array? | `[{product_id, product_name, quantity, price}]` | Embedded items list, used by inventory review |

**Documents:**
- `order_001` → completed, cash, 250000, 2 items (Paracetamol x2, Amoxicillin x1)
- `order_002` → serving, vietqr, 180000, 1 item (Amoxicillin x3)
- `order_approved_001 ` (trailing space!) → approved, 350000, 2 items
- `order_pending_001` → pending, 500000, 3 items

### order_items/{item_id} — 2 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| order_id | string | `order_001` | → orders.order_id |
| product_id | string | `product_001` | → products.product_id |
| quantity | string | `2` | **Stored as String** |
| price_per_unit | string | `125000` | **Stored as String** |

**Documents:**
- `item_001` → order_001, product_001, qty 2, price 125000
- `item_002` → order_002, product_002, qty 3, price 60000

### inventories/{inventory_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| branch_id | string | `branch_hcm_q1` | → branches.branch_id |
| product_id | string | `product_001` | → products.product_id |
| batch_number | string | `BT001` | |
| quantity | string | `15` | **Stored as String**, parsed with int.tryParse() |
| min_stock | string | `20` | **Stored as String**, parsed with int.tryParse() |
| max_stock | string | `100` | **Stored as String** |
| expiry_date | string | `2026-08-15` | **String YYYY-MM-DD**, NOT Timestamp |
| received_date | **Timestamp** | `2025-12-31T17:00:00Z` | Native Timestamp |
| unit | string | `vien` | |

**Documents:**
- `inventory_001` → product_001, BT001, qty:15, min:20 (LOW STOCK!), expires 2026-08-15
- `inventory_002` → product_002, BT002, qty:50, min:30, expires 2027-06-01
- `inventory_003` → product_003, BT003, qty:5, min:10 (LOW STOCK!), expires 2026-08-05

### shifts/{shift_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| branch_id | string | `branch_hcm_q1` | → branches.branch_id |
| name | string | `Ca sang` | Vietnamese |
| start_time | string | `7:00` | |
| end_time | string | `12:00` | |
| status | string? | `active` | |

**Documents:**
- `shift_001` → Ca sang, 7:00-12:00
- `shift_002` → Ca chieu, 12:00-17:00
- `shift_003` → Ca toi, 17:00-22:00

### schedules/{schedule_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| branch_id | string | `branch_hcm_q1` | → branches.branch_id |
| user_id | string | `user_003` | → users.uid |
| shift_id | string? | `shift_001` | → shifts.shift_id |
| shift_name | string? | (empty) | Redundant with shift_id |
| work_date | string | `2026-07-19` | **String YYYY-MM-DD**, queried with range operators |
| status | string | `active` | `active`, `pending_change`, `pending_leave`, `approved`, `rejected`, `handed_over` |
| notes | string? | (empty) | |
| start_time | string? | (empty) | |
| end_time | string? | (empty) | |

**Documents:**
- `schedule_001` → user_003 (pharmacist), shift_001, active, 2026-07-19
- `schedule_002` → user_002 (cashier), shift_002, pending_change, 2026-07-20, "Muon doi sang Ca sang"
- `schedule_003` → user_004 (warehouse), shift_003, pending_leave, 2026-07-21, "Nghi phep ngay 21/07"

### audit_logs/{log_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| user_id | string | `Ikdw7Hbh0vgosRqE6SpGqF2evz83` | → users.uid |
| action | string | `login` | `login`, `approve_request`, `stock_check` |
| description | string | `Branch Manager dang nhap he thong` | Vietnamese |
| timestamp | string | `2026-07-19T08:00:00Z` | String, NOT Timestamp |
| target_type | string | `user` | `user`, `order`, `inventory` |
| target_id | string | `Ikdw7Hbh0vgosRqE6SpGqF2evz83` | ID of target document |
| branch_id | string | `branch_hcm_q1` | → branches.branch_id |

### notifications/{notification_id} — 3 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| title | string | `Canh bao het han` | |
| content | string | `Co 3 mat hang sap het han...` | Vietnamese |
| type | string | `expiry_alert` | `expiry_alert`, `order_pending`, `shift_handover` |
| sender_id | string | `system` | Or users.uid |
| target_id | string | `Ikdw7Hbh0vgosRqE6SpGqF2evz83` | → users.uid |
| created_at | string | `2026-07-19T08:30:00Z` | String, NOT Timestamp |
| is_read | string | `false` | String "true"/"false", NOT boolean |

### roles/{role_id} — 6 docs

| Field | Type | Example | Notes |
|---|---|---|---|
| role_name | string | `system_admin` | Matches users.role values |

**Documents:** `role_001`→system_admin, `role_002`→chain_manager, `role_003`→branch_manager, `role_004`→pharmacist, `role_005`→cashier, `role_006`→warehouse_staff

### system_configs/{config_id} — 1 doc

| Field | Type | Example | Notes |
|---|---|---|---|
| config_key | string | `store_open_hours` | |
| updated_at | **Timestamp** | `2026-07-18T17:00:00Z` | Native Timestamp |
| updated_by | string | `RqK8Yr7GymafZZfSYqoHr9hWZ8d2` | → users.uid |

---

## Collection Relationships

```
branches ←── branch_id ──→ users (branchId)
branches ←── branch_id ──→ orders
branches ←── branch_id ──→ inventories
branches ←── branch_id ──→ shifts
branches ←── branch_id ──→ schedules
branches ←── branch_id ──→ product_prices

products ←── product_id ──→ inventories
products ←── product_id ──→ order_items
products ←── product_id ──→ product_prices

orders ←── order_id ──→ order_items
orders ←── cashier_id ──→ users

schedules ←── shift_id ──→ shifts
schedules ←── user_id ──→ users

users ←── uid ──→ audit_logs (user_id)
users ←── uid ──→ notifications (target_id)
users ←── uid ──→ product_prices (approved_by)
```

## Query Patterns (in services)

### auth_service.dart
```dart
 FirebaseFirestore.instance.collection('users').doc(uid).get()  // one-shot
```

### branch_service.dart
```dart
 FirebaseFirestore.instance.collection('orders')
    .where('branch_id', isEqualTo: branchId)  // stream
 FirebaseFirestore.instance.collection('users')
    .where('branchId', isEqualTo: branchId)
    .where('role', whereIn: ['pharmacist', 'cashier', 'warehouse_staff'])  // stream
```

### shift_service.dart
```dart
 FirebaseFirestore.instance.collection('schedules')
    .where('branch_id', isEqualTo: branchId)
    .where('status', isEqualTo: 'active')  // stream
 FirebaseFirestore.instance.collection('schedules')
    .where('branch_id', isEqualTo: branchId)
    .where('status', isEqualTo: 'pending_change')  // stream
 FirebaseFirestore.instance.collection('schedules')
    .where('branch_id', isEqualTo: branchId)
    .where('status', isEqualTo: 'pending_leave')  // stream
 FirebaseFirestore.instance.collection('schedules')
    .where('branch_id', isEqualTo: branchId)
    .where('user_id', isEqualTo: userId)
    .where('work_date', isEqualTo: workDate)
    .limit(1).get()  // one-shot
```

### inventory_service.dart
```dart
 FirebaseFirestore.instance.collection('inventories')
    .where('branch_id', isEqualTo: branchId)  // stream
 FirebaseFirestore.instance.collection('orders')
    .where('branch_id', isEqualTo: branchId)
    .where('status', whereIn: ['pending','approved','rejected'])  // stream
```

### schedule_service.dart
```dart
 FirebaseFirestore.instance.collection('schedules')
    .where('branch_id', isEqualTo: branchId)
    .where('work_date', isGreaterThanOrEqualTo: '$month-01')
    .where('work_date', isLessThan: '$month-32')  // stream
```

## Data Type Notes

> **CRITICAL:** Many fields stored as String in Firestore but parsed as numbers in Dart.

| Collection | Field | Firestore | Dart Parse | Code Location |
|---|---|---|---|---|
| orders | final_amount | string | `double.tryParse()` | branch_service.dart:28 |
| inventories | quantity | string | `int.tryParse()` | inventory_service.dart:17-22 |
| inventories | min_stock | string | `int.tryParse()` | inventory_service.dart:23 |
| inventories | expiry_date | string (YYYY-MM-DD) | direct string compare | inventory_service.dart:25-26 |
| schedules | work_date | string (YYYY-MM-DD) | string range query | schedule_service.dart:12-13 |
| notifications | is_read | string ("true"/"false") | string compare | - |
| orders | created_at | **Timestamp** | `.toDate()` | branch_service.dart:20-24 |
| inventories | received_date | **Timestamp** | direct | - |
| system_configs | updated_at | **Timestamp** | direct | - |

## Code Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase` with suffixes (Model, Service, Controller, Screen)
- Enums: `PascalCase` values in `camelCase`
- Imports: Relative within feature, relative cross-feature
- State management: ChangeNotifier + AnimatedBuilder
- Controllers created in `initState()`, disposed in `dispose()`
- Service pattern: `final FirebaseFirestore _db = FirebaseFirestore.instance;`
- Variable naming: `_db` (all services except auth which uses `_firestore`)

## Branch Manager Features - COMPLETED

### 1. Dashboard Chi Nhanh
- Real-time revenue, invoice count, counter status, working staff
- Stream from `orders` + `users` collections
- Files: `lib/features/branches/`

### 2. Canh Bao Kho
- Low stock alerts (quantity <= min_stock)
- Expiry alerts (expiry_date < 30 days)
- Files: `lib/features/inventory/screens/warehouse_alert_screen.dart`

### 3. Duyet Kho
- View pending/approved/rejected requests
- Approve/reject with Firestore update
- Files: `lib/features/inventory/screens/inventory_review_screen.dart`

### 4. Nhan/Xuat Kho
- Stock verification (quantity vs min_stock)
- Barcode scan counter (stub)
- Files: `lib/features/inventory/screens/stock_in_out_screen.dart`

### 5. Quan Ly Ca
- Weekly schedule from `schedules` + `shifts` + `users`
- Change-shift requests (status = 'pending_change')
- Leave requests (status = 'pending_leave')
- Approve/reject updates Firestore
- Files: `lib/features/shifts/`

### 6. Ban Giao Ca
- Cash reconciliation (cash/qr/card payment breakdown)
- Digital sign-off (updates schedule status)
- Files: `lib/features/shifts/screens/shift_handover_screen.dart`

## Remaining Work
- [ ] SystemAdmin features (system config, RBAC, audit logs, notifications)
- [ ] ChainManager features (dashboard, pricing, drug catalog, alerts)
- [ ] Pharmacist features (drug lookup, interaction warnings, POS)
- [ ] HrAdmin features (employee profiles, schedules, attendance)
- [ ] Firestore Security Rules
- [ ] Barcode scan implementation (camera integration)
- [ ] Push Notification (FCM)
- [ ] Drug interaction warning logic

## Known Issues
- `main.dart` has dead code from Flutter template
- `home_screen.dart` has duplicate `AppButton` class
- Some unused imports across codebase
- Vietnamese strings hardcoded in screens (not centralized in AppStrings)
- `order_approved_001 ` has trailing space in document ID
