import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nws_huydq_ecommerce_flutter/database/secure_storage_helper.dart';
import 'package:nws_huydq_ecommerce_flutter/models/enums/load_status.dart';
import 'package:nws_huydq_ecommerce_flutter/models/profile/profile.dart';
import 'package:nws_huydq_ecommerce_flutter/ui/pages/main/main_cubit.dart';
import 'package:nws_huydq_ecommerce_flutter/ui/pages/profile/profile_navigator.dart';
import 'package:nws_huydq_ecommerce_flutter/ui/widgets/dialog/show_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileNavigator navigator;
  ProfileCubit({required this.navigator}) : super(const ProfileState());

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController ageEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  String imageUrl = "";

  final Reference storageReference =
      FirebaseStorage.instance.ref().child('images');

  Future<void> getProfile(BuildContext context) async {
    Profile profile = context.read<MainCubit>().profile;
    log(profile.avatar);
    nameEditingController.text = profile.name;
    ageEditingController.text = "21";
    emailEditingController.text = profile.email;
    imageUrl = profile.avatar;

    emit(state.copyWith(loadStatus: LoadStatus.success, imageUrl: imageUrl));
  }

  void logOut(BuildContext context) {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    showAlertDialog(
      context: context,
      title: "Log Out",
      content: "Are you sure you want to log out",
      onConfirm: () {
        SecureStorageHelper().removeToken();
        Future.delayed(
          const Duration(seconds: 1),
          () {
            emit(state.copyWith(loadStatus: LoadStatus.success));
            navigator.openLogin();
          },
        );
      },
    );
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      log("null");
      return;
    } else {
      uploadImage(pickedImage);
    }
  }

  Future<void> uploadImage(XFile pickedImage) async {
    emit(state.copyWith(loadStatus: LoadStatus.loadingMore));
    final File image = File(pickedImage.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1${DateTime.now()}");
    UploadTask uploadTask = ref.putFile(image);
    log(pickedImage.path);
    uploadTask.whenComplete(() async {
      imageUrl = await ref.getDownloadURL();
      emit(state.copyWith(loadStatus: LoadStatus.success, imageUrl: imageUrl));
      log(imageUrl);
    }).catchError((onError) {
      log(onError);
      return onError;
    });
  }
}
