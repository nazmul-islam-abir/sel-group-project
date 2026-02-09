import 'package:flutter/material.dart';
import 'package:myapp/screens/student/navigation_page.dart';




class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("Hello This My Homepage",
        style: TextStyle(fontSize: 20,
        color: const Color.fromARGB(255, 121, 11, 11),
        fontWeight: FontWeight.bold,),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SizedBox(
              
              width: 200,
              child: ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationPage()));
        
              }, child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Text("Student Page"),
                  SizedBox(width: 20,),
                  Icon(Icons.person_3_rounded)             ],
        
              )),
            )
          ],
        ),
      ),
    );
  }
}