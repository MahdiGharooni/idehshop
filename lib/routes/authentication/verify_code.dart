import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCode extends StatefulWidget {
  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final _verifyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var snackBar;
  SharedPreferences _pref;

  // when user come to this page after forgotten password, should reset pass

  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _getPref();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is VerifiedAuthenticationState) {
              if (state.userShouldChangePass) {
                Navigator.pushNamed(context, '/changePass');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            }
            if (state is ShowMessageAuthenticationState) {
              final snackBar = SnackBar(content: Text(state.message));
              Scaffold.of(context).showSnackBar(snackBar);
            }
            if (state is JwtExpiredAuthenticationState) {
              Navigator.pushReplacementNamed(context, '/login');
            }
            if (state is LoggedInAuthenticationState) {
              Navigator.pushReplacementNamed(context, '/homePage');
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'لطفا کد امنیتی را وارد کنید.',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.button.color,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
                      ),
                      Container(
                        child: TextFormField(
                          controller: _verifyController,
                          decoration: InputDecoration(
                            hintText: 'کد امنیتی',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            return value.isEmpty ? 'فیلد کد اجباری است' : null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
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
                                style: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.button.color,
                                ),
                              ),
                        onPressed: () => _onPressed(state),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  key: _formKey,
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

  _onPressed(state) async {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        _authenticationBloc.verifyCode = _verifyController.text;
        if (state is VerifiedAuthenticationState &&
            state.userShouldChangePass) {
          _authenticationBloc.userShouldChangePass = state.userShouldChangePass;
        }
        _authenticationBloc.add(VerifySubmitAuthenticationEvent(pref: _pref));
      }
    }
  }

  @override
  void dispose() {
    _verifyController.dispose();
    super.dispose();
  }

  _getPref() async {
    _pref = await SharedPreferences.getInstance();
  }
}
