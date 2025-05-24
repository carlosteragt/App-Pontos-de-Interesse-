import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/ponto_interesse.dart';
import 'services/localizacao_servico.dart';
import 'services/pontos_servico.dart';

void main() => runApp(const MeuApp());

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  Position? _localizacaoAtual;
  List<PontoInteresse> _pontos = [];

  @override
  void initState() {
    super.initState();
    _atualizarLocalizacao();
    _carregarPontos();
  }

  Future<void> _atualizarLocalizacao() async {
    try {
      final posicao = await LocalizacaoServico.pegarLocalizacaoAtual();
      setState(() => _localizacaoAtual = posicao);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: ${e.toString()}")));
    }
  }

  Future<void> _carregarPontos() async {
    final pontos = await PontosServico.carregarPontos();
    setState(() => _pontos = pontos);
  }

  void _mostrarFormularioPonto() {
    showDialog(
      context: context,
      builder: (ctx) => AdicionarPonto(
        aoSalvar: _carregarPontos,
        localizacaoAtual: _localizacaoAtual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Localizador de Pontos de Interesse")),
      body: Column(
        children: [
          if (_localizacaoAtual != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "📍 Posição atual: ${_localizacaoAtual!.latitude.toStringAsFixed(4)}, ${_localizacaoAtual!.longitude.toStringAsFixed(4)}",
                style: TextStyle(color: Colors.blue[200]),
              ),
            ),
          Expanded(
            child: _pontos.isEmpty
                ? const Center(child: Text("Nenhum ponto cadastrado."))
                : ListaPontos(
                    localizacaoAtual: _localizacaoAtual,
                    pontos: _pontos,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _localizacaoAtual != null ? _mostrarFormularioPonto : null,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ListaPontos extends StatelessWidget {
  final Position? localizacaoAtual;
  final List<PontoInteresse> pontos;

  const ListaPontos({
    super.key,
    required this.localizacaoAtual,
    required this.pontos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pontos.length,
      itemBuilder: (ctx, index) {
        final ponto = pontos[index];
        final distancia = localizacaoAtual != null
            ? LocalizacaoServico.calcularDistancia(
                localizacaoAtual!.latitude,
                localizacaoAtual!.longitude,
                ponto.latitude,
                ponto.longitude,
              )
            : 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(ponto.nome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ponto.descricao),
                Text(
                  "Distância: ${distancia.toStringAsFixed(2)} metros",
                  style: TextStyle(color: Colors.blue[300]),
                ),
              ],
            ),
            trailing: const Icon(Icons.location_pin, color: Colors.blue),
          ),
        );
      },
    );
  }
}

class AdicionarPonto extends StatefulWidget {
  final Function() aoSalvar;
  final Position? localizacaoAtual;

  const AdicionarPonto({
    super.key,
    required this.aoSalvar,
    this.localizacaoAtual,
  });

  @override
  _AdicionarPontoState createState() => _AdicionarPontoState();
}

class _AdicionarPontoState extends State<AdicionarPonto> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.localizacaoAtual != null) {
      _latController.text = widget.localizacaoAtual!.latitude.toStringAsFixed(
        6,
      );
      _longController.text = widget.localizacaoAtual!.longitude.toStringAsFixed(
        6,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cadastrar Ponto de Interesse"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome*"),
                validator: (value) => value!.isEmpty ? "Obrigatório" : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              const SizedBox(height: 16),
              const Text(
                "Coordenadas:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: "Latitude*"),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _longController,
                      decoration: const InputDecoration(
                        labelText: "Longitude*",
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                ],
              ),
              if (widget.localizacaoAtual != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _latController.text = widget.localizacaoAtual!.latitude
                          .toStringAsFixed(6);
                      _longController.text = widget.localizacaoAtual!.longitude
                          .toStringAsFixed(6);
                    });
                  },
                  child: const Text("Usar minha localização atual"),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(onPressed: _salvarPonto, child: const Text("Salvar")),
      ],
    );
  }

  void _salvarPonto() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoPonto = PontoInteresse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text,
          descricao: _descricaoController.text,
          latitude: double.parse(_latController.text),
          longitude: double.parse(_longController.text),
        );

        await PontosServico.salvarPonto(novoPonto);
        widget.aoSalvar();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Verifique as coordenadas. Ex: -22.223611227470748, -45.943325256361426",
            ),
          ),
        );
      }
    }
  }
}
