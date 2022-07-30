import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class BusStopEvent extends Equatable {}

class UpdateBusStopEvent extends BusStopEvent {
  String busStopId;

  UpdateBusStopEvent({required this.busStopId});
  @override
  // TODO: implement props
  List<Object?> get props => [busStopId];
}

class GetNearestBusStopEvent extends BusStopEvent {
  @override
  List<Object?> get props => [];
}

class GetBusStopEvent extends BusStopEvent {
  String busStopId;
  GetBusStopEvent({required this.busStopId});

  @override
  // TODO: implement props
  List<Object?> get props => [busStopId];
}
