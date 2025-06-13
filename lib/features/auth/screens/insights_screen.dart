import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/features/insights/bloc/insights_bloc.dart';
import 'package:smodi/features/insights/bloc/insights_event.dart';
import 'package:smodi/features/insights/bloc/insights_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InsightsBloc>()..add(LoadInsightsData()),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatefulWidget {
  const _InsightsView();

  @override
  State<_InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<_InsightsView> {
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights & Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              // Capture the chart widget and share it
              final image = await _screenshotController.capture();
              if (image == null) return;

              final directory = await getApplicationDocumentsDirectory();
              final imagePath =
                  await File('${directory.path}/smodi_insights.png').create();
              await imagePath.writeAsBytes(image);

              await Share.shareXFiles(
                [XFile(imagePath.path)],
                text: 'Check out my focus progress on Smodi!',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (context, state) {
          if (state.status == InsightsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == InsightsStatus.failure) {
            return Center(
                child: Text('Failed to load data: ${state.errorMessage}'));
          }
          if (state.status == InsightsStatus.success && state.events.isEmpty) {
            return const Center(
                child: Text('No activity has been recorded yet.'));
          }

          // Use a CustomScrollView to combine the chart and the list.
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Screenshot(
                  // Wrap with Screenshot controller
                  controller: _screenshotController,
                  child: Container(
                    // Add a container with a background color
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Distractions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _InsightsChart(
                            dailyCounts: state.dailyDistractionCounts),
                      ],
                    ),
                  ),
                ),
              ),
              // --- History Log Section ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Event History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = state.events[index];
                    return _EventListItem(event: event);
                  },
                  childCount: state.events.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- NEW: Chart Widget ---
class _InsightsChart extends StatelessWidget {
  final Map<int, int> dailyCounts;
  const _InsightsChart({required this.dailyCounts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = theme.colorScheme.primary;
    // final touchedBarColor = barColor.withOpacity(0.8);

    // Find the maximum value for the Y-axis range.
    final maxY = (dailyCounts.values.isEmpty
            ? 0
            : dailyCounts.values.reduce((a, b) => a > b ? a : b))
        .toDouble();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY == 0
              ? 5
              : maxY + 2, // Ensure the chart has some height even with 0 data
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData group) =>
                  theme.colorScheme.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}',
                  TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontSize: 10);
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Mon';
                      break;
                    case 1:
                      text = 'Tue';
                      break;
                    case 2:
                      text = 'Wed';
                      break;
                    case 3:
                      text = 'Thu';
                      break;
                    case 4:
                      text = 'Fri';
                      break;
                    case 5:
                      text = 'Sat';
                      break;
                    case 6:
                      text = 'Sun';
                      break;
                    default:
                      text = '';
                      break;
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: Text(text, style: style));
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value % 5 != 0)
                    return const SizedBox.shrink();
                  return Text(value.toInt().toString(),
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dailyCounts[index]?.toDouble() ?? 0,
                  color: barColor,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// --- Event List Item (No changes) ---
class _EventListItem extends StatelessWidget {
  final FocusEvent event;
  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Icon(_getIconForEventType(event.eventType),
            color: theme.colorScheme.primary),
        title: Text(
          _formatTitle(event.eventType, event.details),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${dateFormat.format(event.timestamp)} at ${timeFormat.format(event.timestamp)}',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  IconData _getIconForEventType(String eventType) {
    switch (eventType) {
      case 'distraction':
        return Icons.phone_android;
      case 'activity':
        return Icons.person;
      case 'posture':
        return Icons.accessibility_new;
      default:
        return Icons.help_outline;
    }
  }

  String _formatTitle(String eventType, Map<String, dynamic> details) {
    switch (eventType) {
      case 'distraction':
        return 'Distraction: ${details['type'] ?? 'Unknown'}';
      case 'activity':
        return details['userPresent'] == true ? 'User Detected' : 'User Away';
      case 'posture':
        return 'Posture Alert: ${details['state'] ?? 'N/A'}';
      default:
        return eventType.toUpperCase();
    }
  }
}
