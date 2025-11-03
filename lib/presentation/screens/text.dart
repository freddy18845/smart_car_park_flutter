// import 'package:flutter/cupertino.dart';
// import 'package:pusher_channels_flutter/pusher-js/core/channels/channel.dart';
// import 'package:pusher_client_flutter/pusher_client_flutter.dart';
//
// class ReservationUpdatesPage extends StatefulWidget {
//   @override
//   _ReservationUpdatesPageState createState() => _ReservationUpdatesPageState();
// }
//
// class _ReservationUpdatesPageState extends State<ReservationUpdatesPage> {
//   late PusherClient pusher;
//   late Channel channel;
//   List<String> updates = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     pusher = PusherClient(
//       'YOUR_APP_KEY',
//       PusherOptions(cluster: 'YOUR_CLUSTER'),
//       autoConnect: true,
//     );
//
//     channel = pusher.subscribe('reservation-channel');
//
//     channel.bind('reservation-event', (PusherEvent? event) {
//       if (event != null && event.data != null) {
//         setState(() {
//           updates.add(event.data!);
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     pusher.unsubscribe('reservation-channel');
//     pusher.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Reservation Updates')),
//       body: ListView.builder(
//         itemCount: updates.length,
//         itemBuilder: (context, index) {
//           return ListTile(title: Text(updates[index]));
//         },
//       ),
//     );
//   }
// }
