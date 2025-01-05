import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../services/crypto_service.dart';
import '../widgets/duration_button.dart';

enum ChartDuration { day, month, year }

class CryptoChartScreen extends StatefulWidget {
  const CryptoChartScreen({super.key});

  @override
  CryptoChartScreenState createState() => CryptoChartScreenState();
}

class CryptoChartScreenState extends State<CryptoChartScreen> {
  final CryptoService _cryptoService = CryptoService();
  List<FlSpot> _priceData = [];
  bool _isLoading = true;
  double _minY = 0;
  double _maxY = 0;
  String _selectedCrypto = 'bitcoin';
  List<Map<String, dynamic>> _cryptoList = [];
  List<DateTime> _timestamps = [];
  String? _error;
  ChartDuration _selectedDuration = ChartDuration.day;

  String _getDurationParam(ChartDuration duration) {
    switch (duration) {
      case ChartDuration.day:
        return '1';
      case ChartDuration.month:
        return '30';
      case ChartDuration.year:
        return '365';
    }
  }

  String _getXAxisLabel(double value) {
    if (value < 0 || value >= _timestamps.length) return '';
    final date = _timestamps[value.toInt()];

    switch (_selectedDuration) {
      case ChartDuration.day:
        return DateFormat('HH:mm').format(date);
      case ChartDuration.month:
        return DateFormat('d').format(date);
      case ChartDuration.year:
        return DateFormat('MMM').format(date);
    }
  }

  String _formatTooltipTimestamp(DateTime date) {
    switch (_selectedDuration) {
      case ChartDuration.day:
        return DateFormat('MMM d, HH:mm').format(date);
      case ChartDuration.month:
        return DateFormat('MMM d').format(date);
      case ChartDuration.year:
        return DateFormat('MMM yyyy').format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCryptoList();
  }

  Future<void> _fetchCryptoList() async {
    try {
      final cryptoList = await _cryptoService.getCryptoList();
      setState(() {
        _error = null;
        _cryptoList = cryptoList;
        _fetchCryptoPrices();
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading crypto data: $e';
      });
    }
  }

  Future<void> _fetchCryptoPrices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _cryptoService.getCryptoPrices(
          _selectedCrypto, _getDurationParam(_selectedDuration));
      final List prices = data['prices'];

      setState(() {
        _timestamps = prices
            .map((price) => DateTime.fromMillisecondsSinceEpoch(price[0]))
            .toList();
        _priceData = prices
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
            .toList();

        _minY = _priceData.map((spot) => spot.y).reduce(min);
        _maxY = _priceData.map((spot) => spot.y).reduce(max);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading price data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B262C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C75),
        elevation: 0,
        title: _cryptoList.isEmpty
            ? const Text(
                'Loading...',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : DropdownButton<String>(
                value: _selectedCrypto,
                dropdownColor: const Color(0xFF0F4C75),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(),
                isExpanded: true,
                items: _cryptoList.map((crypto) {
                  return DropdownMenuItem<String>(
                    value: crypto['id'],
                    child: Row(
                      children: [
                        Image.network(
                          crypto['image'],
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(crypto['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCrypto = newValue;
                    });
                    _fetchCryptoPrices();
                  }
                },
              ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DurationButton(
                  label: '1D',
                  isSelected: _selectedDuration == ChartDuration.day,
                  onPressed: () {
                    setState(() {
                      _selectedDuration = ChartDuration.day;
                    });
                    _fetchCryptoPrices();
                  },
                ),
                const SizedBox(width: 8),
                DurationButton(
                  label: '1M',
                  isSelected: _selectedDuration == ChartDuration.month,
                  onPressed: () {
                    setState(() {
                      _selectedDuration = ChartDuration.month;
                    });
                    _fetchCryptoPrices();
                  },
                ),
                const SizedBox(width: 8),
                DurationButton(
                  label: '1Y',
                  isSelected: _selectedDuration == ChartDuration.year,
                  onPressed: () {
                    setState(() {
                      _selectedDuration = ChartDuration.year;
                    });
                    _fetchCryptoPrices();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3282B8),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F4C75),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1000,
                            getDrawingHorizontalLine: (value) {
                              if (value == _minY || value == _maxY) {
                                return FlLine(
                                  color: value == _minY
                                      ? const Color(0xFFFF6B6B).withOpacity(0.5)
                                      : const Color(0xFF4ECB71)
                                          .withOpacity(0.5),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              }
                              return FlLine(
                                color: const Color(0xFF3282B8).withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: _maxY,
                                color: const Color(0xFF4ECB71),
                                strokeWidth: 1,
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  padding: const EdgeInsets.only(left: 8),
                                  style: const TextStyle(
                                    color: Color(0xFF4ECB71),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  labelResolver: (line) =>
                                      'Max: \$${_maxY.toStringAsFixed(2)}',
                                ),
                              ),
                              HorizontalLine(
                                y: _minY,
                                color: const Color(0xFFFF6B6B),
                                strokeWidth: 1,
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.bottomRight,
                                  padding: const EdgeInsets.only(left: 8),
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  labelResolver: (line) =>
                                      'Min: \$${_minY.toStringAsFixed(2)}',
                                ),
                              ),
                            ],
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: _selectedDuration == ChartDuration.day
                                    ? 24
                                    : _selectedDuration == ChartDuration.month
                                        ? 5
                                        : 30,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _getXAxisLabel(value),
                                      style: const TextStyle(
                                        color: Color(0xFFBBE1FA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 80,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFFBBE1FA),
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: _priceData.length.toDouble() - 1,
                          minY: _minY * 0.999,
                          maxY: _maxY * 1.001,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _priceData,
                              isCurved: true,
                              color: const Color(0xFFBBE1FA),
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFFBBE1FA).withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: const Color(0xFF37474F),
                              tooltipRoundedRadius: 8,
                              tooltipBorder: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              getTooltipItems:
                                  (List<LineBarSpot> touchedSpots) {
                                return touchedSpots
                                    .map((LineBarSpot touchedSpot) {
                                  final index = touchedSpot.x.toInt();
                                  final timestamp = _timestamps[index];
                                  return LineTooltipItem(
                                    '${_formatTooltipTimestamp(timestamp)}\n\$${touchedSpot.y.toStringAsFixed(2)}',
                                    const TextStyle(
                                      color: Color(0xFFBBE1FA),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
