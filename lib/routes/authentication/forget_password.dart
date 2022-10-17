import 'package:flutter/material.dart';
import 'package:idehshop/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthenticationBloc _authenticationBloc;
  SharedPreferences _pref;

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
            if (state is ShowMessageAuthenticationState) {
              final snackBar = SnackBar(content: Text(state.message));
              Scaffold.of(context).showSnackBar(snackBar);
            }
            if (state is LoggedInAuthenticationState) {
              Navigator.pushReplacementNamed(context, '/homePage');
            }
            if (state is VerifiedAuthenticationState) {
              Navigator.pushNamed(context, '/verifycode');
            }
            if (state is JwtExpiredAuthenticationState) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            hintText: 'شماره تلفن *',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return value.isEmpty
                                ? 'فیلد شماره تلفن اجباری است'
                                : null;
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
        _authenticationBloc.mobile = _numberController.text;
        _authenticationBloc
            .add(ForgetPassSubmitAuthenticationEvent(pref: _pref));
      }
    }
  }

  _getPref() async {
    _pref = await SharedPreferences.getInstance();
  }
}
