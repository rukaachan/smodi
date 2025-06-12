import 'package:equatable/equatable.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  @override
  List<Object> get props => [];
}

class LoadInsightsData extends InsightsEvent {}
