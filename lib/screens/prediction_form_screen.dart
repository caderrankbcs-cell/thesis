import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../models/prediction_model.dart';
import 'result_screen.dart';
import '../widgets/glass_container.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({super.key});

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // Form Field States
  String schoolLocation = "শহর (Urban)";
  String gender = "ছাত্রী (Female)";
  String homeLocation = "শহরাঞ্চল (Urban Area)";
  String groupType = "বিজ্ঞান (Science)";
  String mediumOfEducation = "বাংলা মাধ্যম";

  String familyIncome = "১৫,০০০ - ৪০,০০০ টাকা";
  String fatherEducation = "মাধ্যমিক (এসএসসি বা এর নিচে)";
  String motherEducation = "মাধ্যমিক (এসএসসি বা এর নিচে)";
  String fatherOccupation = "ব্যবসা / স্বনির্ভর";
  String receivedStipend = "না";
  String quietStudyPlace = "হ্যাঁ";

  String attendanceRate = "৭৫% বা তার বেশি";
  String studyHours = "২ - ৪ ঘণ্টা";
  String repeatedClass = "না";
  String homeworkCompletion = "মাঝে মাঝে";

  String privateTutor = "হ্যাঁ";
  String coachingCenter = "না";
  String guideBooks = "হ্যাঁ";
  String extraClasses = "হ্যাঁ";

  String ownedSmartphone = "না";
  String internetAccess = "হ্যাঁ";
  String internetUsageHours = "২ ঘণ্টার কম";
  String socialMediaAccount = "হ্যাঁ";
  String internetPurpose = "উভয়ই সমানভাবে (Both Equally)";

  String schoolLab = "নেই (Not Available)";
  String schoolLibrary = "নেই (Not Available)";

  final TextEditingController f3TeacherController = TextEditingController(text: "5");
  final TextEditingController f4ClassSizeController = TextEditingController(text: "60");

  final List<String> likertOptions = [
    "সম্মত (Agree)",
    "দৃঢ়ভাবে সম্মত (Strongly Agree)",
    "নিরপেক্ষ (Neutral)",
    "অসন্মত (Disagree)",
    "দৃঢ়ভাবে অসন্মত (Strongly Disagree)"
  ];

  String g1 = "সম্মত (Agree)";
  String g2 = "সম্মত (Agree)";
  String g3 = "সম্মত (Agree)";
  String g4 = "সম্মত (Agree)";
  String g5 = "সম্মত (Agree)";

  String g6 = "সম্মত (Agree)";
  String g7 = "সম্মত (Agree)";
  String g8 = "সম্মত (Agree)";
  String g9 = "অসন্মত (Disagree)";

  String g10 = "সম্মত (Agree)";
  String g11 = "সম্মত (Agree)";
  String g12 = "সম্মত (Agree)";
  String g13 = "সম্মত (Agree)";

  @override
  void dispose() {
    f3TeacherController.dispose();
    f4ClassSizeController.dispose();
    super.dispose();
  }

  String _mapSchoolLocation(String val) => val.contains("Urban") ? "Town/City (Urban)" : "Village (Rural)";
  String _mapGender(String val) => val.contains("Female") ? "Female" : "Male";
  String _mapHomeLocation(String val) => val.contains("Urban") ? "Urban Area" : "Rural Area";
  String _mapGroupType(String val) {
    if (val.contains("Science")) return "Science";
    if (val.contains("Arts")) return "Arts (Humanities)";
    if (val.contains("Commerce")) return "Commerce";
    return "Vocational / Dakhil";
  }
  String _mapMedium(String val) {
    if (val.contains("English")) return "English Version";
    if (val.contains("Madrasah")) return "Madrasah / Dakhil";
    return "Bangla Medium";
  }
  String _mapIncome(String val) {
    if (val.contains("১৫,০০০")) return "15000 - 40000 TK";
    if (val.contains("উপরে")) return "Above 40000 TK";
    return "Below 15000 TK";
  }
  String _mapEducation(String val) {
    if (val.contains("প্রাথমিক")) return "Primary";
    if (val.contains("উচ্চ")) return "Higher Secondary (HSC) or Above";
    if (val.contains("মাধ্যমিক")) return "Secondary (SSC or Below)";
    return "No Institutional Education";
  }
  String _mapOccupation(String val) {
    if (val.contains("ব্যবসা")) return "Business / Self-employed";
    if (val.contains("চাকরি")) return "Job (Government or Private)";
    if (val.contains("কৃষি")) return "Agriculture";
    if (val.contains("বেকার")) return "Unemployed";
    return "Others";
  }
  String _mapYesNo(String val) => val == "হ্যাঁ" ? "Yes" : "No";
  String _mapAttendance(String val) {
    if (val.contains("৭৫%")) return "75% or Above";
    if (val.contains("৬০% -")) return "60% - 75%";
    return "Below 60%";
  }
  String _mapStudyHours(String val) {
    if (val.contains("কম")) return "Less than 2 Hours";
    if (val.contains("৪ ঘণ্টার বেশি")) return "More than 4 Hours";
    return "2 - 4 Hours";
  }
  String _mapHomework(String val) {
    if (val.contains("সবসময়")) return "Always";
    if (val.contains("খুব কম")) return "Very Low / Rarely";
    return "Sometimes";
  }
  String _mapInternetUsage(String val) {
    if (val.contains("কখনোই")) return "Never_Use";
    if (val.contains("কম")) return "Less than 2 Hours";
    if (val.contains("বেশি")) return "More than 4 Hours";
    return "2 - 4 Hours";
  }
  String _mapInternetPurpose(String val) {
    if (val.contains("পড়াশোনা")) return "Studying / Educational Content";
    if (val.contains("সামাজিক")) return "Social Media / Entertainment";
    if (val.contains("কখনোই")) return "Never_Use";
    return "Both Equally";
  }
  String _mapFacility(String val) => val.contains("আছে") ? "Available" : "Not Available";

  double _likertToScore(String val, {bool reverse = false}) {
    int base = 3;
    if (val.contains("দৃঢ়ভাবে সম্মত")) {
      base = 5;
    } else if (val.contains("সম্মত")) {
      base = 4;
    } else if (val.contains("নিরপেক্ষ")) {
      base = 3;
    } else if (val.contains("দৃঢ়ভাবে অসন্মত")) {
      base = 1;
    } else if (val.contains("অসন্মত")) {
      base = 2;
    }
    return reverse ? (6 - base).toDouble() : base.toDouble();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("দয়া করে ফর্মে ত্রুটিগুলো সংশোধন করুন"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    double se1 = _likertToScore(g1);
    double se2 = _likertToScore(g2);
    double se3 = _likertToScore(g3);
    double se4 = _likertToScore(g4);
    double se5 = _likertToScore(g5);
    double academicSelfEfficacyScore = (se1 + se2 + se3 + se4 + se5) / 5.0;

    double ax6 = _likertToScore(g6);
    double ax7 = _likertToScore(g7);
    double ax8 = _likertToScore(g8);
    double ax9 = _likertToScore(g9, reverse: true);
    double examAnxietyScore = (ax6 + ax7 + ax8 + ax9) / 4.0;

    double sup10 = _likertToScore(g10);
    double sup11 = _likertToScore(g11);
    double sup12 = _likertToScore(g12);
    double sup13 = _likertToScore(g13);
    double familyAcademicSupportScore = (sup10 + sup11 + sup12 + sup13) / 4.0;

    Map<String, dynamic> studentData = {
      "Q3_School_Location": _mapSchoolLocation(schoolLocation),
      "A1_Gender": _mapGender(gender),
      "A2_Home_Location": _mapHomeLocation(homeLocation),
      "A3_Group_Type": _mapGroupType(groupType),
      "A4_Medium_of_Education": _mapMedium(mediumOfEducation),
      "B1_Monthly_Family_Income": _mapIncome(familyIncome),
      "B2_Father_Education": _mapEducation(fatherEducation),
      "B3_Mother_Education": _mapEducation(motherEducation),
      "B4_Father_Occupation": _mapOccupation(fatherOccupation),
      "B5_Received_Stipend": _mapYesNo(receivedStipend),
      "B6_Quiet_Study_Place_At_Home": _mapYesNo(quietStudyPlace),
      "C1_Class_Attendance_Rate": _mapAttendance(attendanceRate),
      "C2_Daily_Self_Study_Hours": _mapStudyHours(studyHours),
      "C3_Repeated_Any_Class": _mapYesNo(repeatedClass),
      "C4_Regular_Homework_Completion": _mapHomework(homeworkCompletion),
      "D1_Private_Tutor_At_Home": _mapYesNo(privateTutor),
      "D2_Attended_Coaching_Center": _mapYesNo(coachingCenter),
      "D3_Used_Suggestion_Or_Guide_Books": _mapYesNo(guideBooks),
      "D4_Extra_Classes_At_School": _mapYesNo(extraClasses),
      "E0_Owned_Smartphone": _mapYesNo(ownedSmartphone),
      "E1_Internet_Access": _mapYesNo(internetAccess),
      "E2_Daily_Internet_Usage_Hours": _mapInternetUsage(internetUsageHours),
      "E3_Social_Media_Account": _mapYesNo(socialMediaAccount),
      "E4_Primary_Purpose_of_Internet": _mapInternetPurpose(internetPurpose),
      "F1_School_Lab_Facility": _mapFacility(schoolLab),
      "F2_School_Library_Facility": _mapFacility(schoolLibrary),
      "F3_Departmental_Teacher_Count": int.tryParse(f3TeacherController.text) ?? 5,
      "F4_Class_Student_Count": int.tryParse(f4ClassSizeController.text) ?? 60,
      "Academic_Self_Efficacy_Score": academicSelfEfficacyScore,
      "Exam_Anxiety_Score": examAnxietyScore,
      "Family_Academic_Support_Score": familyAcademicSupportScore,
    };

    try {
      PredictionResponse response = await ApiService.predictStudent(studentData);
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(predictionResponse: response, inputData: studentData),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("পূর্বাভাস ত্রুটি"),
          content: Text(e.toString().replaceAll("Exception: ", "")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ঠিক আছে"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("শিক্ষার্থীর তথ্য ফরম (Survey)"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCubeGrid(color: Colors.cyanAccent, size: 50.0),
                    SizedBox(height: 20),
                    Text("শিক্ষার্থীর প্রোফাইল বিশ্লেষণ করা হচ্ছে...", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  onStepContinue: () {
                    if (_currentStep < 5) {
                      setState(() => _currentStep += 1);
                    } else {
                      _submitForm();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _currentStep == 5 ? "ফলাফল দেখুন (Predict)" : "পরবর্তী ধাপ (Next)",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("পূর্ববর্তী"),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 0: Background
                    Step(
                      title: const Text("ব্যাকগ্রাউন্ড ও ডেমোগ্রাফিক", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন এ", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        children: [
                          _buildInteractiveCard("৩. বিদ্যালয়ের অবস্থান", ["শহর (Urban)", "গ্রাম (Rural)"], schoolLocation, (val) => setState(() => schoolLocation = val)),
                          _buildInteractiveCard("এ১. লিঙ্গ", ["ছাত্রী (Female)", "ছাত্র (Male)"], gender, (val) => setState(() => gender = val)),
                          _buildInteractiveCard("এ২. বাড়ি কোথায় অবস্থিত?", ["শহরাঞ্চল (Urban Area)", "গ্রামাঞ্চল (Rural Area)"], homeLocation, (val) => setState(() => homeLocation = val)),
                          _buildInteractiveCard("এ৩. এসএসসির বিভাগের ধরন", ["বিজ্ঞান (Science)", "বাণিজ্য (Commerce)", "মানবিক (Arts)", "ভোকেশনাল / দাখিল"], groupType, (val) => setState(() => groupType = val)),
                          _buildInteractiveCard("এ৪. বিদ্যালয়ের শিক্ষার মাধ্যম", ["বাংলা মাধ্যম", "ইংরেজি ভার্সন", "মাদ্রাসা / দাখিল"], mediumOfEducation, (val) => setState(() => mediumOfEducation = val)),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),

                    // Step 1: Family & Socioeconomic
                    Step(
                      title: const Text("পারিবারিক ও সামাজিক অবস্থা", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন বি", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        children: [
                          _buildInteractiveCard("বি১. পরিবারের আনুমানিক মাসিক আয়", ["১৫,০০০ টাকার নিচে", "১৫,০০০ - ৪০,০০০ টাকা", "৪০,০০০ টাকার উপরে"], familyIncome, (val) => setState(() => familyIncome = val)),
                          _buildInteractiveCard("বি২. পিতার সর্বোচ্চ শিক্ষাগত যোগ্যতা", ["কোনো প্রাতিষ্ঠানিক শিক্ষা নেই", "প্রাথমিক", "মাধ্যমিক (এসএসসি বা এর নিচে)", "উচ্চ মাধ্যমিক বা তার উপরে"], fatherEducation, (val) => setState(() => fatherEducation = val)),
                          _buildInteractiveCard("বি৩. মাতার সর্বোচ্চ শিক্ষাগত যোগ্যতা", ["কোনো প্রাতিষ্ঠানিক শিক্ষা নেই", "প্রাথমিক", "মাধ্যমিক (এসএসসি বা এর নিচে)", "উচ্চ মাধ্যমিক বা তার উপরে"], motherEducation, (val) => setState(() => motherEducation = val)),
                          _buildInteractiveCard("বি৪. পিতার পেশা", ["বেকার", "ব্যবসা / স্বনির্ভর", "চাকরি (সরকারি বা বেসরকারি)", "কৃষিকাজ", "অন্যান্য"], fatherOccupation, (val) => setState(() => fatherOccupation = val)),
                          _buildInteractiveCard("বি৫. উপবৃত্তি/বৃত্তি পেয়েছিলেন?", ["হ্যাঁ", "না"], receivedStipend, (val) => setState(() => receivedStipend = val)),
                          _buildInteractiveCard("বি৬. বাড়িতে পড়াশোনার নির্জন স্থান ছিল?", ["হ্যাঁ", "না"], quietStudyPlace, (val) => setState(() => quietStudyPlace = val)),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),

                    // Step 2: Academic History
                    Step(
                      title: const Text("অ্যাকাডেমিক ইতিহাস ও অভ্যাস", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন সি", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        children: [
                          _buildInteractiveCard("সি১. ক্লাসে উপস্থিতির হার", ["৬০% এর নিচে", "৬০% - ৭৫%", "৭৫% বা তার বেশি"], attendanceRate, (val) => setState(() => attendanceRate = val)),
                          _buildInteractiveCard("সি২. স্কুলের বাইরে দৈনিক নিজ-অধ্যয়ন", ["২ ঘণ্টার কম", "২ - ৪ ঘণ্টা", "৪ ঘণ্টার বেশি"], studyHours, (val) => setState(() => studyHours = val)),
                          _buildInteractiveCard("সি৩. একই শ্রেণিতে পুনরায় অধ্যয়ন?", ["না", "হ্যাঁ"], repeatedClass, (val) => setState(() => repeatedClass = val)),
                          _buildInteractiveCard("সি৪. নিয়মিত বাড়ির কাজ সম্পন্ন করতেন?", ["খুব কম", "মাঝে মাঝে", "সবসময়"], homeworkCompletion, (val) => setState(() => homeworkCompletion = val)),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),

                    // Step 3: Tutoring & Digital
                    Step(
                      title: const Text("টিউশনি ও ডিজিটাল ব্যবহার", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন ডি ও ই", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        children: [
                          _buildInteractiveCard("ডি১. বাসায় প্রাইভেট শিক্ষক ছিলেন?", ["না", "হ্যাঁ"], privateTutor, (val) => setState(() => privateTutor = val)),
                          _buildInteractiveCard("ডি২. কোচিং সেন্টারে ভর্তি ছিলেন?", ["না", "হ্যাঁ"], coachingCenter, (val) => setState(() => coachingCenter = val)),
                          _buildInteractiveCard("ডি৩. সাজেশন বা গাইড বই ব্যবহার করতেন?", ["না", "হ্যাঁ"], guideBooks, (val) => setState(() => guideBooks = val)),
                          _buildInteractiveCard("ডি৪. স্কুলের অতিরিক্ত ক্লাস করতেন?", ["না", "হ্যাঁ"], extraClasses, (val) => setState(() => extraClasses = val)),
                          _buildInteractiveCard("ই০. স্মার্টফোন ছিল?", ["হ্যাঁ", "না"], ownedSmartphone, (val) => setState(() => ownedSmartphone = val)),
                          _buildInteractiveCard("ই১. ইন্টারনেট ব্যবহারের সুযোগ ছিল?", ["হ্যাঁ", "না"], internetAccess, (val) => setState(() => internetAccess = val)),
                          _buildInteractiveCard("ই২. দৈনিক ইন্টারনেট ব্যবহারের সময়", ["কখনোই না (Never_Use)", "২ ঘণ্টার কম", "২ - ৪ ঘণ্টা", "৪ ঘণ্টার বেশি"], internetUsageHours, (val) => setState(() => internetUsageHours = val)),
                          _buildInteractiveCard("ই৩. সোশ্যাল মিডিয়া অ্যাকাউন্ট ছিল?", ["হ্যাঁ", "না"], socialMediaAccount, (val) => setState(() => socialMediaAccount = val)),
                          _buildInteractiveCard("ই৪. ইন্টারনেটের প্রধান উদ্দেশ্য কী ছিল?", ["কখনোই না (Never_Use)", "পড়াশোনা / শিক্ষামূলক কনটেন্ট", "সামাজিক যোগাযোগমাধ্যম / বিনোদন", "উভয়ই সমানভাবে"], internetPurpose, (val) => setState(() => internetPurpose = val)),
                        ],
                      ),
                      isActive: _currentStep >= 3,
                    ),

                    // Step 4: School Facility
                    Step(
                      title: const Text("স্কুল সম্পর্কিত তথ্যাদি", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন এফ", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        children: [
                          _buildInteractiveCard("এফ১. স্কুলে ল্যাব সুবিধা ছিল?", ["আছে (Available)", "নেই (Not Available)"], schoolLab, (val) => setState(() => schoolLab = val)),
                          _buildInteractiveCard("এফ২. স্কুলে লাইব্রেরি সুবিধা ছিল?", ["আছে (Available)", "নেই (Not Available)"], schoolLibrary, (val) => setState(() => schoolLibrary = val)),
                          _buildTextField("এফ৩. বিভাগে বিভাগীয় শিক্ষক সংখ্যা আনুমানিক কত?", f3TeacherController),
                          _buildTextField("এফ৪. ক্লাসে শিক্ষার্থীর সংখ্যা আনুমানিক কত?", f4ClassSizeController),
                        ],
                      ),
                      isActive: _currentStep >= 4,
                    ),

                    // Step 5: Psychometric Scale (G1 - G13)
                    Step(
                      title: const Text("মনস্তাত্ত্বিক আচরণ (G1 - G13)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("সেকশন জি (Likert Scale)", style: TextStyle(color: Colors.white70)),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSub("G1-G5: Academic Self-Efficacy"),
                          _buildInteractiveCard("G1. চেষ্টা করলে সবচেয়ে কঠিন বিষয়ও বুঝতে পারব", likertOptions, g1, (val) => setState(() => g1 = val)),
                          _buildInteractiveCard("G2. এসএসসির সব বিষয়ের মৌলিক ধারণা শিখতে পারব", likertOptions, g2, (val) => setState(() => g2 = val)),
                          _buildInteractiveCard("G3. এসএসসির পর্যায়ে দক্ষতাগুলো আয়ত্ত করতে পারব", likertOptions, g3, (val) => setState(() => g3 = val)),
                          _buildInteractiveCard("G4. অন্য শিক্ষার্থীদের তুলনায় ভালো ফল করব", likertOptions, g4, (val) => setState(() => g4 = val)),
                          _buildInteractiveCard("G5. পরীক্ষার প্রশ্নে ভালো করতে পারব", likertOptions, g5, (val) => setState(() => g5 = val)),

                          const SizedBox(height: 12),
                          _buildHeaderSub("G6-G9: Exam Anxiety"),
                          _buildInteractiveCard("G6. পরীক্ষার সময় নার্ভাস হয়ে পড়া ভুলে যাওয়া", likertOptions, g6, (val) => setState(() => g6 = val)),
                          _buildInteractiveCard("G7. পরীক্ষার চিন্তায় আগের রাতে ঘুমাতে না পারা", likertOptions, g7, (val) => setState(() => g7 = val)),
                          _buildInteractiveCard("G8. চাপের কারণে সামর্থ্যের চেয়ে কম ভালো করা", likertOptions, g8, (val) => setState(() => g8 = val)),
                          _buildInteractiveCard("G9. পরীক্ষার সময় শান্ত ও স্বস্তিতে থাকা (Reverse)", likertOptions, g9, (val) => setState(() => g9 = val)),

                          const SizedBox(height: 12),
                          _buildHeaderSub("G10-G13: Family Academic Support"),
                          _buildInteractiveCard("G10. বাবা-মা কঠোর পরিশ্রম করতে উৎসাহিত করতেন", likertOptions, g10, (val) => setState(() => g10 = val)),
                          _buildInteractiveCard("G11. পরিবার স্কুলে অগ্রগতির প্রতি আগ্রহ দেখাত", likertOptions, g11, (val) => setState(() => g11 = val)),
                          _buildInteractiveCard("G12. পড়ার জন্য যথেষ্ট সময় ও উপকরণ পেতাম", likertOptions, g12, (val) => setState(() => g12 = val)),
                          _buildInteractiveCard("G13. পরিবার নিয়মিত স্কুলের অগ্রগতি নিয়ে আলোচনা করত", likertOptions, g13, (val) => setState(() => g13 = val)),
                        ],
                      ),
                      isActive: _currentStep >= 5,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSub(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
      ),
    );
  }

  Widget _buildInteractiveCard(String label, List<String> options, String selectedValue, ValueChanged<String> onChanged) {
    return GlassContainer(
      borderRadius: 14,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              bool isSelected = selectedValue == option;
              return ChoiceChip(
                label: Text(option, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                selectedColor: Colors.cyanAccent,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                onSelected: (selected) {
                  if (selected) {
                    onChanged(option);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyanAccent)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'দয়া করে একটি মান লিখুন';
          if (int.tryParse(value) == null) return 'অবশ্যই পূর্ণসংখ্যা হতে হবে';
          return null;
        },
      ),
    );
  }
}
