// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/reservation_provider.dart';
import '../../utils/pdf_generator_english.dart' as pdf_en;
import '../../utils/pdf_generator_es.dart' as pdf_es;
import '../../utils/price_calculator.dart';
import '../../utils/quote_calculator.dart';
import 'success_screen.dart';

class QuotePreviewScreen extends StatelessWidget {
  const QuotePreviewScreen({super.key});

  Future<void> confirm(BuildContext context) async {
    final reservation = context.read<ReservationProvider>();

    if (!reservation.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La cotizacion se calculo con datos locales. Se requiere internet para enviar la reservacion.",
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Procesando reservacion..."),
                ],
              ),
            ),
          ),
    );

    final aircraft = reservation.selectedAircraft;

    if (aircraft == null) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final supabase = Supabase.instance.client;
    final startDate = reservation.startDate!;
    final endDate = reservation.endDate ?? startDate;
    final totals = QuoteCalculator.calculate(reservation);

    try {
      final quote =
          await supabase
              .from('quotes')
              .insert({
                'full_name': reservation.fullName,
                'email': reservation.email,
                'phone': reservation.phone,
                'flight_type': aircraft.name,
                'total_estimated_price': totals.totalPrice,
              })
              .select()
              .single();

      final quoteId = quote['id'];

      for (final route in reservation.routes) {
        final result = PriceCalculator.calculate(
          aircraft: aircraft,
          route: route,
          startDate: startDate,
          endDate: endDate,
          international: totals.isInternational,
        );

        await supabase.from('quote_routes').insert({
          'quote_id': quoteId,
          'from_airport': route.fromAirport?.name,
          'to_airport': route.toAirport?.name,
          'passengers': reservation.passengers,
          'aircraft_id': aircraft.id,
          'estimated_price': result.flightCost,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        });
      }

      await supabase.from('reservations').insert({
        'quote_id': quoteId,
        'aircraft_id': aircraft.id,
        'start_datetime': startDate.toIso8601String(),
        'end_datetime': endDate.toIso8601String(),
        'status': 'confirmed',
      });

      Uint8List pdfBytes;

      if (reservation.language == "ES") {
        pdfBytes = await pdf_es.ReservationPdf.generate(reservation);
      } else {
        pdfBytes = await pdf_en.ReservationPdf.generate(reservation);
      }

      final pdfBase64 = base64Encode(pdfBytes);

      await http.post(
        Uri.parse("https://redskyg.com/landing/send-email_movil_cliente.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "form": {
            "name": reservation.fullName,
            "email": reservation.email,
            "phone": reservation.phone,
            "flightType": aircraft.name,
          },
          "routes":
              reservation.routes.map((route) {
                return {
                  "fromAirport": route.fromAirport?.name,
                  "toAirport": route.toAirport?.name,
                  "passengers": reservation.passengers,
                };
              }).toList(),
          "subtotal": totals.subtotal,
          "iva": totals.taxAmount,
          "total": totals.totalPrice,
          "pdf": pdfBase64,
        }),
      );

      reservation.resetForm();

      if (!context.mounted) return;

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de reservacion: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = context.watch<ReservationProvider>();
    final aircraft = reservation.selectedAircraft;
    final startDate = reservation.startDate;
    final endDate = reservation.endDate ?? startDate;
    final totals = QuoteCalculator.calculate(reservation);

    return Scaffold(
      appBar: AppBar(title: const Text("Vista previa de cotizacion")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Detalles de la reservacion",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Pasajero: ${reservation.fullName}"),
            Text("Correo: ${reservation.email ?? '-'}"),
            Text("Telefono: ${reservation.phone ?? '-'}"),
            const SizedBox(height: 25),
            const Text(
              "Aeronave",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Aeronave: ${aircraft?.name ?? '-'}"),
            Text("Pasajeros: ${reservation.passengers}"),
            Text("Velocidad crucero: ${aircraft?.cruiseSpeedKnots ?? 0} nudos"),
            const SizedBox(height: 30),
            const Text(
              "Informacion de pago",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (reservation.paymentMethod == null) ...[
              const Text("Metodo de pago no seleccionado"),
            ] else if (reservation.paymentMethod == "WIRE") ...[
              Text("Metodo de pago: transferencia bancaria"),
              Text("Banco: ${reservation.bankName ?? '-'}"),
              Text("CLABE: ${reservation.clabe ?? '-'}"),
              Text("Cuenta: ${reservation.cuenta ?? '-'}"),
            ] else if (reservation.paymentMethod == "CREDIT") ...[
              const Text("Metodo de pago: tarjeta de credito"),
              Text("Referencia: ${reservation.paymentNumber ?? '-'}"),
            ] else if (reservation.paymentMethod == "DEBIT") ...[
              const Text("Metodo de pago: tarjeta de debito"),
              Text("Referencia: ${reservation.paymentNumber ?? '-'}"),
            ],
            const Text(
              "Detalles del vuelo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (aircraft != null)
              ...reservation.routes.map((route) {
                final result = PriceCalculator.calculate(
                  aircraft: aircraft,
                  route: route,
                  startDate: startDate,
                  endDate: endDate,
                  international: totals.isInternational,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${route.fromAirport?.name ?? '-'} -> ${route.toAirport?.name ?? '-'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Distancia: ${result.distanceKm.toStringAsFixed(0)} km",
                        ),
                        Text(
                          "Distancia (NM): ${result.distanceNm.toStringAsFixed(0)}",
                        ),
                        Text(
                          "Horas de vuelo: ${result.flightHours.toStringAsFixed(2)} hrs",
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Costo de vuelo: \$${result.flightCost.toStringAsFixed(0)} USD",
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),
            const Text(
              "Desglose de costos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Costo de vuelo: \$${totals.flightTotal.toStringAsFixed(0)} USD",
            ),
            Text(
              "Costo de pernocta: \$${totals.overnightTotal.toStringAsFixed(0)} USD",
            ),
            Text(
              "Gastos operativos: \$${totals.operationalExpenses.toStringAsFixed(0)} USD",
            ),
            const Divider(),
            Text("Subtotal: \$${totals.subtotal.toStringAsFixed(0)} USD"),
            Text(
              "IVA (${(totals.taxRate * 100).toInt()}%): \$${totals.taxAmount.toStringAsFixed(0)} USD",
            ),
            const Divider(),
            Text(
              "Total: \$${totals.totalPrice.toStringAsFixed(0)} USD",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!reservation.isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Text(
                  "Esta cotizacion se genero con datos guardados en el telefono. Reconectate a internet para enviar la reservacion.",
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    aircraft == null || !reservation.isOnline
                        ? null
                        : () => confirm(context),
                child: Text(
                  reservation.isOnline
                      ? "Confirmar reservacion"
                      : "Se requiere internet para confirmar",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
