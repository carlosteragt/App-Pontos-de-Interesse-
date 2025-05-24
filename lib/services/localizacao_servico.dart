import 'package:geolocator/geolocator.dart';

class LocalizacaoServico {
  static Future<Position> pegarLocalizacaoAtual() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) throw Exception('GPS desligado');

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) throw Exception('Permissão negada');
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception('Permissão negada permanentemente');
    }

    return await Geolocator.getCurrentPosition();
  }

  static double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}