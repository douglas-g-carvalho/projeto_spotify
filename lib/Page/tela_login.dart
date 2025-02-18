import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projeto_spotify/Utils/load_screen.dart';

import '../Utils/constants.dart';
import '../Utils/groups.dart';

// Classe para realizar o login ou cadastro.
class TelaLogin extends StatefulWidget {
  final Groups group;

  const TelaLogin({required this.group, super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Controles de Texto para os TextFormFields.
  late TextEditingController controllerUserName;
  late TextEditingController controllerEmail;
  late TextEditingController controllerSenha;
  late TextEditingController controllerConfirmarSenha;

  // Referência ao arquivo 'Informação' do Firebase.
  late DatabaseReference dbRef;

  // String de possíveis erros.
  String? errorUserName;
  String? errorEmail;
  String? errorSenha;
  String? errorConfirmarSenha;

  // Booleano para checagem.
  bool login = true;
  bool loginIsOkay = true;

  // Função para verificar caso exista algum erro nos TextFormFields e avisar ao usuário.
  Future<void> checkValidation({
    required bool validation,
    required String? errorText,
    required String error,
    required Size size,
  }) async {
    if (validation) {
      switch (errorText) {
        case 'errorUserName':
          errorUserName = error;

        case 'errorEmail':
          errorEmail = error;

        case 'errorSenha':
          errorSenha = error;

        case 'errorConfirmarSenha':
          errorConfirmarSenha = error;
      }
      setState(() {});
      await bottomError(texto: error, size: size);
      loginIsOkay = false;
    } else {
      switch (errorText) {
        case 'errorUserName':
          errorUserName = null;

        case 'errorEmail':
          errorEmail = null;

        case 'errorSenha':
          errorSenha = null;

        case 'errorConfirmarSenha':
          errorConfirmarSenha = null;
      }
      setState(() {});
    }
  }

  // Função para criar um TextFormField personalizado para Apelido/E-mail/Senha/ConfirmarSenha.
  Widget textFormFieldEmailSenha({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required String? errorText,
    required String hint,
    required Size size,
  }) {
    return SizedBox(
      width: size.width * 0.80,
      child: TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.045,
        ),
        decoration: InputDecoration(
          errorText: errorText,
          errorStyle: TextStyle(fontSize: size.height * 0.02),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        cursorColor: Colors.white,
        keyboardType: keyboardType ?? TextInputType.text,
        controller: controller,
      ),
    );
  }

  // Função para criar um TextButton personalizado para Login/Cadastro.
  Widget loginOrCadastro({
    required String texto,
    required VoidCallback onPressed,
    required Size size,
    required bool loginOrCadastro,
  }) {
    if (login == loginOrCadastro) {
      return TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.color[700],
          ),
          onPressed: onPressed,
          child: Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.07,
            ),
          ));
    } else {
      return Placeholder(
        color: Colors.transparent,
        fallbackWidth: 0,
        fallbackHeight: 0,
      );
    }
  }

  // Função para mostrar um erro na parte de baixo da tela.
  Future<void> bottomError({required String texto, required Size size}) {
    return showModalBottomSheet(
        backgroundColor: Colors.red[900],
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return SizedBox(
            height: size.height * 0.05,
            width: size.width,
            child: TextButton(
                onPressed: () {},
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: size.height * 0.02,
                    color: Colors.white,
                  ),
                )),
          );
        });
  }

  // Função para converter a mensagem de erro do firabase para o português.
  String errorConvert(String error) {
    switch (error) {
      case '[firebase_auth/invalid-email] The email address is badly formatted.':
        return 'O e-mail está mal formatado.';

      case '[firebase_auth/weak-password] Password should be at least 6 characters':
        return 'A senha deve ter pelo menos 6 caracteres!';

      case '[firebase_auth/channel-error] "dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.createUserWithEmailAndPassword".':
        return 'Erro ao criar conta.';

      case _:
        return 'Error';
    }
  }

  // Função para remover espaço no Texto dos TextFields.
  void removeSpace(bool cadastro) {
    controllerEmail.text = controllerEmail.text.replaceAll(' ', '');
    controllerSenha.text = controllerSenha.text.replaceAll(' ', '');
    if (cadastro) {
      controllerConfirmarSenha.text =
          controllerConfirmarSenha.text.replaceAll(' ', '');
    }
  }

  // Função do Flutter para quando a Página iniciar.
  @override
  void initState() {
    super.initState();
    // Atribuindo os Editores de Texto.
    controllerUserName = TextEditingController();
    controllerEmail = TextEditingController();
    controllerSenha = TextEditingController();
    controllerConfirmarSenha = TextEditingController();

    dbRef = FirebaseDatabase.instance.ref().child('Informações');
  }

  // Função do Flutter para quando a Página fechar.
  @override
  void dispose() {
    controllerUserName.dispose();
    controllerEmail.dispose();
    controllerSenha.dispose();
    controllerConfirmarSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // Dar um espaço separar do topo da tela.
                SizedBox(height: size.height * 0.05),
                // Coloca o ícone na tela com tamaho especificado e forma oval.
                SizedBox(
                    height: size.height * 0.30,
                    child: ClipOval(child: Image.asset('assets/icon.png'))),
                // Dar um espaço entre os Widget's.
                SizedBox(height: size.height * 0.05),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TextFormField do Apelido.
                    if (!login)
                      textFormFieldEmailSenha(
                        controller: controllerUserName,
                        errorText: errorUserName,
                        hint: 'Apelido',
                        size: size,
                      ),
                    // TextFormField do Email.
                    textFormFieldEmailSenha(
                      controller: controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      errorText: errorEmail,
                      hint: 'Email',
                      size: size,
                    ),
                    // TextFormField do Senha.
                    textFormFieldEmailSenha(
                      controller: controllerSenha,
                      errorText: errorSenha,
                      hint: 'Senha',
                      size: size,
                    ),
                    // TextFormField do ConfirmarSenha.
                    if (!login)
                      textFormFieldEmailSenha(
                        controller: controllerConfirmarSenha,
                        errorText: errorConfirmarSenha,
                        hint: 'Confirmar Senha',
                        size: size,
                      ),
                    // Dar um espaço entre os Widget's.
                    SizedBox(height: size.height * 0.03),
                    // TextButton do Login.
                    loginOrCadastro(
                        texto: 'Logar',
                        onPressed: () async {
                          // Tela de Carregamento.
                          LoadScreen().loadingScreen(context);
                          // Explicação se encontra na Função.
                          removeSpace(false);

                          try {
                            // Função do Firebase para fazer login.
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: controllerEmail.text,
                              password: controllerSenha.text,
                            );

                            if (context.mounted) {
                              // Remove a tela que está no topo, que atualmente é a de carregamento.
                              Navigator.of(context).pop();
                              if (FirebaseAuth.instance.currentUser != null) {
                                // Vai para a tela_inicial.
                                Navigator.of(context).pushNamed('/inicio');
                              }
                            }
                          } catch (error) {
                            if (context.mounted) {
                              // Remove a tela que está no topo, que atualmente é a de carregamento.
                              Navigator.of(context).pop();
                            }

                            // Explicação se encontra na Função.
                            bottomError(texto: 'Conta não existe!', size: size);
                          }
                        },
                        size: size,
                        loginOrCadastro: true),
                    // TextButton do Cadastro.
                    loginOrCadastro(
                        texto: 'Cadastrar',
                        onPressed: () async {
                          // Explicação se encontra na Função.
                          removeSpace(true);

                          // Validação do Apelido.
                          await checkValidation(
                            validation: controllerUserName.text == '',
                            errorText: 'errorUserName',
                            error: 'Apelido está vazio.',
                            size: size,
                          );

                          // Validação do E-mail.
                          await checkValidation(
                            validation: controllerEmail.text == '',
                            errorText: 'errorEmail',
                            error: 'E-mail está vazio.',
                            size: size,
                          );

                          // Validação da Senha.
                          await checkValidation(
                            validation: controllerSenha.text == '',
                            errorText: 'errorSenha',
                            error: 'Senha está vazia.',
                            size: size,
                          ).then((value) async {
                            if (errorSenha == null) {
                              // Validação da Senha.
                              await checkValidation(
                                validation: controllerSenha.text != '' &&
                                    controllerSenha.text.length < 6,
                                errorText: 'errorSenha',
                                error: 'Senha deve ser maior que 6 caracteres.',
                                size: size,
                              ).then((value) async {
                                if (errorSenha == null) {
                                  // Validação do ConfirmarSenha.
                                  await checkValidation(
                                    validation: controllerSenha.text !=
                                        controllerConfirmarSenha.text,
                                    errorText: 'errorConfirmarSenha',
                                    error: 'As Senhas são diferentes!',
                                    size: size,
                                  );
                                }
                              });
                            }
                            errorConfirmarSenha = null;
                            setState(() {});
                          });

                          if (loginIsOkay) {
                            if (context.mounted) {
                              // Tela de Carregamento.
                              LoadScreen().loadingScreen(context);
                            }

                            errorUserName = null;
                            errorEmail = null;
                            errorSenha = null;
                            errorConfirmarSenha = null;
                            setState(() {});

                            try {
                              // Cadastra conta no Firebase.
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: controllerEmail.text,
                                      password: controllerSenha.text);

                              // Salva o apelido e cria a Lista e Mixes vazio.
                              Map<String, String> mapInfo = {
                                'Apelido': controllerUserName.text,
                                'ID Music': '',
                              };

                              // Adiciona na database do Firebase.
                              await dbRef
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .set(mapInfo);

                              if (context.mounted) {
                                // Remove a tela que está no topo, que atualmente é a de carregamento.
                                Navigator.of(context).pop();
                                if (FirebaseAuth.instance.currentUser != null) {
                                  // Vai para tela_inicial.
                                  Navigator.of(context).pushNamed('/inicio');
                                }
                              }
                            } catch (error) {
                              if (context.mounted) {
                                // Remove a tela que está no topo, que atualmente é a de carregamento.
                                Navigator.of(context).pop();

                                // Explicação se encontra na Função.
                                bottomError(
                                    texto: errorConvert(error.toString()),
                                    size: size);
                              }
                            }
                          }
                          loginIsOkay = true;
                        },
                        size: size,
                        loginOrCadastro: false),
                    // Dar um espaço entre os Widget's.
                    SizedBox(height: size.height * 0.03),
                    // TextButton para trocar entre Criar Conta / Fazer Login.
                    TextButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.color[700],
                        ),
                        onPressed: () {
                          setState(() => login = !login);
                        },
                        child: Text(
                          login
                              ? 'Não tem conta? Crie Uma!'
                              : 'Já tem conta? Faça Login!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.035,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
