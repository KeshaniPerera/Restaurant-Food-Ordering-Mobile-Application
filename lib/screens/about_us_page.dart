import 'package:flutter/material.dart';

import '../theme.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text('About Us',
              style: whiteheading,
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              "Hungry Bunny is Sri Lanka's ultimate destination for fast food lovers. Our restaurant offers a delightful array of mouthwatering dishes, meticulously prepared to tantalize your taste buds. We ensure every bite is a savory delight. Whether you're dining in or opting for our convenient pickup and delivery services, our friendly staff guarantees a memorable experience. Located in the heart of Sri Lanka, our main branch stands as a beacon of culinary excellence, serving up delectable treats that cater to every craving. Join us at Hungry Bunny for an unforgettable feast that satisfies your hunger and leaves you craving more.",
              style: normaltext,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    );
  }
}
