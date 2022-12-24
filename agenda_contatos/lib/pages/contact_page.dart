import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';
//pegando imagen da camera ou galeria.
//https://www.youtube.com/watch?v=Z8eIAm9KfdM

class ContactPage extends StatefulWidget {
  //para que contact seja opcional ao chamar oconstrutor
  //da classe ContactPage devemos declarar a mesma como NullAble.
  //assim ela não exigira ser required this.contact.
  final Contact? contact;

  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //Para pegar o input do usuario
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  //caso o usuario clique em salvar sem entrar com nenhum nome
  //foca no campo nome para inserir
  final _nameFocus = FocusNode();

  late Contact _editedContact;

  bool _userEdited = false;

  @override
  void initState() {
    super.initState();

    //pegando o objeto contact de ContactPage
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email!;
      _phoneController.text = _editedContact.phone!;
    }
  } //initState

  @override
  Widget build(BuildContext context) {
    //Para mostrar o texto quando o usuario editar
    //os contatos faremos isso usando o widget
    //WillPopScope
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          //pega o nome do contato no titulo.
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          //verificando se o usuario existe e abrindo na proxima tela.
          onPressed: () {
            if (_editedContact.name != null &&
                _editedContact.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: _editedContact.imagens != null
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: FileImage(File(_editedContact.imagens)),

                              //Para a imagen ficar circular e não retangular.
                              fit: BoxFit.cover),
                        )
                      : const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage("assets/images/person.png"),

                              //Para a imagen ficar circular e não retangular.
                              fit: BoxFit.cover),
                        ),
                ), //Container

                onTap: () {
                  _requestImage();
                }, //onTap
              ), //GestureDetector

              //usando o TextField para editar o contato
              TextField(
                controller: _nameController,
                //focando para mostrar o nome vazio ao clicar em salvar sem inserir o nome.
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;

                  setState(() {
                    _editedContact.name = text;
                  });
                },
                keyboardType: TextInputType.name,
              ),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;

                  setState(() {
                    _editedContact.phone = text;
                  });
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  //Função para pegar a imagen da camera.
  void _getImgCamera() {
    _getImg(ImageSource.camera);
  }

  //Função para pegar a imagen da galeria.
  void _getImgGalery() {
    _getImg(ImageSource.gallery);
  }
  
  //Tipando o método para pegar a imagen.
  void _getImg(ImageSource source) {
    ImagePicker().pickImage(source: source).then((value) {
      if (value == null) return;
      setState(() {
        _editedContact.imagens = value.path;
      });
    });
  }

  void _requestImage() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Click em camera ou a galery"),
            actions: [
              TextButton(
                onPressed: () {
                  _getImgCamera();

                  //para fechar a caixa de dialogo.
                  Navigator.pop(context);
                },
                child: const Text("Camera"),
              ),

              TextButton(
                onPressed: () {
                  _getImgGalery();

                  //para fechar a caixa de dialogo.
                  Navigator.pop(context);
                },
                child: const Text("Galery"),
              ), //TextButton

              TextButton(
                onPressed: () {
                  //fecha a janela se não quiser mais adicionar uma imagen
                  Navigator.pop(context);
                },
                child: const Text('Voltar'),
              ),
            ],
          );
        });
  } //_requestImage

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Descartar Alteraçoes?'),
            content: const Text('Se sair as alterações serão perdidas.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Voltar'),
              ),
              ElevatedButton(
                onPressed: () {
                  //remover o Dialog
                  Navigator.pop(context);

                  //remover o contact_page
                  Navigator.pop(context);
                },
                child: const Text('Descartar'),
              )
            ],
          );
        },
      );
      // não sair automaticamente se algum dado foi modificado
      return Future.value(false);
    } else {
      //sair automaticamente da tela se não modificou nada.
      return Future.value(true);
    }
  }
}