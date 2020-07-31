import 'package:flutter/material.dart';
import 'package:lojavirtual/helpers/validators.dart';
import 'package:lojavirtual/models/user.dart';
import 'package:lojavirtual/models/user_manager.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final User user = User();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: Consumer<UserManager>(
              builder: (_, userManager, __){
                return ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Nome Completo'),
                      enabled: !userManager.loading,
                      validator: (name){
                        if(name.isEmpty){
                          return 'Campo obrigatório';
                        }else if(name.trim().split(' ').length <=1){
                          return 'Preencha seu nome completo';
                        }
                        return null;
                      },
                      onSaved: (name) => user.name = name,
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      enabled: !userManager.loading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email){
                        if(email.isEmpty){
                          return 'Campo obrigatório';
                        }else if(!emailValid(email)){
                          return 'Email invalido';
                        }
                        return null;
                      },
                      onSaved: (email) => user.email = email,
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Senha'),
                      enabled: !userManager.loading,
                      obscureText: true,
                      validator: (pass){
                        if(pass.isEmpty){
                          return 'Campo obrigatório';
                        }else if(pass.length < 6){
                          return 'Senha muito curta';
                        }
                        return null;
                      },
                      onSaved: (pass) => user.password = pass,
                    ),
                    const SizedBox(height: 16,),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Repita a Senha'),
                      enabled: !userManager.loading,
                      obscureText: true,
                      validator: (pass){
                        if(pass.isEmpty){
                          return 'Campo obrigatório';
                        }else if(pass.length < 6){
                          return 'Senha muito curta';
                        }
                        return null;
                      },
                      onSaved: (confirmedPass) => user.confirmedPassword = confirmedPass,
                    ),
                    const SizedBox(height: 16,),
                    RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: userManager.loading ? null : (){
                        if(formKey.currentState.validate()){
                          formKey.currentState.save();

                          if(user.password != user.confirmedPassword){
                            scaffoldKey.currentState.showSnackBar(
                              const SnackBar(
                                content: Text("Senhas não coiencidem!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          userManager.signUP(
                              user: user,
                              onSucess: (){
                                Navigator.of(context).pop();
                              },
                              onFail: (e){
                                scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text("Falha ao cadastrar: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                          );
                        }
                      },
                      color: Theme.of(context).primaryColor,
                      disabledColor: Theme.of(context).primaryColor.withAlpha(100),
                      textColor: Colors.white,
                      child: userManager.loading
                      ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                      : const Text(
                        'Criar Conta',
                        style: TextStyle(
                            fontSize: 15
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}