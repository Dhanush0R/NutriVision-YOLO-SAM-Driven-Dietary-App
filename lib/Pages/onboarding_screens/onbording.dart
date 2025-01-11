import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';

const _color = Color.fromARGB(255, 145, 199, 137);
var hex = "91c789";

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 80, bottom: 30, left: 10, right: 10),
        child: Onboarding(
          swipeableBody: const [
            _firstInfo(
                "Transform your diet with personalized recommendations! Track your meals, analyze nutrition, and achieve your health goals effortlessly.",
                "logo3.png"),
            _InfoCard(
                "Capture and Analyze Meals",
                "Snap a photo of your meal, and let our AI analyze its nutritional content.Instant insights on calories, carbs, protein, and more!",
                "capture_img4.png"),
            _InfoCard(
                "Personalized Nutrition Intake",
                "Your dashboard, tailored just for you! See your daily nutritional requirements and track your progress with ease.",
                "dashboard_img4.png"),
            _InfoCard(
                "Get Food Recommendations",
                "Receive meal suggestions based on your nutritional needs. Healthy eating has never been this simple!",
                "recommendation_img.png")
          ],
          startIndex: 0,
          buildHeader: (context, netDragDistance, pagesLength, currentIndex,
                  setPageIndex, slideDirection) =>
              _Title(currentIndex),
          buildFooter: (context, netDragDistance, pagesLength, currentIndex,
                  setIndex, slideDirection) =>
              Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Indicator<CirclePainter>(
                  painter: CirclePainter(
                    currentPageIndex: currentIndex,
                    pagesLength: pagesLength,
                    netDragPercent: netDragDistance,
                    activePainter: Paint()..color = _color,
                    inactivePainter: Paint()..color = Colors.grey,
                    radius: 5,
                    translate: false,
                    slideDirection: slideDirection,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final int index;
  const _Title(this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: index != 0
            ? const Text(
                "NutriVision",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              )
            : const Text(
                "Welcome To",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ));
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/userform');
          },
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            fixedSize: const Size(340, 80),
            backgroundColor: _color,
          ),
          child: const Text(
            "Get Started",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already Have An Account?",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/loginpage');
                },
                child: const Text(
                  "Log In",
                  style: TextStyle(
                    color: _color,
                    fontSize: 18,
                  ),
                ))
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String _title;
  final String _info;
  final String _image;

  const _InfoCard(
    this._title,
    this._info,
    this._image,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$_image', // Path to your image
            height: 300, // Set the height of the image
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            _title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _info,
            textAlign: TextAlign.center,
            style: const TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}

class _firstInfo extends StatelessWidget {
  final String _info;
  final String _image;

  const _firstInfo(
    this._info,
    this._image,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/$_image', // Path to your image
            height: 300, // Set the height of the image
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            _info,
            textAlign: TextAlign.center,
            style: const TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}
