import 'package:equatable/equatable.dart';
import 'package:medrel_bus/bus_line_model.dart';

abstract class BusLineEvent extends Equatable {
  const BusLineEvent();
}

class UpdateBusLine extends BusLineEvent {
  String busId;
  UpdateBusLine({required this.busId});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class BusLineUpdated extends BusLineEvent {
  List<BusLineModel> busLineModels;

  BusLineUpdated({required this.busLineModels});
  @override
  // TODO: implement props
  List<Object?> get props => [busLineModels];
}

class FetchAllBusLines extends BusLineEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
