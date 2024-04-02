import 'package:flutter/material.dart';
import 'package:bridgefy_example/domain/entities/log.dart';

class LogRow extends StatelessWidget {
  final Log log;

  const LogRow({
    super.key,
    required this.log
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            log.text,
            style: TextStyle(
              color:
                log.type==LogType.success ? Colors.green : 
                (log.type==LogType.finish ? colors.primary : Colors.black),
              fontWeight: (log.type==LogType.error) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}