class PontoInteresse {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;

  PontoInteresse({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory PontoInteresse.fromJson(Map<String, dynamic> json) => PontoInteresse(
        id: json['id'],
        nome: json['nome'],
        descricao: json['descricao'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}