import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:minimalisticpush/localizations.dart';
import 'package:minimalisticpush/managers/session_manager.dart';
import 'package:minimalisticpush/models/session.dart';
import 'package:minimalisticpush/styles/styles.dart';

import 'package:sprinkle/Observer.dart';
import 'package:sprinkle/sprinkle.dart';

class SessionsContent extends StatelessWidget {
  const SessionsContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sessionManager = context.use<SessionManager>();

    return Observer<List<Session>>(
      stream: sessionManager.sessions,
      builder: (context, value) {
        if (value.length == 0) {
          return _NoSessionWidget();
        } else {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              int id = index + 1;
              return _SessionWidget(
                session: value[index],
                idToShow: id,
              );
            },
          );
        }
      },
    );
  }
}

class _NoSessionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        MyLocalizations.of(context).getLocale('sessions')['empty'],
        style: TextStyles.body,
      ),
    );
  }
}

class _SessionWidget extends StatelessWidget {
  const _SessionWidget({
    @required this.session,
    @required this.idToShow,
  });

  final Session session;
  final int idToShow;

  @override
  Widget build(BuildContext context) {
    var sessionManager = context.use<SessionManager>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 36.0,
              width: 36.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(this.idToShow.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  )),
            ),
          ),
          Expanded(
            child: Text(
              this.session.count.toString(),
              softWrap: true,
              style: TextStyles.body,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(16.0),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.white,
            ),
            onPressed: () => sessionManager.deleteSession(this.session.id),
          )
        ],
      ),
    );
  }
}
