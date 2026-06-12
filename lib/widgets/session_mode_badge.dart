import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sync_engine.dart';
import '../services/session_mode_service.dart';

class SessionModeBadge extends StatelessWidget {
  final bool compact;

  const SessionModeBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final syncEngine = context.watch<SyncEngine>();

    return FutureBuilder<SessionMode>(
      future: SessionModeService.currentMode(),
      builder: (context, snapshot) {
        final storedMode = snapshot.data ?? SessionMode.cloudSync;
        final offline =
            storedMode == SessionMode.secureOffline || !syncEngine.isOnline;
        final color = offline
            ? const Color(0xFFF59E0B)
            : const Color(0xFF22C55E);
        final icon = offline
            ? Icons.enhanced_encryption_rounded
            : Icons.cloud_done_rounded;
        final label = offline ? 'SECURE LOCAL OFFLINE MODE' : 'CLOUD SYNC MODE';

        return Tooltip(
          message: label,
          child: Container(
            width: compact ? 34 : double.infinity,
            height: compact ? 30 : null,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 0 : 10,
              vertical: compact ? 0 : 7,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 15),
                if (!compact) ...[
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
