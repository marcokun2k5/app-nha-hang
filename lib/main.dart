import 'package:flutter/material.dart';

void main() {
  runApp(const NhaHangApp());
}

/* =========================
   Models đơn giản
   ========================= */
class MenuItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final String category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });
}

class TableOrder {
  final int tableId;
  final List<MenuItem> items;
  bool occupied;

  TableOrder({
    required this.tableId,
    List<MenuItem>? items,
    this.occupied = false,
  }) : items = items ?? [];

  int get total => items.fold(0, (sum, it) => sum + it.price);
}

/* =========================
   App chính
   ========================= */
class NhaHangApp extends StatelessWidget {
  const NhaHangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Nhà hàng',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      home: const TrangChu(),
    );
  }
}

/* =========================
   Trang chủ với BottomNavigationBar
   ========================= */
class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  int _selectedIndex = 0;

  // Dữ liệu menu (các món lấy từ yêu cầu)
  final List<MenuItem> _menuItems = const [
    MenuItem(
        id: 'pho_bo',
        name: 'Phở bò',
        price: 45000,
        image: 'assets/images/pho_bo.jpg',
        category: 'Món chính'),
    MenuItem(
        id: 'bun_cha',
        name: 'Bún chả',
        price: 40000,
        image: 'assets/images/bun_cha.jpg',
        category: 'Món chính'),
    MenuItem(
        id: 'com_tam_suon',
        name: 'Cơm tấm sườn',
        price: 35000,
        image: 'assets/images/com_tam_suon.jpg',
        category: 'Món chính'),
    MenuItem(
        id: 'hu_tieu',
        name: 'Hủ tiếu Nam Vang',
        price: 42000,
        image: 'assets/images/hu_tieu_nam_vang.jpg',
        category: 'Món chính'),
    MenuItem(
        id: 'goi_cuon',
        name: 'Gỏi cuốn',
        price: 25000,
        image: 'assets/images/goi_cuon.jpg',
        category: 'Món khai vị'),
    MenuItem(
        id: 'nem_ran',
        name: 'Nem rán',
        price: 30000,
        image: 'assets/images/nem_ran.jpg',
        category: 'Món khai vị'),
    MenuItem(
        id: 'cha_gio_hs',
        name: 'Chả giò hải sản',
        price: 35000,
        image: 'assets/images/cha_gio.jpg',
        category: 'Món khai vị'),
    MenuItem(
        id: 'tra_da',
        name: 'Trà đá',
        price: 5000,
        image: 'assets/images/tra_da.jpg',
        category: 'Đồ uống'),
    MenuItem(
        id: 'nuoc_mia',
        name: 'Nước mía',
        price: 10000,
        image: 'assets/images/nuoc_mia.jpg',
        category: 'Đồ uống'),
    MenuItem(
        id: 'ca_phe_sua_da',
        name: 'Cà phê sữa đá',
        price: 20000,
        image: 'assets/images/ca_phe.jpg',
        category: 'Đồ uống'),
    MenuItem(
        id: 'sinh_to_xoai',
        name: 'Sinh tố xoài',
        price: 25000,
        image: 'assets/images/sinh_to_xoai.jpg',
        category: 'Đồ uống'),
  ];

  // Danh sách bàn (ví dụ 8 bàn)
  late final List<TableOrder> _tables = List.generate(
    8,
    (index) => TableOrder(tableId: index + 1),
  );

  // --- Các thao tác thay đổi state (luôn gọi setState để cập nhật UI ngay) ---
  void _addItemToTable(int tableId, MenuItem item) {
    setState(() {
      final t = _tables.firstWhere((tb) => tb.tableId == tableId);
      t.items.add(item);
      t.occupied = true;
    });
  }

  void _removeItemFromTable(int tableId, int index) {
    setState(() {
      final t = _tables.firstWhere((tb) => tb.tableId == tableId);
      if (index >= 0 && index < t.items.length) {
        t.items.removeAt(index);
      }
      if (t.items.isEmpty) t.occupied = false;
    });
  }

  void _toggleTableOccupied(int tableId) {
    setState(() {
      final t = _tables.firstWhere((tb) => tb.tableId == tableId);
      t.occupied = !t.occupied;
      if (!t.occupied) t.items.clear(); // nếu chuyển sang trống thì xóa món
    });
  }

  void _clearBill(int tableId) {
    setState(() {
      final t = _tables.firstWhere((tb) => tb.tableId == tableId);
      t.items.clear();
      t.occupied = false;
    });
  }

  // Trả về TableOrder mới nhất (dùng bởi modal để lấy dữ liệu cập nhật)
  TableOrder _getTable(int tableId) {
    return _tables.firstWhere((t) => t.tableId == tableId);
  }

  // Mở modal chi tiết bàn, truyền callback và hàm getTable
  void _openTableDetail(int tableId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return TableDetailSheet(
          tableId: tableId,
          getTable: () => _getTable(tableId),
          menuItems: _menuItems,
          onAdd: (item) => _addItemToTable(tableId, item),
          onRemove: (index) => _removeItemFromTable(tableId, index),
          onToggleOccupied: () => _toggleTableOccupied(tableId),
          onClearBill: () {
            _clearBill(tableId);
            Navigator.of(ctx).pop();
          },
          onOpenMenu: () {
            // đóng modal rồi chuyển về tab Menu
            Navigator.of(ctx).pop();
            setState(() {
              _selectedIndex = 0;
            });
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tạo pages ở đây để mỗi lần setState() tái tạo widget mới và UI cập nhật ngay
    final pages = [
      MenuPage(menuItems: _menuItems, tables: _tables, onAddToTable: (tableId, item) {
        _addItemToTable(tableId, item);
      }),
      OrdersPage(tables: _tables),
      TablesPage(
        tables: _tables,
        onToggleOccupied: _toggleTableOccupied,
        onOpenTableDetail: _openTableDetail,
      ),
      BillsPage(tables: _tables, onClearBill: _clearBill),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Đơn món'),
          BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: 'Bàn'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Hóa đơn'),
        ],
      ),
    );
  }
}

/* =========================
   MenuPage: hiển thị menu, có nút thêm vào bàn
   ========================= */
class MenuPage extends StatelessWidget {
  final List<MenuItem> menuItems;
  final List<TableOrder> tables;
  final void Function(int tableId, MenuItem item) onAddToTable;

  const MenuPage({
    super.key,
    required this.menuItems,
    required this.tables,
    required this.onAddToTable,
  });

  @override
  Widget build(BuildContext context) {
    // gom theo category
    final Map<String, List<MenuItem>> categories = {};
    for (var m in menuItems) {
      categories.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: categories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final dish = entry.value[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.asset(
                              dish.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stack) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.image_not_supported)),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Column(
                            children: [
                              // Dùng Text với maxLines + ellipsis để tránh overflow
                              Text(
                                dish.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text('${dish.price} VNĐ', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              // Dùng Wrap để các nút có thể xuống dòng nếu không đủ chỗ
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      minimumSize: const Size(80, 36),
                                    ),
                                    onPressed: () {
                                      _showChooseTableDialog(context, dish);
                                    },
                                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                                    label: const Text('Thêm'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      _showDishDetail(context, dish);
                                    },
                                    child: const Text('Xem'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDishDetail(BuildContext context, MenuItem dish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dish.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(dish.image, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox(height: 120, child: Center(child: Icon(Icons.image_not_supported)))),
            const SizedBox(height: 8),
            Text('Giá: ${dish.price} VNĐ'),
            const SizedBox(height: 8),
            Text('Thể loại: ${dish.category}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showChooseTableDialog(BuildContext context, MenuItem dish) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text('Chọn bàn để thêm "${dish.name}"', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final t = tables[index];
                    return GestureDetector(
                      onTap: () {
                        onAddToTable(t.tableId, dish);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm ${dish.name} vào bàn ${t.tableId}')),
                        );
                      },
                      child: Card(
                        color: t.occupied ? Colors.red[200] : Colors.green[200],
                        child: Center(
                          child: Text('Bàn ${t.tableId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* =========================
   OrdersPage: hiển thị tất cả đơn (theo bàn)
   ========================= */
class OrdersPage extends StatelessWidget {
  final List<TableOrder> tables;

  const OrdersPage({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    final orders = tables.where((t) => t.items.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn món'), backgroundColor: Colors.green[700]),
      body: orders.isEmpty
          ? const Center(child: Text('Chưa có đơn nào', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final o = orders[index];
                return Card(
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: Text('${o.tableId}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text('Bàn ${o.tableId} - ${o.items.length} món'),
                    subtitle: Text('Tổng: ${o.total} VNĐ'),
                    children: o.items.map((it) {
                      return ListTile(
                        title: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text('${it.price} VNĐ'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}

/* =========================
   TablesPage: hiển thị danh sách bàn, mở chi tiết bàn
   - Đã tăng kích thước vùng hiển thị, font lớn hơn, tránh overflow
   ========================= */
class TablesPage extends StatelessWidget {
  final List<TableOrder> tables;
  final void Function(int tableId) onToggleOccupied;
  final void Function(int tableId) onOpenTableDetail;

  const TablesPage({
    super.key,
    required this.tables,
    required this.onToggleOccupied,
    required this.onOpenTableDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Tính kích thước card dựa trên màn hình để tránh overflow dọc
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = (screenWidth / 2) * 0.9; // tỷ lệ hợp lý cho 2 cột

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý bàn'), backgroundColor: Colors.green[700]),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (screenWidth / 2) / cardHeight, // đảm bảo chiều cao đủ lớn
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final t = tables[index];
          return GestureDetector(
            onTap: () => onOpenTableDetail(t.tableId),
            child: Card(
              elevation: 4,
              color: t.occupied ? Colors.red[200] : Colors.green[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tăng kích thước chữ và cho phép xuống dòng an toàn
                    Text(
                      'Bàn ${t.tableId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.occupied ? 'Có khách' : 'Trống',
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Nút nhỏ gọn để tránh chiếm chỗ
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () => onToggleOccupied(t.tableId),
                          child: Text(t.occupied ? 'Đặt trống' : 'Đặt có khách'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   TableDetailSheet: modal chi tiết bàn (thêm/xóa món, xem bill, toggle)
   - Thay đổi: nhận tableId + getTable() để luôn lấy dữ liệu mới nhất
   - Thêm onOpenMenu callback để chuyển về tab Menu khi cần
   ========================= */
class TableDetailSheet extends StatefulWidget {
  final int tableId;
  final TableOrder Function() getTable;
  final List<MenuItem> menuItems;
  final void Function(MenuItem item) onAdd;
  final void Function(int index) onRemove;
  final VoidCallback onToggleOccupied;
  final VoidCallback onClearBill;
  final VoidCallback onOpenMenu;

  const TableDetailSheet({
    super.key,
    required this.tableId,
    required this.getTable,
    required this.menuItems,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleOccupied,
    required this.onClearBill,
    required this.onOpenMenu,
  });

  @override
  State<TableDetailSheet> createState() => _TableDetailSheetState();
}

class _TableDetailSheetState extends State<TableDetailSheet> {
  @override
  Widget build(BuildContext context) {
    // Lấy table mới nhất mỗi lần build
    final t = widget.getTable();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bàn ${t.tableId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trạng thái: ${t.occupied ? 'Có khách' : 'Trống'}'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: t.occupied ? Colors.red : Colors.green),
                  onPressed: () {
                    widget.onToggleOccupied();
                    setState(() {});
                  },
                  child: Text(t.occupied ? 'Đặt trống' : 'Đặt có khách'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: Text('Món đã gọi:', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            if (t.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Chưa có món nào', style: TextStyle(color: Colors.grey)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: t.items.length,
                  itemBuilder: (context, index) {
                    final it = t.items[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: Image.asset(it.image, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)),
                      ),
                      title: Text(it.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${it.price} VNĐ'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Gọi callback parent để xóa, parent sẽ setState và cập nhật
                          widget.onRemove(index);
                          // Sau khi parent cập nhật, gọi setState để rebuild modal với dữ liệu mới
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng: ${t.total} VNĐ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    // Nút mở Menu (chuyển về tab Menu)
                    TextButton(
                      onPressed: () {
                        widget.onOpenMenu();
                      },
                      child: const Text('Mở Menu'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        widget.onClearBill();
                        setState(() {});
                      },
                      child: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/* =========================
   BillsPage: hiển thị hóa đơn cho từng bàn
   ========================= */
class BillsPage extends StatelessWidget {
  final List<TableOrder> tables;
  final void Function(int tableId) onClearBill;

  const BillsPage({super.key, required this.tables, required this.onClearBill});

  @override
  Widget build(BuildContext context) {
    final occupiedTables = tables.where((t) => t.items.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn'), backgroundColor: Colors.green[700]),
      body: occupiedTables.isEmpty
          ? const Center(child: Text('Không có hóa đơn', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: occupiedTables.length,
              itemBuilder: (context, index) {
                final t = occupiedTables[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green[700], child: Text('${t.tableId}', style: const TextStyle(color: Colors.white))),
                    title: Text('Bàn ${t.tableId} - ${t.items.length} món'),
                    subtitle: Text('Tổng: ${t.total} VNĐ'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            // mở chi tiết giống TableDetailSheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => TableDetailSheet(
                                tableId: t.tableId,
                                getTable: () => t,
                                menuItems: tables.expand((e) => e.items).toList(),
                                onAdd: (item) {},
                                onRemove: (i) {},
                                onToggleOccupied: () {},
                                onClearBill: () {},
                                onOpenMenu: () {},
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.payment, color: Colors.orange),
                          onPressed: () {
                            onClearBill(t.tableId);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thanh toán bàn ${t.tableId}')));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}