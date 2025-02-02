import 'package:daimond_host_provider/constants/colors.dart';
import 'package:flutter/material.dart';

import '../localization/language_constants.dart';

class AdditionalsRestaurantCoffee extends StatefulWidget {
  final bool isVisible;
  final Function(bool, String) onCheckboxChanged;

  const AdditionalsRestaurantCoffee({
    super.key,
    required this.isVisible,
    required this.onCheckboxChanged,
  });

  @override
  _AdditionalsRestaurantCoffeeState createState() =>
      _AdditionalsRestaurantCoffeeState();
}

class _AdditionalsRestaurantCoffeeState
    extends State<AdditionalsRestaurantCoffee> {
  bool checkHookah = false;
  bool checkBuffet = false;
  bool checkBreakfastBuffet = false;
  bool checkLunchBuffet = false;
  bool checkDinnerBuffet = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return Container();

    return Column(
      children: [
        _buildCheckboxRow(
          context,
          "Is there Hookah?",
          checkHookah,
          (value) {
            setState(() => checkHookah = value);
            widget.onCheckboxChanged(value, "Is there Hookah?");
          },
        ),
        _buildCheckboxRow(
          context,
          "Is there Buffet?",
          checkBuffet,
          (value) {
            setState(() => checkBuffet = value);
            widget.onCheckboxChanged(value, "Is there Buffet?");
            if (!value) {
              checkBreakfastBuffet = false;
              checkLunchBuffet = false;
              checkDinnerBuffet = false;
            }
          },
        ),
        if (checkBuffet)
          Column(
            children: [
              _buildCheckboxRow(
                context,
                "Is there a breakfast buffet?",
                checkBreakfastBuffet,
                (value) {
                  setState(() => checkBreakfastBuffet = value);
                  widget.onCheckboxChanged(
                      value, "Is there a breakfast buffet?");
                },
              ),
              _buildCheckboxRow(
                context,
                "Is there a lunch buffet?",
                checkLunchBuffet,
                (value) {
                  setState(() => checkLunchBuffet = value);
                  widget.onCheckboxChanged(value, "Is there a lunch buffet?");
                },
              ),
              _buildCheckboxRow(
                context,
                "Is there a dinner buffet?",
                checkDinnerBuffet,
                (value) {
                  setState(() => checkDinnerBuffet = value);
                  widget.onCheckboxChanged(value, "Is there a dinner buffet?");
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCheckboxRow(BuildContext context, String label, bool value,
      Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            getTranslated(context, label),
          ),
        ),
        Expanded(
          child: Checkbox(
            checkColor: Colors.white,
            value: value,
            onChanged: (bool? newValue) => onChanged(newValue!),
            activeColor: kPurpleColor,
          ),
        ),
      ],
    );
  }
}
