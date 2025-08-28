// lib/plugins/sensores/modelos/sensores_modbus_data.dart
class ModbusData {
  final int id;
  final DateTime createdAt;
  final Map<String, int?> registers;

  ModbusData({
    required this.id,
    required this.createdAt,
    required this.registers,
  });

  factory ModbusData.fromJson(Map<String, dynamic> json) {
    final registers = <String, int?>{};
    for (int i = 1; i <= 25; i++) {
      final value = json['register$i'];
      registers['Register $i'] = value;
    }

    return ModbusData(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      registers: registers,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
    };

    registers.forEach((key, value) {
      final registerNumber = key.split(' ')[1];
      json['register$registerNumber'] = value;
    });

    return json;
  }
}