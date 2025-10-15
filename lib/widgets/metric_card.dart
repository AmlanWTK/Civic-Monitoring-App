import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // White background
      elevation: 3,        // Soft shadow
      shadowColor: Colors.grey[300], // Light shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15), // lighter background for icon
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400], // softer arrow
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              SizedBox(height: 4),
              Text(
  title,
  style: GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    //color: Colors.grey[700],
    fontSize: 16, // optional, adjust as needed
  ),
),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
  subtitle!,
  style: GoogleFonts.roboto(   // or any Google Font you want
    textStyle: Theme.of(context).textTheme.bodySmall,
    color: Colors.grey[700],
    fontSize: 11,
  ),
),

              ],
            ],
          ),
        ),
      ),
    );
  }
}
