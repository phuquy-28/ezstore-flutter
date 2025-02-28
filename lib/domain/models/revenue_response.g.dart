// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueResponse _$RevenueResponseFromJson(Map<String, dynamic> json) =>
    RevenueResponse(
      revenueByMonth: (json['revenueByMonth'] as List<dynamic>)
          .map((e) => RevenueByMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RevenueResponseToJson(RevenueResponse instance) =>
    <String, dynamic>{
      'revenueByMonth': instance.revenueByMonth,
    };

RevenueByMonth _$RevenueByMonthFromJson(Map<String, dynamic> json) =>
    RevenueByMonth(
      month: (json['month'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
    );

Map<String, dynamic> _$RevenueByMonthToJson(RevenueByMonth instance) =>
    <String, dynamic>{
      'month': instance.month,
      'revenue': instance.revenue,
    };
