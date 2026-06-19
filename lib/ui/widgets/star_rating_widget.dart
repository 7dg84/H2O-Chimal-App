import 'package:flutter/material.dart';
import '../../core/config.dart';

class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final String description;
  final Function(int) onSubmit;

  const StarRatingWidget({
    super.key,
    this.initialRating = 0,
    required this.description,
    required this.onSubmit,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(covariant StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      setState(() {
        _currentRating = widget.initialRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.initialRating > 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConfig.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppConfig.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _currentRating;

              return GestureDetector(
                onTap: isReadOnly
                    ? null
                    : () {
                        setState(() {
                          _currentRating = starValue;
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    size: 48,
                    color: AppConfig.secondaryAzure,
                  ),
                ),
              );
            }),
          ),
          if (!isReadOnly) ...[
          //   Comentario
            const SizedBox(height: 16),
            TextFormField(
              // controller: _,
              decoration: const InputDecoration(
                hintText: 'Excelente!',
                prefixIcon: Icon(Icons.send_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Escribe que te parecio la experiencia';
                return null;
              },
            ),
          ],
          if (!isReadOnly) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentRating > 0
                    ? () => widget.onSubmit(_currentRating)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enviar calificación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
