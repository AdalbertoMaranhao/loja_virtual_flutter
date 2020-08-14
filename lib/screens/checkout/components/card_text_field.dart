import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardTextField extends StatelessWidget {

  const CardTextField({
    this.title,
    this.bold = false,
    this.hint,
    this.textInputType,
    this.inputFormaters,
    this.validator,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.onSubmitted,
    this.onSaved,
    this.initialValue,
  }) : textInputAction = onSubmitted == null
      ? TextInputAction.done
      : TextInputAction.next;

  final String title;
  final bool bold;
  final String hint;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormaters;
  final FormFieldValidator<String> validator;
  final int maxLength;
  final TextAlign textAlign;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final TextInputAction textInputAction;
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return  FormField<String>(
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      builder: (state){
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(title != null)
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    if(state.hasError)
                      Text(
                        '   Inválido',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 9
                        ),
                      ),
                  ],
                ),
              TextFormField(
                initialValue: initialValue,
                style: TextStyle(
                  color: title == null && state.hasError
                      ? Colors.red
                      : Colors.white,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: title == null && state.hasError
                          ? Colors.red.withAlpha(100)
                          : Colors.white.withAlpha(100),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  counterText: '',
                ),
                keyboardType: textInputType,
                inputFormatters: inputFormaters,
                maxLength: maxLength,
                textAlign: textAlign,
                focusNode: focusNode,
                onFieldSubmitted: onSubmitted,
                textInputAction: textInputAction,
                onChanged: (text){
                  state.didChange(text);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}