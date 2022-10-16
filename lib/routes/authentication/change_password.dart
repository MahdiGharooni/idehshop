import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is ShouldLoginAuthenticationState) {
              Navigator.pushNamed(context, '/login');
            }
            if (state is JwtExpiredAuthenticationState) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        children: [
                          Container(
                            child: TextFormField(
                              controller: _passController,
                              decoration: InputDecoration(
                                hintText: 'رمزعبور جدید *',
                              ),
                              textDirection: TextDirection.ltr,
                              obscureText: true,
                              validator: (String value) {
                                return value.isEmpty
                                    ? 'فیلد رمز  اجباری است'
                                    : value == _passController.text
                                        ? null
                                        : 'تکرار رمز مطابقت ندارد';
                              },
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 50.0,
                              vertical: 10.0,
                            ),
                          ),
                          RaisedButton(
                            child: (state is LoadingAuthenticationState)
                                ? Container(
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                  )
                                : Text(
                                    'تایید',
                                    style: Theme.of(context).textTheme.button,
                                  ),
                            onPressed: _onPressed,
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      key: _formKey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: GestureDetector(
                        child: Text(
                          'ورود',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.button.color,
                          ),
                        ),
                        onTap: () => _goLogin(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          cubit: _authenticationBloc,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  _onPressed() {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        _authenticationBloc.newPass = _passController.text;
        _authenticationBloc.add(ChangePassSubmitAuthenticationEvent());
      }
    }
  }

  _goLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }
}
