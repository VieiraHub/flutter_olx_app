import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/models/Ad.dart';
import 'package:olx/util/Settings.dart';
import 'package:olx/views/widgets/CustomButton.dart';
import 'package:olx/views/widgets/CustomInput.dart';
import 'package:validadores/Validador.dart';

class NewAd extends StatefulWidget {
  @override
  _NewAdState createState() => _NewAdState();
}

class _NewAdState extends State<NewAd> {

  final _formKey = GlobalKey<FormState>();
  //final picker = ImagePicker();
  List<File> _imagesList = List();
  List<DropdownMenuItem<String>> _itensDropStateList = List();
  List<DropdownMenuItem<String>> _itensDropCategoryList = List();
  Ad _ad;
  BuildContext _dialogContext;

  String _selectedItemState;
  String _selectedItemCategory;

  _selectGalleryImage() async {
    File selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {  _imagesList.add(selectedImage);  });
    }
  }

  _openDialog(BuildContext context) {
    showDialog(
        context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Saving Ad...")
              ]
            )
          );
      }
    );
  }

  _saveAd() async {
    _openDialog(_dialogContext);

    //Upload das imagens no storage
    await _uploadImages();

    //Salvar anuncio no Firestore
    Firestore db = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    String idLoggedUser = loggedUser.uid;

    db.collection("my_ads").document(idLoggedUser)
        .collection("ads").document(_ad.id)
        .setData(_ad.toMap()).then((_) {
          //Salvar anuncio publico
          db.collection("ads").document(_ad.id)
              .setData(_ad.toMap()).then((_) {
            Navigator.pop(_dialogContext);
            Navigator.pop(context);
          });

    });
  }

  Future _uploadImages() async{
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();

    for (var image in _imagesList) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquive = rootFolder
          .child("my_ads").child(_ad.id).child(imageName);
      
      StorageUploadTask uploadTask = arquive.putFile(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _ad.photos.add(url);
    }
  }

  _loadItensDropdown(){
    _itensDropCategoryList = Settings.getCategories();
    _itensDropStateList = Settings.getStates();
  }

  @override
  void initState() {
    super.initState();
    _loadItensDropdown();
    _ad = Ad.generateId();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("New ad")),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Área de imagens
                  FormField<List>(
                      initialValue: _imagesList,
                      validator: (images) {
                        if (images.length == 0) {
                          return "Need to select an image";
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          children: [
                            Container(
                              height: 100,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imagesList.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _imagesList.length) {
                                      return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: GestureDetector(
                                          onTap: () {  _selectGalleryImage();  },
                                          child: CircleAvatar(
                                            backgroundColor: Colors.grey[400],
                                            radius: 50,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo,
                                                  size: 40,
                                                  color: Colors.grey[100],
                                                ),
                                                Text("Add", style: TextStyle(color: Colors.grey[100]))
                                              ]
                                            )
                                          ),
                                        ),
                                      );
                                    }
                                    if (_imagesList.length > 0) {
                                      return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Image.file(_imagesList[index]),
                                                        FlatButton(
                                                            child: Text("Delete"),
                                                            textColor: Colors.red,
                                                          onPressed: () {
                                                              setState(() {  
                                                                _imagesList.removeAt(index);
                                                                Navigator.of(context).pop();
                                                              });
                                                          }
                                                        )
                                                      ],
                                                    )
                                                  )
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundImage: FileImage(_imagesList[index]),
                                              child: Container(
                                                color: Color.fromRGBO(255, 255, 255, 0.4),
                                                alignment: Alignment.center,
                                                child: Icon(Icons.delete, color: Colors.red)
                                              )
                                            )
                                          )
                                      );
                                    }
                                    return Container();
                                  }
                              ),
                            ),
                            if (state.hasError)
                              Container(
                                child: Text("[${state.errorText}]",
                                  style: TextStyle( color: Colors.red, fontSize: 14),
                                ),
                              )
                          ],
                        );
                      }
                  ),

                  //Menus Dropdown
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.all(8),
                            child: DropdownButtonFormField(
                                value: _selectedItemState,
                                hint: Text("State"),
                                onSaved: (state) {  _ad.state = state;  },
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                items: _itensDropStateList,
                                validator: (value) {
                                  return Validador().add(Validar.OBRIGATORIO, msg: "Required field").valido(value);
                                },
                                onChanged: (value) {
                                  setState(() {  _selectedItemState = value;  });
                                }
                            ),
                          )
                      ),

                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: DropdownButtonFormField(
                                value: _selectedItemCategory,
                                hint: Text("Category"),
                                onSaved: (category) {  _ad.category = category;  },
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                items: _itensDropCategoryList,
                                validator: (value) {
                                  return Validador().add(Validar.OBRIGATORIO, msg: "Required field").valido(value);
                                },
                                onChanged: (value) {
                                  setState(() {  _selectedItemCategory = value;  });
                                }
                            ),
                          )
                      )
                    ],
                  ),
                  //Caixas de textos e botões

                  Padding(
                      padding: EdgeInsets.only(bottom: 15, top: 15),
                    child: CustomInput(
                        hint: "Title",
                        onSaved: (title) {  _ad.title = title;  },
                        validator: (value) {
                          return Validador().add(Validar.OBRIGATORIO, msg: "Required field").valido(value);
                        }
                    )
                  ),

                  Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: CustomInput(
                        hint: "Price",
                        onSaved: (price) {  _ad.price = price;  },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          RealInputFormatter(centavos: true)
                        ],
                        validator: (value) {
                          return Validador().add(Validar.OBRIGATORIO, msg: "Required field").valido(value);
                        }
                      )
                  ),

                  Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: CustomInput(
                        hint: "Telephone",
                        onSaved: (telephone) {  _ad.telephone = telephone;  },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter()
                        ],
                        validator: (value) {
                          return Validador().add(Validar.OBRIGATORIO, msg: "Required field").valido(value);
                        }
                      )
                  ),

                  Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: CustomInput(
                        hint: "Description (200 characters)",
                        onSaved: (description) {  _ad.description = description;  },
                        maxLines: null,
                        validator: (value) {
                          return Validador().add(Validar.OBRIGATORIO, msg: "Required field")
                              .maxLength(200, msg: "Maximum 200 characters").valido(value);
                        }
                      )
                  ),

                  CustomButton(
                      text: "Sign up ad",
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          //Salva campos
                          _formKey.currentState.save();
                          //Configura dialog context
                          _dialogContext = context;
                          //Salvar anuncio
                          _saveAd();
                        }
                      }
                  )
                ]
              )
          )
        )
      )
    );
  }
}
