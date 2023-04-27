import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../campaign_detail/bloc/campaign_detail_bloc.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          BlocBuilder<CampaignDetailBloc, CampaignDetailState>(
            builder: (context, state) {
              // TODO: Replace placeholder
              const placeholder =
                  'https://play-lh.googleusercontent.com/6UgEjh8Xuts4nwdWzTnWH8QtLuHqRMUB7dp24JYVE2xcYzq4HA8hFfcAbU-R-PC_9uA1';
              if (state is CampaignLoaded && state.data.logo.isNotEmpty) {
                return Image.network(state.data.logo, width: 100, height: 100);
              } else {
                return Image.network(placeholder, width: 100, height: 100);
              }
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Уровень: Продвинутый',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: theme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
