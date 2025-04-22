// i want the rows and coloumns to be aligned so that the titles such as capacity and booked should be in one column, and their respective  y values in one row and j values. need to perfectly alin everything with bc and ey on top. 

// Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment
//                                                 .end, // Space between items
//                                             children: [
//                                               Text(
//                                                 'BC', // Business Class
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: screenWidth * 0.041,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: screenWidth * 0.1,
//                                               ),
//                                               Text(
//                                                 'EY', // Economy Class
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: screenWidth * 0.041,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: screenWidth * 0.043,
//                                               ),
//                                             ],
//                                           ),

//                                           // Capacity information content
//                                           Row(
//                                             children: [
//                                               Text('Capacity',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               SizedBox(
//                                                 width: screenWidth * 0.27,
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.13,
//                                                     -0.5), //100.5
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                   ),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jCapacity}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.165,
//                                                     -0.5), //-12.55
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yCapacity}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           // Add more rows for other capacity information
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Booked',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               SizedBox(
//                                                 width: screenWidth * 0.23,
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.037,
//                                                     1.0), //87.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jBooked}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.01,
//                                                     1.0), //-11.55
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yBooked}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           // Add more rows for other capacity information
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Checked-In',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               SizedBox(
//                                                 width: screenWidth * 0.23,
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.014,
//                                                     1.0), //52.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jCheckedIn}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.01,
//                                                     1.0), //-11.55
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yCheckedIn}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Commercial Standby',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.07,
//                                                     1.0), //87.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jCommercialStandby}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.008,
//                                                     1.0), //-11.50
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yCommercialStandby}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Staff Listed',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.157,
//                                                     1.0), //65.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jStaffListed ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.009,
//                                                     1.0), //-11.50
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yStaffListed ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Staff on Standby',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.11,
//                                                     1.0), //31.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                   ),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jStaffOnStandby ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.01,
//                                                     1.0), //-11.50
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yStaffOnStandby ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: screenHeigth * 0.01),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text('Staff Accepted',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize:
//                                                           screenWidth * 0.041)),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     screenWidth * 0.128,
//                                                     1.0), //31.0
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.jStaffAccepted ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Transform.translate(
//                                                 offset: Offset(
//                                                     -screenWidth * 0.008,
//                                                     1.0), //-11.50
//                                                 child: Container(
//                                                   height: screenHeigth * 0.035,
//                                                   width: screenWidth * 0.12,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: Center(
//                                                     child: Text(
//                                                         '${flightLoad?.yStaffAccepted ?? 0}',
//                                                         style: TextStyle(
//                                                             color: const Color
//                                                                 .fromARGB(
//                                                                 255, 0, 0, 0),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth *
//                                                                     0.041)),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                               height: screenHeigth * 0.047),

//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
                                              
//                                               Container(
//                                                 width: screenWidth * 0.8,
//                                                 height: screenHeigth * 0.045,
//                                                 child: ElevatedButton(
//                                                   onPressed: areButtonsEnabled
//                                                       ? () {
//                                                           _navigateToPriorityPage(
//                                                               context);
//                                                         }
//                                                       : null,
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         areButtonsEnabled
//                                                             ? Colors
//                                                                 .white // Normal color when enabled
//                                                             : Colors
//                                                                 .grey, // Color when disabled
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               9.0),
//                                                     ),
//                                                     disabledForegroundColor:
//                                                         const Color.fromARGB(
//                                                                 255,
//                                                                 255,
//                                                                 255,
//                                                                 255)
//                                                             .withOpacity(0.38),
//                                                     disabledBackgroundColor:
//                                                         const Color.fromARGB(
//                                                                 255,
//                                                                 242,
//                                                                 236,
//                                                                 236)
//                                                             .withOpacity(0.12),

//                                                     padding: EdgeInsets.symmetric(
//                                                         horizontal: screenWidth *
//                                                             0.03), // Ensures background color is grey when disabled
//                                                   ),
//                                                   child: Text(
//                                                     'My Priority',
//                                                     style: TextStyle(
//                                                       color: areButtonsEnabled
//                                                           ? const Color
//                                                               .fromRGBO(
//                                                               235,
//                                                               97,
//                                                               39,
//                                                               1) // Normal color for text when enabled
//                                                           : const Color
//                                                               .fromARGB(
//                                                               194,
//                                                               235,
//                                                               98,
//                                                               39), // Color when disabled
//                                                       fontWeight:
//                                                           FontWeight.w900,
//                                                       fontSize:
//                                                           screenWidth * 0.04,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       )