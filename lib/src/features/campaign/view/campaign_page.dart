import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/src/features/campaign/bloc/campaign_cubit.dart';
import 'package:gigaturnip/src/helpers/helpers.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:gigaturnip/src/utilities/constants.dart';
import 'package:gigaturnip_api/gigaturnip_api.dart' as api;
import 'package:go_router/go_router.dart';

class CampaignPage extends StatelessWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCampaignCubit>(
          create: (context) => CampaignCubit(
            UserCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
            ),
          )..initialize(),
        ),
        BlocProvider<SelectableCampaignCubit>(
          create: (context) => CampaignCubit(
            SelectableCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
            ),
          )..initialize(),
        )
      ],
      child: const CampaignView(),
    );
  }
}

class CampaignView extends StatelessWidget {
  const CampaignView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void redirectToTaskMenu(BuildContext context, int id) {
      context.goNamed(
        Constants.relevantTaskRoute.name,
        params: {'cid': '$id'},
      );
    }

    return Scaffold(
      appBar: AppBar(),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListViewWithPagination<Campaign, UserCampaignCubit>(
              header: const Text('Open campaigns'),
              itemBuilder: (context, index, item) {
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("${item.id}"),
                  onTap: () => redirectToTaskMenu(context, item.id),
                );
              },
            ),
            ListViewWithPagination<Campaign, SelectableCampaignCubit>(
              header: const Text('Available campaigns'),
              itemBuilder: (context, index, item) {
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("${item.id}"),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
