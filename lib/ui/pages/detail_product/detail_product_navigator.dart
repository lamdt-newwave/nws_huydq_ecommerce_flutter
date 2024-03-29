import 'package:flutter/cupertino.dart';

import 'package:go_router/go_router.dart';
import 'package:nws_huydq_ecommerce_flutter/common/app_navigator.dart';
import 'package:nws_huydq_ecommerce_flutter/models/detail_categories/detail_category.dart';
import 'package:nws_huydq_ecommerce_flutter/router/router_config.dart';

class DetailProductNavigator extends AppNavigator {
  DetailProductNavigator({required BuildContext context})
      : super(context: context);

  void openDetailCategory(DetailCategory detailCategory) {
    GoRouter.of(context)
        .pushNamed(AppRouter.detailCategory, extra: detailCategory);
  }

  void openCartPage() {
    GoRouter.of(context).pushNamed(AppRouter.cart);
  }
}
