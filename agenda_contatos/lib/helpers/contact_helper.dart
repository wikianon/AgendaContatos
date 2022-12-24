import 'dart:async' show Future;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//Para criar a tabela
const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imageColumn = "imageColumn";

//classe para conectar com o banco de dados.
//para isso vamos utilizar um padrão chamado Singleton
//O padrão Singleton é usado quando queremos
//ter apenas um objeto dentro da classe.
class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //Para não dar erro em: ContactHelper.internal()
  // devemos declarar o Database como late mas isso ira gerar um erro.
  //se não fizermos isso teremos que marcar
  // a variavel _database como NullAble
  //ficando assim: Database? _database;
  //ou
  //static Database? _database;

  //Para compararmos se um banco dedados == null
  //podemos utilizar um var ao invés de declarar
  //a variavel como nullable
  var _database;

  Future<Database> get getDatabase async {
    if (_database != null) {
      return _database;
    } else {
      _database = await intDatabase();

      return _database;
    }
  }

  //inicializa o banco de dados.
  Future<Database> intDatabase() async {
    //pegando o local do banco de dados
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, "contacts.db");

    //Abrindo o banco de dados e criando uma tabela.
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)");
    });
  } //initDb

  //Salvando os contatos
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await getDatabase;

    //Para usarmos o contact.toMap() temos que fazer um casting que define o seu tipo.
    contact.id = await dbContact.insert(
        contactTable, contact.toMap() as Map<String, dynamic>);

    return contact;
  } //saveContact

  Future<Contact?> getContact(int id) async {
    Database dbContact = await getDatabase;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  } //getContact

  //como o delete retorna um inteiro indicando sucesso ou não
  //usaremos um Future<int>
  Future<int> deleteContact(int id) async {
    Database dbContact = await getDatabase;

    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  } //deleteContact

  //atualizando os contatos
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await getDatabase;

    return await dbContact.update(
        contactTable, contact.toMap() as Map<String, dynamic>,
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await getDatabase;

    //criando uma lista de contatos
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");

    //lista do tipo Contact
    List<Contact> listContact = [];

    for (Map map in listMap) {
      listContact.add(Contact.fromMap(map));
    }

    return listContact;
  } //getAllContacts

  //Obtendo o numero de contatos da lista.
  Future<int?> getNumber() async {
    Database dbContact = await getDatabase;

    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  } //getNumber

  Future<void> closeDatabase() async {
    Database dbContact = await getDatabase;
    dbContact.close();
  }
} //ContactHelper

//classe para pegar os dados do contato
class Contact {
  //como a classe nao terá um construtor
  //as variaveis tem de ser late.

  //Para não dar erro de inicalização de variave late temos que marcar
  //todas as variaveis como opcionais  do tipo NullAble.
  int? id;
  String? name;
  String? email;
  String? phone;
  //para conseguirmos verificar se a imagen é == null
  //podemos utilizar um Var ao invés de declarar como NullAble.
  var imagens;

  Contact();

  //Armazenando os dados em forma de um map.
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    imagens = map[imageColumn];
  } //fromMap

  //Função que vai retornar um mapa.
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: imagens
    };

    map[idColumn] = id;

    return map;
  } //toMap

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, imagens: $imagens)";
  }
}
