import 'package:flutter/material.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D141C), 
      body: Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Color(0xFF0D141C),
          border: Border.all(color: Color(0xFF7CB342), width: 3),
        ),
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFFFFFFF), width: 1),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 10,
                right: 15,
                child: Text(
                  'PANEL 05: FOREST VICTORY STATE',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Color(0x66FFFFFF),
                    fontSize: 10,
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8.0, right: 15.0),
                            child: Icon(
                              Icons.energy_savings_leaf,
                              color: Color(0xFF7CB342),
                              size: 50,
                            ),
                          ),
                          Text(
                            'FOREST RESTORED!',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF),
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  color: Color(0xFF7CB342).withValues(alpha: 0.8),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 120,
                            color: Color(0xFF405D27),
                          ),
                          SizedBox(width: 30),
                          
                          SizedBox(
                            width: 350,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TREES PLANTED', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFFFFFFF), fontSize: 14)),
                                    Text('+100 SEEDS', style: TextStyle(fontFamily: 'Courier', color: Color(0xFF7CB342), fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 15),
                                
                                Container(height: 1, color: Color(0xFF2C3E50)),
                                SizedBox(height: 15),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('BIO-DIVERSITY BONUS', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFFFFFFF), fontSize: 14)),
                                    Text('+50 SEEDS', style: TextStyle(fontFamily: 'Courier', color: Color(0xFF7CB342), fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 15),
                                
                                Container(height: 1, color: Color(0xFF2C3E50)),
                                SizedBox(height: 15),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TOTAL', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('150 SEEDS', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFF48FB1), fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 70),

                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF7CB342),
                              border: Border.all(color: Color(0xFFFFFFFF), width: 3),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            child: Text(
                              'NURTURE NEXT REGION',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}