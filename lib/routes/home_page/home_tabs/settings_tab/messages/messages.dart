import 'package:flutter/material.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/messages/all_messages.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/messages/new_messages.dart';
import 'package:idehshop/utils.dart';

class Messages extends StatefulWidget {
  final Role role;

  Messages({@required this.role});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = _tabController = TabController(vsync: this, length: 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'پیام های جدید',
              ),
              Tab(
                text: 'همه ی پیام ها',
              ),
            ],
            labelColor: Theme.of(context).accentColor,
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: TabBarView(
          children: [
            NewMessages(
              role: widget.role,
            ),
            AllMessages(
              role: widget.role,
            ),
          ],
          controller: _tabController,
        ),
      ),
      length: 2,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
