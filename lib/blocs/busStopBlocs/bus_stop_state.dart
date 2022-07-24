import 'package:equatable/equatable.dart';
import 'package:medrel_bus/bus_line_model.dart';

abstract class BusStopState extends Equatable {
  BusStopModel busStopModel;
  BusStopState({required this.busStopModel});
}

class BusStopInitial extends BusStopState {
  BusStopInitial() : super(busStopModel: BusStopModel());
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class BusStopUpdated extends BusStopState {
  BusStopUpdated({required super.busStopModel});

  @override
  // TODO: implement props
  List<Object?> get props => [busStopModel];
}
