import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class Categoria {
  String nome;
  int iconeIndex;
  double horasGastadas;

  Categoria({required this.nome, required this.iconeIndex, this.horasGastadas = 0});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Categoria> categorias = [];
  List<String> historico = [];
  final List<IconData> iconesComuns = [
    Icons.work, Icons.school, Icons.sports_soccer, Icons.sports_basketball,
    Icons.weekend, Icons.pets, Icons.home, Icons.computer, Icons.local_cafe,
    Icons.directions_car, Icons.shopping_cart, Icons.fastfood, Icons.local_florist,
    Icons.music_note, Icons.movie, Icons.book, Icons.build, Icons.beach_access,
    Icons.fitness_center, Icons.child_friendly,
  ];

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregarHistorico();
  }

  // Função para salvar as categorias
  void _salvarCategorias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> nomes = categorias.map((c) => c.nome).toList();
    List<String> icones = categorias.map((c) => c.iconeIndex.toString()).toList();
    List<String> horas = categorias.map((c) => c.horasGastadas.toString()).toList();
    
    await prefs.setStringList('categorias_nomes', nomes);
    await prefs.setStringList('categorias_icones', icones);
    await prefs.setStringList('categorias_horas', horas);
  }

  // Função para carregar as categorias
  void _carregarCategorias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? nomes = prefs.getStringList('categorias_nomes');
    List<String>? icones = prefs.getStringList('categorias_icones');
    List<String>? horas = prefs.getStringList('categorias_horas');

    if (nomes != null && icones != null && horas != null) {
      setState(() {
        categorias = List.generate(nomes.length, (index) {
          return Categoria(
            nome: nomes[index],
            iconeIndex: int.parse(icones[index]),
            horasGastadas: double.parse(horas[index]),
          );
        });
      });
    }
  }

  // Função para salvar o histórico
  void _salvarHistorico() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('historico', historico);
  }

  // Função para carregar o histórico
  void _carregarHistorico() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historicoSalvo = prefs.getStringList('historico');

    if (historicoSalvo != null) {
      setState(() {
        historico = historicoSalvo;
      });
    }
  }

  // Função para adicionar uma nova categoria
  void _adicionarCategoria() async {
    String nome = '';
    int iconeSelecionado = 0;
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nova Categoria"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nome da Categoria'),
                onChanged: (value) {
                  nome = value;
                },
              ),
              DropdownButton<int>(
                value: iconeSelecionado,
                items: List.generate(iconesComuns.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Icon(iconesComuns[index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    iconeSelecionado = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nome.isNotEmpty) {
                  setState(() {
                    categorias.add(Categoria(nome: nome, iconeIndex: iconeSelecionado));
                  });
                  _salvarCategorias();
                }
                Navigator.of(context).pop();
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      }
    );
  }

  // Função para adicionar horas a uma categoria
  void _adicionarHoras(Categoria categoria) async {
    double horas = categoria.horasGastadas;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adicionar Horas a ${categoria.nome}"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Horas Gastas'),
            onChanged: (value) {
              horas = double.tryParse(value) ?? categoria.horasGastadas;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  categoria.horasGastadas = horas;
                  _salvarCategorias();
                });
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      }
    );
  }

  // Função para salvar o histórico ao final do dia
  void _salvarHistoricoDiario() {
    String dataAtual = DateTime.now().toString().substring(0, 10);
    String registro = 'Data: $dataAtual\n';
    for (var categoria in categorias) {
      registro += '${categoria.nome}: ${categoria.horasGastadas}h\n';
    }

    setState(() {
      historico.add(registro);
      for (var categoria in categorias) {
        categoria.horasGastadas = 0;
      }
      _salvarHistorico();
      _salvarCategorias();
    });
  }

  // Tela do histórico
  void _abrirHistorico() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return HistoricoPage(historico: historico);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _abrirHistorico,
          ),
        ],
      ),
      body: categorias.isEmpty
          ? Center(child: Text('Nenhuma categoria adicionada.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return GestureDetector(
                  onTap: () => _adicionarHoras(categoria),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconesComuns[categoria.iconeIndex], size: 40),
                        SizedBox(height: 10),
                        Text(categoria.nome),
                        Text('${categoria.horasGastadas}h'),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarCategoria,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          onPressed: _salvarHistoricoDiario,
          child: Text('Salvar Histórico Diário'),
        ),
      ),
    );
  }
}

// Tela de Histórico
class HistoricoPage extends StatelessWidget {
  final List<String> historico;

  HistoricoPage({required this.historico});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Horas'),
      ),
      body: ListView.builder(
        itemCount: historico.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(historico[index]),
          );
        },
      ),
    );
  }
}