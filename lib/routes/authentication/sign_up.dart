import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
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
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SignedUpAuthenticationState) {
            Navigator.pushNamed(context, '/verifycode');
            return null;
          }
          if (state is ShowMessageAuthenticationState) {
            final snackBar = SnackBar(content: Text(state.message));
            Scaffold.of(context).showSnackBar(snackBar);
          }
          if (state is LoggedInAuthenticationState) {
            Navigator.pushReplacementNamed(context, '/homePage');
          }
          if (state is JwtExpiredAuthenticationState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        builder: (context, state) {
          return Container(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                          autocorrect: false,
                          controller: _numberController,
                          decoration: InputDecoration(
                            hintText: 'شماره موبایل* (مثل ۰۹۱۲۳۴۵۶۷۸۹)',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            return value.isEmpty
                                ? 'فیلد موبایل اجباری است'
                                : null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
                      ),
                      Container(
                        child: TextFormField(
                          autocorrect: false,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'رمزعبور* (حداقل 6 کاراکتر):',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          validator: (String value) {
                            return value.isEmpty ? 'فیلد رمز اجباری است' : null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
                      ),
                      InkWell(
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'قوانین و حریم خصوصی ایده شاپ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        color: Colors.white,
                                      ),
                                ),
                                TextSpan(text: ' را خوانده و میپذیرم.'),
                              ],
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.white,
                                      ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 10.0),
                        ),
                        onTap: _privacyPolicy,
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
                                'ثبت نام',
                                style: Theme.of(context).textTheme.button,
                              ),
                        onPressed: _onPressed,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        child: GestureDetector(
                          child: Text(
                            'ورود',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.button.color,
                            ),
                          ),
                          onTap: _onLogin,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  key: _formKey,
                ),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login.png"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        cubit: _authenticationBloc,
      ),
    );
  }

  _onLogin() {
    Navigator.pushNamed(context, '/login');
  }

  _onPressed() async {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        _authenticationBloc.context = context;
        _authenticationBloc.password = _passwordController.text;
        _authenticationBloc.mobile = _numberController.text;
        _authenticationBloc.add(SignUpSubmitAuthenticationEvent());
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _privacyPolicy() async {
    final url = PRIVACY_URI;
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }
}
