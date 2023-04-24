import 'dart:io';
class Traveller {
  static Traveller? _user;
  String id;

  Traveller(this.id);

  static Traveller Instance([String id=""]){
    if(_user == null){
      _user = Traveller(id);
    }
    return _user!;
  }
}
// void main(){
//
// }