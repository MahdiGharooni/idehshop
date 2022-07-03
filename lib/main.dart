import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/managers/theme_manager.dart';
import 'package:idehshop/routes/authentication/change_password.dart';
import 'package:idehshop/routes/authentication/forget_password.dart';
import 'package:idehshop/routes/authentication/launch_page.dart';
import 'package:idehshop/routes/authentication/login_page.dart';
import 'package:idehshop/routes/authentication/sign_up.dart';
import 'package:idehshop/routes/authentication/verify_code.dart';
import 'package:idehshop/routes/buying_page/buying_page.dart';
import 'package:idehshop/routes/home_page/home_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/home_tab/category_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/home_tab/customer_product_category_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/home_tab/customer_product_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/home_tab/customer_store_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/about_us_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/marketer_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/create_store_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_reporting_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_pay_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_settings_tab/store_activate_site.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_settings_tab/store_details_edit_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_settings_tab/store_details_location_edit.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_settings_tab/store_details_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_settings_tab/store_settlement_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/profile/addresses/add_address_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/profile/addresses/addresses_list.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/profile/profile_edit_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/profile/profile_page.dart';
import 'package:location/location.dart';

import 'routes/home_page/home_tabs/settings_tab/profile/charge_wallet_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (BuildContext context) => LocationBloc(),
        ),
        BlocProvider<StoreBloc>(
          create: (BuildContext context) => StoreBloc(
            locationBloc: BlocProvider.of<LocationBloc>(context),
          ),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(
            storeBloc: BlocProvider.of<StoreBloc>(context),
          ),
        ),
        BlocProvider<PermissionBloc>(
          create: (BuildContext context) => PermissionBloc(
            locationService: PermissionService(
              location: Location(),
            ),
          ),
        ),
        BlocProvider<ShoppingBloc>(
          create: (BuildContext context) => ShoppingBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          ),
        ),
      ],
      child: MaterialApp(
        checkerboardOffscreenLayers: false,
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        home: LaunchPage(),
        theme: lightIdehShopTheme.data,
        onGenerateRoute: (RouteSettings settings) {
          Widget route;
          List<String> substringsList = settings.name.split('/');
          switch (substringsList[1]) {

          /// example : /categoryPage
//            case 'category':
//              final CategoryPageArguments args = settings.arguments;
//              route = CategoryPage(
//                permissionBloc: args.permissionBloc,
//              );
//              break;
          }
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return route;
            },
            settings: settings,
          );
        },
        routes: {
          '/homePage': (context) => HomePage(),
          '/launch': (context) => LaunchPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUp(),
          '/verifycode': (context) => VerifyCode(),
          '/forgetPass': (context) => ForgetPassword(),
          '/changePass': (context) => ChangePassword(),
          '/profile': (context) => ProfilePage(),
          '/profileEdit': (context) => ProfileEditPage(),
          '/createstore': (context) => CreateStorePage(),
          '/store': (context) => StorePage(),
          '/customerStorePage': (context) => CustomerStorePage(),
          '/customerProductCategoryPage': (context) =>
              CustomerProductCategoryPage(),
          '/customerProductPage': (context) => CustomerProductPage(),
          '/category': (context) => CategoryPage(),
          '/buying': (context) => BuyingPage(),
          '/addressesList': (context) => AddressesList(),
          '/addressesPage': (context) => AddAddressPage(),
          '/storeDetails': (context) => StoreDetailsPage(),
          '/storeDetailsEdit': (context) => StoreDetailsEditPage(),
          '/storePay': (context) => StorePayPage(),
          '/storeLocationEdit': (context) => StoreDetailsLocationEdit(),
          '/chargeWallet': (context) => ChargeWalletPage(),
          '/aboutUs': (context) => AboutUsPage(),
          '/settlement': (context) => StoreSettlementPage(),
          '/activateSite': (context) => StoreActivateSite(),
          '/marketerPage': (context) => MarketerPage(),
          '/storeReport': (context) => StoreReportingPage(),
        },
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fa', ''),
        ],
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
        title: 'idehshop',
      ),
    );
  }
}
