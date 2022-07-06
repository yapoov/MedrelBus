// import 'dart:html';

import 'package:equatable/equatable.dart';
import 'package:medrel_bus/bus_line_model.dart';

abstract class BusLineState extends Equatable {
  List<BusLineModel> busLineModels;
  BusLineState({required this.busLineModels});
}

class BusLineInitial extends BusLineState {
  BusLineInitial() : super(busLineModels: [BusLineModel(), BusLineModel()]);
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class BusLineChanged extends BusLineState {
  BusLineChanged({required super.busLineModels});
  @override
  // TODO: implement props
  List<Object?> get props => [busLineModels];
}

class AllBusLines extends Equatable {
  Map<String, List<BusLineModel>> busLines;

  AllBusLines({required this.busLines});

  @override
  // TODO: implement props
  List<Object?> get props => [busLines];
}
