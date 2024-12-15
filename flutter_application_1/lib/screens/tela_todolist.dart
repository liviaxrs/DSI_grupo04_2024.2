import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:proAluno/Widgets/addButton.dart';


class TodolistScreen extends StatefulWidget {
  const TodolistScreen({super.key});

  @override
  State<TodolistScreen> createState() => _TodolistScreenState();
}

class _TodolistScreenState extends State<TodolistScreen> {
  DateTime _selectedDate = DateTime.now(); // Holds the currently selected date

  String getCurrentDay() {
    final List<String> daysOfWeek = [
      'domingo',
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado'
    ];
    return daysOfWeek[DateTime.now().weekday % 7];
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF133E87),
        title: Text(
          "Hoje é ${getCurrentDay()}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Picker Section
          Padding(
            padding: const EdgeInsets.all(10),
            child: DatePicker(
              DateTime.now(),
              height: 100,
              width: 80,
              locale: "pt_br",
              initialSelectedDate: _selectedDate,
              selectionColor: const Color(0xFF133E87),
              selectedTextColor: Colors.white,
              onDateChange: _onDateChange,
            ),
          ),

          // Display the selected date
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Data escolhida: ${_selectedDate.toLocal()}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Task List Section
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with dynamic task count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 7.0),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text('Task ${index + 1}'),
                    subtitle: const Text('Task description here'),
                    onTap: () {
                      // Handle task tap
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AddButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tela_adicionartask');
        },
      ),
    );
  }
}

