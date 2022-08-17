import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/drawer_row.dart';

class StorePageDrawer extends StatelessWidget {
  final BuildContext context;

  final StoreBloc storeBloc;

  StorePageDrawer({
    @required this.context,
    @required this.storeBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: storeBloc.currentStore.imageAddress != null &&
                          storeBloc.currentStore.imageAddress.length > 5
                      ? NetworkImage(
                          "http://${storeBloc.currentStore.imageAddress}",
                        )
                      : AssetImage(
                          'assets/images/default_basket.png',
                        ),
                  fit: BoxFit.fitWidth,
                ),
                color: Theme.of(context).accentColor,
              ),
            ),
            Divider(
              height: 0,
            ),
            DrawerRow(
              icon: Icon(
                Icons.store_mall_directory,
                color: Theme.of(context).accentColor,
              ),
              label: 'اطلاعات فروشگاه',
              inkwellOnTap: () {
                Navigator.of(context).pushNamed('/storeDetails');
              },
            ),
            Divider(
              height: 0,
            ),
            DrawerRow(
              icon: Icon(
                Icons.web_outlined,
                color: Theme.of(context).accentColor,
              ),
              label: 'سایت اختصاصی',
              inkwellOnTap: () {
                Navigator.of(context).pushNamed('/activateSite');
              },
            ),
            Divider(
              height: 0,
            ),
            DrawerRow(
              icon: Icon(
                Icons.insert_chart_outlined,
                color: Theme.of(context).accentColor,
              ),
              label: 'گزارش‌گیری همه محصولات',
              inkwellOnTap: () {
                Navigator.of(context).pushNamed('/storeReport');
              },
            ),
            Divider(
              height: 0,
            ),
            DrawerRow(
              icon: Icon(
                Icons.monetization_on_outlined,
                color: Theme.of(context).accentColor,
              ),
              label: 'تسویه حساب',
              inkwellOnTap: () {
                Navigator.of(context).pushNamed('/settlement');
              },
            ),
            Divider(
              height: 0,
            ),
          ],
        );
      },
      cubit: storeBloc,
    );
  }
}
