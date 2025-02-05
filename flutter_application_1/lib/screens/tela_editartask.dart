import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart'; 

class EditarTask extends StatefulWidget {
  final Task task;

  
  const EditarTask({super.key, required this.task});
  
  @override
  _EditarTaskState createState() => _EditarTaskState();
}

class _EditarTaskState extends State<EditarTask> {
  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _dateController = TextEditingController(); 
  late TextEditingController _timeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dateController = TextEditingController(text: widget.task.date);
    _timeController = TextEditingController(text: widget.task.hour);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

// Função do Date Picker 
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),  
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

// Função do Time Picker 
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  // Função para atualizar task no banco
  void _editTask() async {
    
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(widget.task.id).update({
                'title': _titleController.text,
                'description': _descriptionController.text,
                'date': _dateController.text,
                'hour': _timeController.text,
              });
              Navigator.pop(context);
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } 

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF133E87),
        centerTitle: true,
        title: const Text(
          "Editar task",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Título da task",
              ),
            ),
            const SizedBox(height: 20),

            // Description Input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Descrição da task",
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Date Input 
            TextField(
              controller: _dateController, 
              readOnly: true, 
              onTap: _selectDate,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Data",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: _selectDate, // Open Date Picker on icon tap
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            // time input 
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _selectTime,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Horário",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
              ),
            ),

            const SizedBox(height: 30),

            //  Butão atualizar Task
            Center(
              child: ElevatedButton(
                onPressed: (){
                  _editTask();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF133E87),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Atualizar task",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
