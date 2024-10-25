import 'package:campus_sync/src/models/colors/colors.dart';
import 'package:campus_sync/src/views/pages/cadastro_page.dart';
import 'package:campus_sync/src/views/pages/listagem_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class EntidadePage extends StatelessWidget {
  final String titulo;
  final String endpoint;

  const EntidadePage({super.key, required this.titulo, required this.endpoint});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, String>> fieldMappings = {
      'Matriculas': {
        'title': 'estudante',
        'subtitle1': 'curso',
        'subtitle2': 'periodoCurso',
      },
      'Faculdades': {
        'title': 'nomeFaculdade',
        'subtitle1': 'tipoFacul',
        'subtitle2': 'universidade',
      },
      'Estudantes': {
        'title': 'nome',
        'subtitle1': 'cpf',
        'subtitle2': 'email',
      },
      'Professores': {
        'title': 'nome',
        'subtitle1': 'cpf',
        'subtitle2': 'departamento',
      },
      'Funcionarios': {
        'title': 'nome',
        'subtitle1': 'cargo',
        'subtitle2': 'cpf',
      },
      'Cursos': {
        'title': 'descricao',
        'subtitle1': 'mensalidade',
        'subtitle2': 'faculdade',
      },
      'Universidades': {
        'title': 'nomeUniversidade',
        'subtitle1': 'sigla',
        'subtitle2': 'cidade',
      },
      'Enderecos': {
        'title': 'logradouro',
        'subtitle1': 'numero',
        'subtitle2': 'cidade',
      },
      'FaculdadeProfessor': {
        'title': 'professor',
        'subtitle1': 'faculdade',
        'subtitle2': 'departamento',
      },
      'Users': {
        'title': 'nome',
        'subtitle1': 'email',
        'subtitle2': 'cpf',
      },
    };

    formatarData(String data) {
      initializeDateFormatting('pt_BR');
      var formatador = DateFormat('dd/MM/yyyy');
      DateTime dataConvertida = DateTime.parse(data);
      String dataFormatada = formatador.format(dataConvertida);
      return dataFormatada;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhiteColor,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 120,
                child: GestureDetector(
                    onTap: () {
                      Map<String, dynamic> initialData = {};

                      switch (endpoint) {
                        case 'Matriculas':
                          initialData = {
                            'EstudanteId': null,
                            'CursoId': null,
                            'PeriodoCurso': 'Manha',
                            'DataMatricula':
                                formatarData(DateTime.now().toString()),
                          };
                          break;
                        case 'Faculdades':
                          initialData = {
                            'Nome': '',
                            'EnderecoRua': '',
                            'EnderecoCidade': '',
                            'EnderecoEstado': '',
                            'EnderecoCEP': null,
                            'TipoFacul': 'Privada',
                            'UniversidadeId': null,
                          };
                          break;
                        case 'Estudantes':
                          initialData = {
                            'Nome': '',
                            'Email': '',
                            'CPF': '',
                            'NumEstudante': null,
                            'EnderecoRua': '',
                            'EnderecoCidade': '',
                            'EnderecoEstado': '',
                            'EnderecoCEP': null,
                          };
                          break;
                        case 'Professores':
                          initialData = {
                            'Nome': '',
                            'Email': '',
                            'Formacoes': '',
                            'Salario': null,
                            'EnderecoRua': '',
                            'EnderecoCidade': '',
                            'EnderecoEstado': '',
                            'EnderecoCEP': null,
                          };
                          break;
                        case 'Funcionarios':
                          initialData = {
                            'Nome': '',
                            'Email': '',
                            'Cargo': '',
                            'Salario': null,
                            'EnderecoRua': '',
                            'EnderecoCidade': '',
                            'EnderecoEstado': '',
                            'EnderecoCEP': null,
                          };
                          break;
                        case 'Cursos':
                          initialData = {
                            'Descricao': '',
                            'Mensalidade': null,
                            'FaculdadeId': null,
                          };
                          break;
                        case 'Universidades':
                          initialData = {
                            'Nome': '',
                            'EnderecoRua': '',
                            'EnderecoCidade': '',
                            'EnderecoEstado': '',
                            'EnderecoCEP': null,
                            'ContatoInfo': '',
                          };
                          break;
                        case 'Enderecos':
                          initialData = {
                            'Rua': '',
                            'Cidade': '',
                            'Estado': '',
                            'CEP': null,
                          };
                          break;
                        case 'FaculdadeProfessor':
                          initialData = {
                            'ProfessorId': null,
                            'FaculdadeId': null,
                          };
                          break;
                        case 'Users':
                          initialData = {
                            'CPF': '',
                            'Nome': '',
                            'Email': '',
                            'Celular': '',
                            'Senha': '',
                          };
                          break;
                        default:
                          initialData = {};
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CadastroPage(
                            endpoint: endpoint,
                            initialData: initialData,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.lightGreyColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.backgroundBlueColor,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.backgroundBlueColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 120,
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListagemPage(
                            endpoint: endpoint,
                            fieldMapping: fieldMappings[endpoint] ?? {},
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.lightGreyColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_list_bulleted_outlined,
                            color: AppColors.backgroundBlueColor,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Listar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.backgroundBlueColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
