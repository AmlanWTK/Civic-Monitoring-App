

// Alert Widget for notifications and alerts
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title + time),
      direction: onDismiss != null 
          ? DismissDirection.endToStart 
          : DismissDirection.none,
      onDismissed: (direction) {
        if (onDismiss != null) onDismiss!();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, color: Colors.black,),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.roboto(fontSize: 13,color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: onTap != null 
            ? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
            : null,
      ),
    );
  }
}
