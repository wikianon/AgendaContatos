import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';
import '../helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'contact_page.dart';

//https://pub.dev/packages/url_launcher/example

//ordenando a lista de contatos em ordem alfabetica.
enum OrderOptions { orderaz, orderza }

class AgendaContatos extends StatelessWidget {
  const AgendaContatos({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Como nossa classe ContactHelper é um Singleton
  //só podemos ter um objeto inicializado pela mesma.
  ContactHelper helper = ContactHelper();

  //Criando uma lista de contatos.
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Contatos'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          //Ordenando os contatos em ordem alfabetica
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderaz,
                child: Text('Ordenar de A-Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderza,
                child: Text('Ordenar de Z-A'),
              ), //PopupMenuItem
            ], //<PopupMenuEntry<OrderOptions>>

            //Para o _orderList ordenar os contatos
            //temos que colocar um setState vazio dentro da função
            //e chamar o _orderList aqui.
            onSelected: _orderList,

          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ), //ListView.builder
    ); //Scaffold
  } //Widget build

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                //Só consguimos comparar se a imagen é == null
                //por que a variavel imagens é do tipo var
                //entao ela não esta declaraa como NullAble ex:
                //late String? imagens;
                decoration: contacts[index].imagens != null
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: FileImage(File(contacts[index].imagens)),

                            //Para a imagen ficar circular e não retangular.
                            fit: BoxFit.cover
                        ),
                      )
                    : const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("assets/images/person.png"),

                            //Para a imagen ficar circular e não retangular.
                            fit: BoxFit.cover
                        ),
                      ),
              ), //Container

              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  //Para os contatos não ficarem alinhados no centro.
                  //colocaremos os contatos a esquerda.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "Nome não adicionado",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    Text(
                      contacts[index].email ?? "Email não adicionado",
                      style: const TextStyle(fontSize: 20),
                    ),

                    //Para este tipo de verificação ?? as variaveis tem que ser NullAble.
                    Text(
                      contacts[index].phone ?? "Phone não adicionado",
                      style: const TextStyle(fontSize: 20),
                    ) //Text
                  ],
                ),
              )
            ],
          ),
        ),
      ), //Card

      onTap: () {
        //_showContactPage(contact: contacts[index]);

        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      //criando a url para pegar o numero do telefone
                      //a UrlString não pode ser tels:$numeroTelefone
                      //tem que ser exatamente tel:$numeroTelefone
                      var phoneUrl = "tel:${contacts[index].phone}";

                      launchUrlString(phoneUrl);

                      //pegando o numero do telefone através da string tel:
                      //launchUrlString("tel:${contacts[index].phone}");

                      //fechando a janela ao mostrar o numero
                      Navigator.pop(context);
                    },
                    child: const Text('Ligar',
                        style: TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      //para fechar a janela ao mostrar as opçoes do contato
                      Navigator.pop(context);

                      _showContactPage(contact: contacts[index]);
                    },
                    child: const Text('Editar',
                        style: TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      //deletando o contato
                      helper.deleteContact(contacts[index].id!);

                      //para atualizar a view temos que colocar
                      //dentro de um setState.
                      setState(() {
                        //removendo contato da lista.
                        contacts.removeAt(index);

                        //para fechar a janela ao mostrar as opçoes do contato
                        Navigator.pop(context);
                      });
                    },
                    child: const Text('Excluir',
                        style: TextStyle(color: Colors.blue, fontSize: 20)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //Passando um contato para a função.
  void _showContactPage({Contact? contact}) async {
    //A variavel reqContact recebe um contato da tela
    //para retornar o contato para a tela.
    final reqContact = await Navigator.push(
        context,
        //enviando o contato para a proxima tela.
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (reqContact != null) {
      if (contact != null) {
        await helper.updateContact(reqContact);
      } else {
        await helper.saveContact(reqContact);
      }

      _getAllContacts();
    }
  } //_showContactPage

  //Obtendo a lista dos contatos atualizados
  void _getAllContacts() {
    helper.getAllContacts().then((lista) {
      setState(() {
        //para que a variavel lista seja aceita
        //temos que fazer um casting
        contacts = lista as List<Contact>;
      });
    });
  } //_getAllContacts

  //método que ordena os contatos.
  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, z) {
          return a.name!.toLowerCase().compareTo(z.name!.toLowerCase());
        });
        break;
        
      case OrderOptions.orderza:
        contacts.sort((a, z) {
          return z.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }

    //setState vazio para ordenar a lista de contatos
    setState(() {});
  } //_orderList

} //HomePageState
