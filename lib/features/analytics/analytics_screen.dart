import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'analytics_view_model.dart';
import '../notes/note_editor_screen.dart' show getNoteColor;
import 'dart:math';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DailyFocusStats? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Analytics'),
      ),
      body: statsAsync.when(
        data: (stats) {
          final maxMins = stats.fold<int>(0, (maxVal, element) => max(maxVal, element.totalMinutes));
          final double maxY = maxMins > 0 ? (maxMins + 10).toDouble() : 60.0;

          // Select today by default on first load
          if (_selectedDay == null && stats.isNotEmpty) {
            _selectedDay = stats.last;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 30 Days Focus Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                // Bar Chart
                SizedBox(
                  height: 200,
                  child: stats.isEmpty
                      ? const Center(child: Text('No session data found'))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Theme.of(context).colorScheme.secondaryContainer,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final dayStat = stats[groupIndex];
                                  return BarTooltipItem(
                                    '${dayStat.date.day}/${dayStat.date.month}\n${dayStat.totalMinutes} mins',
                                    TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                                  );
                                },
                              ),
                              touchCallback: (FlTouchEvent event, barTouchResponse) {
                                if (!event.isInterestedForInteractions ||
                                    barTouchResponse == null ||
                                    barTouchResponse.spot == null) {
                                  return;
                                }
                                final index = barTouchResponse.spot!.touchedBarGroupIndex;
                                setState(() {
                                  _selectedDay = stats[index];
                                });
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < stats.length) {
                                      final date = stats[index].date;
                                      // Only show label for every 6th day to avoid crowding
                                      if (index % 6 == 0 || index == stats.length - 1) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '${date.day}/${date.month}',
                                            style: const TextStyle(fontSize: 9),
                                          ),
                                        );
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(stats.length, (index) {
                              final day = stats[index];
                              final isSelected = _selectedDay?.date.day == day.date.day &&
                                  _selectedDay?.date.month == day.date.month;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: day.totalMinutes.toDouble(),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                    width: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
                const SizedBox(height: 28),
                if (_selectedDay != null) ...[
                  Text(
                    'Details for ${_selectedDay!.date.day}/${_selectedDay!.date.month}/${_selectedDay!.date.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total focus duration: ${_selectedDay!.totalMinutes} minutes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDay!.sessions.isEmpty)
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      child: const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('No focus sessions recorded on this day.'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedDay!.sessions.length,
                      itemBuilder: (context, index) {
                        final session = _selectedDay!.sessions[index];
                        final isFocus = session.mode == 'focus';
                        final color = getNoteColor(context, isFocus ? 1 : 4); // red for focus, green for break

                        final startTimeStr = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';
                        final endTimeStr = '${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}';

                        return Card(
                          color: color,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isFocus ? Icons.work : Icons.coffee,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              isFocus ? 'Focus Session' : 'Break Session',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Time: $startTimeStr - $endTimeStr'),
                            trailing: Text(
                              '${session.durationMinutes} mins',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading analytics: $err')),
      ),
    );
  }
}
