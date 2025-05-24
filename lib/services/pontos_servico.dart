import 'package:shared_preferences/shared_preferences.dart';
import '../models/ponto_interesse.dart';
import 'dart:convert';

class PontosServico {
  static const String _chavePontos = 'pontos_salvos';

  static Future<List<PontoInteresse>> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final pontosJson = prefs.getStringList(_chavePontos) ?? [];
    return pontosJson.map((json) => PontoInteresse.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> salvarPonto(PontoInteresse ponto) async {
    final prefs = await SharedPreferences.getInstance();
    final pontos = await carregarPontos();
    pontos.add(ponto);
    await prefs.setStringList(
      _chavePontos,
      pontos.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}