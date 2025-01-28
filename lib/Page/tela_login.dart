import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projeto_spotify/Utils/load_screen.dart';

import '../Utils/constants.dart';
import '../Utils/groups.dart';

class TelaLogin extends StatefulWidget {
  final Groups group;

  const TelaLogin({required this.group, super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  late TextEditingController controllerUserName;
  late TextEditingController controllerEmail;
  late TextEditingController controllerSenha;
  late TextEditingController controllerConfirmarSenha;

  late DatabaseReference dbRef;

  String? errorUserName;
  String? errorEmail;
  String? errorSenha;
  String? errorConfirmarSenha;

  bool login = true;
  bool loginIsOkay = true;

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

  Widget textFieldEmailSenha({
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

  void removeSpace(bool cadastro) {
    controllerEmail.text = controllerEmail.text.replaceAll(' ', '');
    controllerSenha.text = controllerSenha.text.replaceAll(' ', '');
    if (cadastro) {
      controllerConfirmarSenha.text =
          controllerConfirmarSenha.text.replaceAll(' ', '');
    }
  }

  @override
  void initState() {
    super.initState();
    controllerUserName = TextEditingController();
    controllerEmail = TextEditingController();
    controllerSenha = TextEditingController();
    controllerConfirmarSenha = TextEditingController();

    dbRef = FirebaseDatabase.instance.ref().child('Informações');
  }

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                SizedBox(
                    height: size.height * 0.30,
                    child: ClipOval(child: Image.asset('assets/icon.png'))),
                SizedBox(height: size.height * 0.05),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apelido
                    if (!login)
                      textFieldEmailSenha(
                        controller: controllerUserName,
                        errorText: errorUserName,
                        hint: 'Apelido',
                        size: size,
                      ),
                    // Email
                    textFieldEmailSenha(
                      controller: controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      errorText: errorEmail,
                      hint: 'Email',
                      size: size,
                    ),
                    // Senha
                    textFieldEmailSenha(
                      controller: controllerSenha,
                      errorText: errorSenha,
                      hint: 'Senha',
                      size: size,
                    ),
                    // Confirmar Senha
                    if (!login)
                      textFieldEmailSenha(
                        controller: controllerConfirmarSenha,
                        errorText: errorConfirmarSenha,
                        hint: 'Confirmar Senha',
                        size: size,
                      ),
                    SizedBox(height: size.height * 0.03),
                    // Login
                    loginOrCadastro(
                        texto: 'Logar',
                        onPressed: () async {
                          LoadScreen().loadingScreen(context);
                          removeSpace(false);

                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: controllerEmail.text,
                              password: controllerSenha.text,
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              if (FirebaseAuth.instance.currentUser != null) {
                                Navigator.of(context).pushNamed('/inicio');
                              }
                            }
                          } catch (error) {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            bottomError(texto: 'Conta não existe!', size: size);
                          }
                        },
                        size: size,
                        loginOrCadastro: true),
                    // Cadastro
                    loginOrCadastro(
                        texto: 'Cadastrar',
                        onPressed: () async {
                          removeSpace(true);

                          await checkValidation(
                            validation: controllerUserName.text == '',
                            errorText: 'errorUserName',
                            error: 'Apelido está vazio.',
                            size: size,
                          );

                          await checkValidation(
                            validation: controllerEmail.text == '',
                            errorText: 'errorEmail',
                            error: 'E-mail está vazio.',
                            size: size,
                          );

                          await checkValidation(
                            validation: controllerSenha.text == '',
                            errorText: 'errorSenha',
                            error: 'Senha está vazia.',
                            size: size,
                          ).then((value) async {
                            if (errorSenha == null) {
                              await checkValidation(
                                validation: controllerSenha.text != '' &&
                                    controllerSenha.text.length < 6,
                                errorText: 'errorSenha',
                                error: 'Senha deve ser maior que 6 caracteres.',
                                size: size,
                              ).then((value) async {
                                if (errorSenha == null) {
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
                              LoadScreen().loadingScreen(context);
                            }

                            errorUserName = null;
                            errorEmail = null;
                            errorSenha = null;
                            errorConfirmarSenha = null;
                            setState(() {});

                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: controllerEmail.text,
                                      password: controllerSenha.text);

                              Map<String, String> mapInfo = {
                                'Apelido': controllerUserName.text,
                                'Lista': '',
                                'Mixes': '',
                              };

                              await dbRef
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .set(mapInfo);

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                if (FirebaseAuth.instance.currentUser != null) {
                                  Navigator.of(context).pushNamed('/inicio');
                                }
                              }
                            } catch (error) {
                              if (context.mounted) {
                                Navigator.of(context).pop();

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
                    SizedBox(height: size.height * 0.03),
                    // Criar Conta / Fazer Login
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
