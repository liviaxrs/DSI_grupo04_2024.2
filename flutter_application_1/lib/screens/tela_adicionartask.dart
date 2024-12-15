import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class AdicionarTask extends StatefulWidget {
  const AdicionarTask({super.key});

  @override
  _AdicionarTaskState createState() => _AdicionarTaskState();
}

class _AdicionarTaskState extends State<AdicionarTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); 
  final TextEditingController _timeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
  }

  void _validadeDate(){
    if (_titleController.text.isNotEmpty&&_descriptionController.text.isNotEmpty){
      // add to database
      Navigator.of(context).pop();
    }else if(_titleController.text.isEmpty || _descriptionController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: const Text("Todos os campos precisam ser preenchidos!"),
          backgroundColor: Colors.red[200],
      ));
    }
  }

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100),  // Latest selectable date
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
// Time Picker Function
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        // Format the time as HH:mm
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Adicionar task",
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
              controller: _dateController, // Attach controller
              readOnly: true, // Prevent manual typing (optional)
              onTap: _selectDate, // Open Date Picker on tap
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

            // Add Task Button
            Center(
              child: ElevatedButton(
                onPressed: (){
                  _validadeDate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF133E87),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Adicionar task",
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
