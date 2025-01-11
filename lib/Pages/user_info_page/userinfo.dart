import 'package:f_logs/f_logs.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Models/recommended_intake.dart';
import 'package:nutrivision/Provider/diet_provider.dart';
import 'package:nutrivision/Provider/diseases_provider.dart';
import 'package:nutrivision/global.dart';

const _color = Color.fromARGB(255, 145, 199, 137);
final _seccolor = _color.withOpacity(0.3);

class UserInfoForm extends ConsumerStatefulWidget {
  const UserInfoForm({super.key});

  @override
  ConsumerState<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends ConsumerState<UserInfoForm> {
  Map<String, String> selectedDiseasesWithSeverity = {};
  final formKey = GlobalKey<FormState>();
  String selectedGender = 'male';
  String selectedExercise = 'sedentary';
  String selectedChoice = 'Vegetarian';
  String selectedGoal = "Maintenance";
  List<String> selectedDiseases = [];

  // Define controllers to access text form field values
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<Nutrition> getDietRecommendation(Map<String, dynamic> userData) async {
    var url = Uri.parse('http://$ipaddress:8000/calculate_recommended_intake/');
    FLog.info(text: "inside function");
    // Send data as JSON
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      FLog.info(text: "sucessful");

      // Parse the response
      return Nutrition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get diet recommendation');
    }
  }

  void _submitForm() async {
    if (formKey.currentState!.validate()) {
      // Prepare user data for the API call
      Map<String, dynamic> userData = {
        'age': int.tryParse(ageController.text) ?? 0, // Get age from controller
        'height': double.tryParse(heightController.text) ??
            0.0, // Get height from controller
        'weight': double.tryParse(weightController.text) ??
            0.0, // Get weight from controller
        'gender': selectedGender,
        'exercise': selectedExercise,
        'veg_index': selectedChoice,
        'goal': selectedGoal,
        'selected_diseases': selectedDiseasesWithSeverity,
      };
      print(userData);

      try {
        // Call the API and get the recommended diet data
        Nutrition recommendedIntake = await getDietRecommendation(userData);
        print(recommendedIntake.carbs);
        print(recommendedIntake.protein);
        print(recommendedIntake.fats);
        ref.read(dietProvider.notifier).toggleDietValues(recommendedIntake);

        selectedDiseasesWithSeverity.forEach((disease, severity) {
          selectedDiseases.add(disease); // Add the disease name to the list
        });
        ref
            .read(selectedDiseasesProvider.notifier)
            .addDisease(selectedDiseases);

        // Pass the data to the next page
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/mainpage",
          (Route<dynamic> route) => false,
          arguments: recommendedIntake, // Pass the API response data
        );
      } catch (e) {
        // Handle error
        print('Error: $e');
      }
    }
  }

  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: formKey,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                const Text(
                  "UserInfo",
                  style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold, color: _color),
                ),
                const SizedBox(
                  height: 30,
                ),
                _AgeGenderInput(
                    selectedGender: selectedGender,
                    ageController: ageController,
                    onGenderChanged: (newValue) {
                      selectedGender = newValue;
                    }),
                const SizedBox(
                  height: 20,
                ),
                HeightWeightInput(
                  heightController: heightController,
                  weightController: weightController,
                ),
                const SizedBox(
                  height: 20,
                ),
                ExerciseInput(
                  selectedExercise: selectedExercise,
                  onExcerciseChange: (newValue) {
                    selectedExercise = newValue;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                VegNonVegInput(
                  selectedChoice: selectedChoice,
                  onVegChange: (newValue) {
                    selectedChoice = newValue;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                GoalInput(
                    selectedGoal: selectedGoal,
                    onExcerciseChange: (newValue) {
                      selectedGoal = newValue;
                    }),
                const SizedBox(
                  height: 20,
                ),
                // GestureDetector(
                //   onTap: () {
                //     setState(() {
                //       isExpanded = !isExpanded;
                //     });
                //   },
                //   child: InputDecorator(
                //     decoration: const InputDecoration(
                //       labelText: "Select Diseases",
                //       border: OutlineInputBorder(),
                //     ),
                //     child: Wrap(
                //       spacing: 8.0,
                //       runSpacing: 4.0,
                //       children: selectedDiseases.map((disease) {
                //         return Chip(
                //           label: Text(disease),
                //           onDeleted: () {
                //             setState(() {
                //               selectedDiseases.remove(disease);
                //             });
                //           },
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // isExpanded
                //     ? SizedBox(
                //         height: 200,
                //         child: SingleChildScrollView(
                //           child: Wrap(
                //             spacing: 8.0,
                //             runSpacing: 4.0,
                //             children: diseases.map((disease) {
                //               return FilterChip(
                //                 label: Text(disease),
                //                 selected: selectedDiseases.contains(disease),
                //                 onSelected: (selected) {
                //                   setState(() {
                //                     if (selected) {
                //                       selectedDiseases.add(disease);
                //                     } else {
                //                       selectedDiseases.remove(disease);
                //                     }
                //                   });
                //                 },
                //               );
                //             }).toList(),
                //           ),
                //         ),
                //       )
                //     : const SizedBox(),
                DiseaseSelectionWidget(onDiseaseChange: (selected) {
                  selected.forEach((key, value) {
                    FLog.info(text: "$key  $value");
                  });

                  selectedDiseasesWithSeverity = selected;
                }),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 60),
                    shape: const StadiumBorder(),
                    backgroundColor: _color,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ]),
            ),
          )),
    ));
  }
}

class VegNonVegInput extends StatelessWidget {
  final String selectedChoice;
  final Function onVegChange;

  const VegNonVegInput(
      {super.key, required this.selectedChoice, required this.onVegChange});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      validator: (value) {
        if (value == null) {
          return "Please Select the Choice";
        } else {
          return null;
        }
      },
      value: selectedChoice,
      decoration: const InputDecoration(
        labelText: "Veg/Nonveg",
        border: OutlineInputBorder(),
      ),
      items: ["Vegetarian", "Non-Vegetarian"]
          .map((String option) =>
              DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (newValue) {
        // Update the selectedChoice with setState to rebuild the widget
        onVegChange(newValue);
      },
    );
  }
}

class ExerciseInput extends StatelessWidget {
  const ExerciseInput(
      {super.key,
      required this.selectedExercise,
      required this.onExcerciseChange});

  final String selectedExercise;
  final Function onExcerciseChange;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        style:
            const TextStyle(overflow: TextOverflow.fade, color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please Select the choice";
          } else {
            return null;
          }
        },
        value: selectedExercise,
        decoration: const InputDecoration(
            labelText: "How much you exercise?", border: OutlineInputBorder()),
        items: [
          "sedentary",
          "lightly active",
          "moderately active",
          "very active",
          "extremely active"
        ].map((String option) {
          return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
              ));
        }).toList(),
        onChanged: (newValue) {
          onExcerciseChange(newValue);
        });
  }
}

class GoalInput extends StatelessWidget {
  const GoalInput(
      {super.key, required this.selectedGoal, required this.onExcerciseChange});

  final String selectedGoal;
  final Function onExcerciseChange;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        style:
            const TextStyle(overflow: TextOverflow.fade, color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please Select the choice";
          } else {
            return null;
          }
        },
        value: selectedGoal,
        decoration: const InputDecoration(
            labelText: "What is Fitness goal?", border: OutlineInputBorder()),
        items: [
          "Muscle gain",
          "Weight Loss",
          "Maintenance",
        ].map((String option) {
          return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
              ));
        }).toList(),
        onChanged: (newValue) {
          onExcerciseChange(newValue);
        });
  }
}

class HeightWeightInput extends StatelessWidget {
  const HeightWeightInput({
    super.key,
    required this.heightController,
    required this.weightController,
  });

  final TextEditingController heightController;
  final TextEditingController weightController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: heightController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter the Height";
              } else if (double.tryParse(value) == null) {
                return "Enter Only numbers";
              } else if (double.tryParse(value) != null) {
                if (double.tryParse(value)! > 251) {
                  return "Enter Valid Height";
                } else {
                  return null;
                }
              } else {
                return null;
              }
            },
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            decoration: const InputDecoration(
              labelText: "Height(cm)",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextFormField(
            controller: weightController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter the Weight";
              } else if (double.tryParse(value) == null) {
                return "Enter Only numbers";
              } else if (double.tryParse(value) != null) {
                if (double.tryParse(value)! > 635) {
                  return "Enter Valid Weight";
                } else {
                  return null;
                }
              } else {
                return null;
              }
            },
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            decoration: const InputDecoration(
                labelText: "Weight(Kg)", border: OutlineInputBorder()),
          ),
        ),
      ],
    );
  }
}

class _AgeGenderInput extends StatelessWidget {
  const _AgeGenderInput(
      {required this.selectedGender,
      required this.ageController,
      required this.onGenderChanged});

  final String selectedGender;
  final TextEditingController ageController;
  final ValueChanged<String> onGenderChanged; // Type for the callback

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: ageController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter the Age";
            } else if (int.tryParse(value) == null) {
              return "Enter Only numbers";
            } else if (int.tryParse(value) != null) {
              if (int.tryParse(value)! > 122) {
                return "Enter Valid Age";
              } else {
                return null;
              }
            } else {
              return null;
            }
          },
          keyboardType: const TextInputType.numberWithOptions(
              decimal: false, signed: false),
          decoration: const InputDecoration(
              labelText: "Age", border: OutlineInputBorder()),
        ),
        const SizedBox(
          height: 20,
        ),
        DropdownButtonFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please Select the Gender";
            } else {
              return null;
            }
          },
          value: selectedGender,
          decoration: const InputDecoration(
              labelText: "Gender", border: OutlineInputBorder()),
          items: ["male", "female"]
              .map((String gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
              .toList(),
          onChanged: (String? newValue) {
            onGenderChanged(newValue.toString());
          },
        ),
      ],
    );
  }
}

class DiseaseSelectionWidget extends StatefulWidget {
  final ValueChanged<Map<String, String>> onDiseaseChange;

  const DiseaseSelectionWidget({super.key, required this.onDiseaseChange});

  @override
  DiseaseSelectionWidgetState createState() => DiseaseSelectionWidgetState();
}

class DiseaseSelectionWidgetState extends State<DiseaseSelectionWidget> {
  final List<String> diseases = [
    'Coeliac Disease',
    'Hypothyroidism',
    'Type 2 Diabetes',
    'Kidney Disease',
    'Hypertension',
    'Heart Disease',
    'Stroke',
    'Fatty Liver Disease',
    'Osteoarthritis',
    'Migraine',
    'Gallbladder Disease',
    'Malnutrition',
    'Hyperthyroidism',
    'Sleep Apnea',
    'Scleroderma',
  ]; // List of all diseases

  Map<String, String> selectedDiseasesWithSeverity =
      {}; // Store selected diseases with severity

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Select Diseases",
              border: OutlineInputBorder(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: selectedDiseasesWithSeverity.keys.map((disease) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(disease),
                          onDeleted: () {
                            setState(() {
                              selectedDiseasesWithSeverity.remove(disease);
                              widget.onDiseaseChange(
                                  selectedDiseasesWithSeverity);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedDiseasesWithSeverity[disease],
                          items: const [
                            DropdownMenuItem(
                                value: "Mild", child: Text("Mild")),
                            DropdownMenuItem(
                                value: "Moderate", child: Text("Moderate")),
                            DropdownMenuItem(
                                value: "Severe", child: Text("Severe")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedDiseasesWithSeverity[disease] = value!;
                              widget.onDiseaseChange(
                                  selectedDiseasesWithSeverity);
                            });
                          },
                          hint: const Text("Select Severity"),
                          underline:
                              const SizedBox(), // Removes the default underline
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        isExpanded
            ? SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: diseases.map((disease) {
                      return FilterChip(
                        label: Text(disease),
                        selected:
                            selectedDiseasesWithSeverity.containsKey(disease),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDiseasesWithSeverity[disease] =
                                  "Mild"; // Default severity
                            } else {
                              selectedDiseasesWithSeverity.remove(disease);
                            }
                            widget
                                .onDiseaseChange(selectedDiseasesWithSeverity);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  bool isExpanded = false;
}
