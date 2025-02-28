// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      totalUsers: json['totalUsers'] as num,
      totalOrders: json['totalOrders'] as num,
      totalRevenue: json['totalRevenue'] as num,
      totalProducts: json['totalProducts'] as num,
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'totalOrders': instance.totalOrders,
      'totalRevenue': instance.totalRevenue,
      'totalProducts': instance.totalProducts,
    };
