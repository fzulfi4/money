import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/model/user.dart';
import 'package:mon/widget/chart_widget.dart';

class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewAllPageState createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  late Future<List<User>> _usersFuture;
  late Future<Map<String, double>> _pieChartDataFuture;
  int currentPage = 1;
  int itemsPerPage = 10;
  String _currentSortColumn = 'id'; // Default sorting column
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _usersFuture = DataApi.getAll();
    _pieChartDataFuture = DataApi.getPieChartData();
  }

  List<User> _getCurrentPageItems(List<User> users) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage);
    return users.sublist(
        startIndex, endIndex > users.length ? users.length : endIndex);
  }

  List<User> _sortUsers(List<User> users) {
    users.sort((a, b) {
      int comparison;
      switch (_currentSortColumn) {
        case 'Name':
          comparison = (a.name).compareTo(b.name);
          break;
        case 'Total':
          comparison = (a.total).compareTo(b.total);
          break;
        case 'Date':
          comparison = (a.date).compareTo(b.date);
          break;
        case 'Method':
          comparison = (a.method).compareTo(b.method);
          break;
        case 'Type':
          comparison = (a.type).compareTo(b.type);
          break;
        case 'Category':
          comparison = (a.category ?? '').compareTo(b.category ?? '');
          break;
        default:
          comparison = (a.id ?? 0).compareTo(b.id ?? 0);
      }
      return _isAscending ? comparison : -comparison;
    });
    return users;
  }

  void _onSortColumn(String columnName) {
    setState(() {
      if (_currentSortColumn == columnName) {
        _isAscending = !_isAscending;
      } else {
        _currentSortColumn = columnName;
        _isAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Entries'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: FutureBuilder<Map<String, double>>(
                future: _pieChartDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found.'));
                  }
                  return PieChartWidget(pieChartData: snapshot.data!);
                },
              ),
            ),
            FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                final users = _sortUsers(snapshot.data!);
                final pageItems = _getCurrentPageItems(users);
                final totalPages = (users.length / itemsPerPage).ceil();

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('ID'),
                              child: Row(
                                children: [
                                  const Text('ID'),
                                  if (_currentSortColumn == 'ID')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Name'),
                              child: Row(
                                children: [
                                  const Text('Name'),
                                  if (_currentSortColumn == 'Name')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Method'),
                              child: Row(
                                children: [
                                  const Text('Method'),
                                  if (_currentSortColumn == 'Method')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Type'),
                              child: Row(
                                children: [
                                  const Text('Type'),
                                  if (_currentSortColumn == 'Type')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Total'),
                              child: Row(
                                children: [
                                  const Text('Total'),
                                  if (_currentSortColumn == 'Total')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Category'),
                              child: Row(
                                children: [
                                  const Text('Category'),
                                  if (_currentSortColumn == 'Category')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: GestureDetector(
                              onTap: () => _onSortColumn('Date'),
                              child: Row(
                                children: [
                                  const Text('Date'),
                                  if (_currentSortColumn == 'Date')
                                    Icon(_isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward),
                                ],
                              ),
                            ),
                          ),
                        ],
                        rows: pageItems.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user.id?.toString() ?? 'N/A')),
                            DataCell(Text(user.name)),
                            DataCell(Text(user.method)),
                            DataCell(Text(user.type)),
                            DataCell(Text(
                              'Rp ${NumberFormat("#,##0").format(user.total.toDouble())}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            )),
                            DataCell(Text(user.category ?? 'N/A')),
                            DataCell(Text(user.date.toIso8601String())),
                          ]);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: currentPage > 1
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text('$currentPage/$totalPages'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: currentPage < totalPages
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
