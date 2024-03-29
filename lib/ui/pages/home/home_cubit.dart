// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nws_huydq_ecommerce_flutter/models/categories/category.dart';
import 'package:nws_huydq_ecommerce_flutter/models/detail_categories/detail_category.dart';
import 'package:nws_huydq_ecommerce_flutter/models/detail_categories/product.dart';
import 'package:nws_huydq_ecommerce_flutter/models/enums/load_status.dart';
import 'package:nws_huydq_ecommerce_flutter/network/api_path.dart';
import 'package:nws_huydq_ecommerce_flutter/network/api_service.dart';
import 'package:nws_huydq_ecommerce_flutter/ui/pages/check_home/check_home_cubit.dart';
import 'package:nws_huydq_ecommerce_flutter/ui/pages/home/home_navigator.dart';
import 'package:nws_huydq_ecommerce_flutter/utils/logger.dart';


part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeNavigator navigator;
  HomeCubit({required this.navigator}) : super(const HomeState());
  List<Category> categories = [];
  List<DetailCategory> detailCategories = [];
  TextEditingController searchEditingController = TextEditingController();

  void openDetailCategory(int id, BuildContext context) {
    log(id.toString());
    context.read<CheckHomeCubit>().openDetailCategory(id);
  }

  Future<void> getAllCategories(BuildContext context) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      Response response = await ApiService().getAPI(
          ApiPath.getListCategory);
      logger.d(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        categories = data.map((json) => Category.fromJson(json)).toList();
        emit(state.copyWith(
            loadStatus: LoadStatus.success, categories: categories));

        detailCategories = categories.map((category) {
          return DetailCategory(
            id: category.id,
            category: category.name,
            products: [],
          );
        }).toList();

        getDetailCategories(context);
      } else {
        emit(state.copyWith(
            loadStatus: LoadStatus.failure,
            errorMessage: response.statusMessage));
      }
    } catch (e) {
      emit(state.copyWith(
          loadStatus: LoadStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> getDetailCategories(BuildContext context) async {
    for (int i = 0; i < detailCategories.length; i++) {
         emit(state.copyWith(
          loadStatus: LoadStatus.loadingMore));
      var detailCategory = detailCategories[i];
      Response response = await ApiService().getAPI(
          ApiPath().getListProduct(detailCategory.id)); // Gọi API để lấy danh sách sản phẩm dựa trên ID.
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Product> products =
            data.map((json) => Product.fromJson(json)).toList();
        detailCategory.products = products;
        categories[i].quantity = products.length;
        log(categories[i].quantity.toString());
      } else {
        // Xử lý lỗi nếu cần.
      }
   
      emit(state.copyWith(
          loadStatus: LoadStatus.success, categories: categories));
      context.read<CheckHomeCubit>().detailCategories = detailCategories;
    }
  }

  void searchCategoriesByName(String keyword) {
    log(searchEditingController.text);
    // String keyword = searchEditingController.text;
    List<Category> searchResults = [];

    for (Category category in categories) {
      if (category.name.toLowerCase().contains(keyword.toLowerCase())) {
        searchResults.add(category);
      }
    }
    emit(state.copyWith(
        loadStatus: LoadStatus.loadingMore, categories: searchResults));
  }

  void clearSearchBar() {
    searchEditingController.clear();
    emit(state.copyWith(
        loadStatus: LoadStatus.loadingMore, categories: categories));
  }
}
