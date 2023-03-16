import 'package:flutter/material.dart' hide Notification;
import 'package:gigaturnip/src/bloc/bloc.dart';
import 'package:gigaturnip/src/helpers/helpers.dart';
import 'package:gigaturnip/src/utilities/constants.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:go_router/go_router.dart';

class NotificationView<NotificationCubit extends RemoteDataCubit<Notification>>
    extends StatelessWidget {
  final int campaignId;

  const NotificationView({Key? key, required this.campaignId}) : super(key: key);

  void redirectToNotification(BuildContext context, Notification notification) {
    context.goNamed(
      Constants.notificationDetailRoute.name,
      params: {
        'cid': '$campaignId',
        'nid': '${notification.id}',
      },
      extra: Notification,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListViewWithPagination<Notification, NotificationCubit>(
      itemBuilder: (context, index, item) {
        return ListTile(
          title: Text(item.title),
          subtitle: Text('${item.id}'),
          onTap: () => redirectToNotification(context, item),
        );
      },
    );
  }
}
