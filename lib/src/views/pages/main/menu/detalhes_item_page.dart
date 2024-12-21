import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetalhesItemPage extends StatelessWidget {
  final String titulo;
  final Map<String, dynamic> dados;

  const DetalhesItemPage({
    super.key,
    required this.titulo,
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text('Detalhes de $titulo'),
        shadowColor: Colors.black,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final headerSubtitle = dados['universidadeNome'] ??
        dados['faculdadeNome'] ??
        dados['turmaNome'] ??
        dados['cargo'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(1, 3),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            left: -40,
            child: _buildBackgroundShape(Colors.blue.shade400, 120),
          ),
          Positioned(
            bottom: -40,
            right: -50,
            child: _buildBackgroundShape(Colors.blue.shade300, 130),
          ),
          Positioned(
            top: 50,
            left: 60,
            child: _buildBackgroundShape(Colors.blue.shade700, 100),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dados['nome'] ?? 'Detalhes',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (headerSubtitle != null)
                  Text(
                    headerSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildContent() {
    switch (titulo) {
      case 'Faculdade':
        return _buildFaculdadeContent();
      case 'Curso':
        return _buildCursoContent();
      case 'Estudante':
      case 'Colaborador':
        return _buildPessoaContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildFaculdadeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailTile(
          'Tipo',
          (dados['tipoString'] == 'Publica')
              ? 'Pública'
              : (dados['tipoString'] ?? ''),
        ),
        _buildDetailTile('CNPJ', dados['cnpj'] ?? '', fieldType: 'cnpj'),
        _buildDetailTile('Contato', dados['emailResponsavel'] ?? ''),
        _buildDetailTile('Telefone', dados['telefone'] ?? '',
            fieldType: 'telefone'),
        const SizedBox(height: 16),
        const Text(
          'Endereço:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ..._buildEnderecoTiles(dados['endereco']),
      ],
    );
  }

  Widget _buildCursoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailTile(
          'Mensalidade',
          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(
            double.tryParse(dados['mensalidade'].toString()) ?? 0,
          ),
        ),
        const SizedBox(height: 16),
        _buildListSection('Disciplinas', dados['disciplinas'] ?? []),
        const SizedBox(height: 16),
        _buildListSection('Turmas', dados['turmas'] ?? []),
      ],
    );
  }

  Widget _buildPessoaContent() {
    final isEstudante = titulo == 'Estudante';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEstudante && dados['cargo'] == 'Docente')
          _buildDetailTile('Curso', dados['cursoNome']),
        const SizedBox(height: 16),
        const Text(
          'Dados:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (isEstudante)
          _buildDetailTile('Número da Matrícula', dados['numeroMatricula']),
        if (!isEstudante)
          _buildDetailTile('Número de Registro', dados['numeroRegistro']),
        _buildDetailTile('Nome', dados['nome']),
        _buildDetailTile('CPF', dados['cpf'], fieldType: 'cpf'),
        _buildDetailTile('RG', dados['rg'], fieldType: 'rg'),
        _buildDetailTile('E-mail', dados['email']),
        _buildDetailTile('Telefone', dados['telefone'], fieldType: 'telefone'),
        _buildDetailTile(
          isEstudante ? 'Data de Matrícula' : 'Data de Admissão',
          DateFormat('dd/MM/yyyy').format(
            DateTime.parse(
              isEstudante ? dados['dataMatricula'] : dados['dataAdmissao'],
            ),
          ),
        ),
        _buildDetailTile(
          'Data de Nascimento',
          DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(dados['dataNascimento'])),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dados de Confiança:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildDetailTile('Nome do Pai', dados['nomePai']),
        _buildDetailTile('Nome da Mãe', dados['nomeMae']),
        const SizedBox(height: 16),
        const Text(
          'Endereço:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ..._buildEnderecoTiles(dados['endereco']),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return const Text('Detalhes não disponíveis para este item.');
  }

  Widget _buildDetailTile(String title, String? value, {String? fieldType}) {
    final formattedValue =
        fieldType != null ? formatField(value, fieldType) : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Card(
          color: AppColors.lightGreyColor,
          elevation: 6,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formattedValue ?? 'Não informado',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          final name = item['nome'] ?? 'Sem nome';
          final subtitle = item['periodoString'] ?? '';
          return _buildDetailTile(name, subtitle);
        }),
      ],
    );
  }

  List<Widget> _buildEnderecoTiles(Map<String, dynamic>? endereco) {
    if (endereco == null) return [const Text('Endereço não disponível.')];

    return [
      _buildDetailTile('Logradouro', endereco['logradouro']),
      _buildDetailTile('Número', endereco['numero']),
      _buildDetailTile('Bairro', endereco['bairro']),
      _buildDetailTile('Cidade', endereco['cidade']),
      _buildDetailTile('Estado', endereco['estado']),
      _buildDetailTile('CEP', endereco['cep'], fieldType: 'cep'),
    ];
  }

  String formatField(String? field, String fieldType) {
    if (field == null || field.isEmpty) return 'Não informado';

    switch (fieldType) {
      case 'cpf':
        return '${field.substring(0, 3)}.${field.substring(3, 6)}.${field.substring(6, 9)}-${field.substring(9)}';
      case 'rg':
        return '${field.substring(0, 2)}.${field.substring(2, 5)}.${field.substring(5, 8)}-${field.substring(8)}';
      case 'cep':
        return '${field.substring(0, 5)}-${field.substring(5)}';
      case 'cnpj':
        return '${field.substring(0, 2)}.${field.substring(2, 5)}.${field.substring(5, 8)}/${field.substring(8, 12)}-${field.substring(12)}';
      case 'telefone':
        return field.length == 11
            ? '(${field.substring(0, 2)}) ${field.substring(2, 7)}-${field.substring(7)}'
            : '(${field.substring(0, 2)}) ${field.substring(2, 6)}-${field.substring(6)}';
      default:
        return field;
    }
  }
}
