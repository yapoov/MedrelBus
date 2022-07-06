import 'dart:convert';

import 'package:equatable/equatable.dart';

class BusLineModel extends Equatable {
  final List<BusStopModel>? stationList;

  final String? lineName;
  final String? lineId;

  final bool? isStartDirection;

  final int? weekdayInterval;
  final int? holidayInterval;

  final String? startTimeAtStartPoint;
  final String? endTimeAtStartPoint;
  final String? startTimeAtEndPoint;
  final String? endTimeAtEndPoint;

  const BusLineModel({
    this.stationList,
    this.lineName,
    this.lineId,
    this.weekdayInterval,
    this.holidayInterval,
    this.startTimeAtStartPoint,
    this.endTimeAtStartPoint,
    this.startTimeAtEndPoint,
    this.endTimeAtEndPoint,
    this.isStartDirection,
  });
  BusLineModel copyWith({
    String? lineName,
    String? lineId,
    List<BusStopModel>? stationList,
    bool? isStartDirection,
    int? weekdayInterval,
    int? holidayInterval,
    String? startTimeAtStartPoint,
    String? endTimeAtStartPoint,
    String? startTimeAtEndPoint,
    String? endTimeAtEndPoint,
  }) {
    return BusLineModel(
      lineName: lineName ?? this.lineName,
      lineId: lineId ?? this.lineId,
      stationList: stationList ?? this.stationList,
      isStartDirection: isStartDirection ?? this.isStartDirection,
      weekdayInterval: weekdayInterval ?? this.weekdayInterval,
      holidayInterval: holidayInterval ?? this.holidayInterval,
      startTimeAtStartPoint:
          startTimeAtStartPoint ?? this.startTimeAtStartPoint,
      endTimeAtStartPoint: endTimeAtStartPoint ?? this.endTimeAtStartPoint,
      startTimeAtEndPoint: startTimeAtEndPoint ?? this.startTimeAtEndPoint,
      endTimeAtEndPoint: endTimeAtEndPoint ?? this.endTimeAtEndPoint,
    );
  }

  BusLineModel.fromJson(Map<String, dynamic> json)
      : lineName = json['line_name'] as String,
        lineId = json['line_id'] as String,
        stationList = json['station_list'].map<BusStopModel>((station) {
          var busStop = BusStopModel.fromJson(station);
          return busStop;
        }).toList(),
        isStartDirection = json['is_start'] == 'Y',
        weekdayInterval = json['weekday_interval'] as int,
        holidayInterval = json['holiday_interval'] as int,
        startTimeAtStartPoint = json['start_time_at_start_point'] as String,
        startTimeAtEndPoint = json['start_time_at_end_point'] as String,
        endTimeAtStartPoint = json['end_time_at_start_point'] as String,
        endTimeAtEndPoint = json['end_time_at_end_point'] as String;

  Map<String, dynamic> toJson() => {
        'line_name': lineName,
        'line_id': lineId,
        'station_list': stationList,
        'is_start_direction': isStartDirection,
        'weekday_interval': weekdayInterval,
        'holiday_interval': holidayInterval,
        'start_time_at_start_point': startTimeAtStartPoint,
        'start_time_at_end_point': startTimeAtEndPoint,
        'end_time_at_start_point': endTimeAtStartPoint,
        'end_time_at_end_point': endTimeAtEndPoint,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [lineName, lineId, stationList, isStartDirection];
}

class BusStopModel extends Equatable {
  final String? stationName;
  final String? stationId;

  final int? stationSeq;
  final bool? existBus;

  final double? longitude;
  final double? latitude;

  BusStopModel(
      {this.stationName,
      this.stationId,
      this.stationSeq,
      this.existBus,
      this.longitude,
      this.latitude});

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
        stationName: json['station_name'] as String,
        stationId: json['station_id'] as String,
        stationSeq: json['station_seq'] as int,
        existBus: json['exist_bus'] == 'Y',
        longitude: json['longitude'] as double,
        latitude: json['latitude'] as double);
  }

  Map<String, dynamic> toJson() => {
        'station_name': stationName,
        'station_id': stationId,
        'station_seq': stationSeq,
        'exist_bus': (existBus ?? false) ? "Y" : "N",
        'longitude': longitude,
        'latitude': latitude,
      };

  @override
  // TODO: implement props
  List<Object?> get props =>
      [stationName, stationId, stationSeq, longitude, latitude, existBus];
}
