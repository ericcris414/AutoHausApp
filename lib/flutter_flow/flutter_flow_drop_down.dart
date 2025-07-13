import 'package:flutter/material.dart';

class FlutterFlowDropDown<T> extends StatelessWidget {
  const FlutterFlowDropDown({
    Key? key,
    required this.options,
    required this.onChanged,
    this.controller,
    this.width,
    this.height,
    this.textStyle,
    this.hintText,
    this.icon,
    this.fillColor,
    this.elevation,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.margin,
    this.hidesUnderline = true,
    this.isOverButton = false,
    this.isSearchable = false,
    this.isMultiSelect = false,
  }) : super(key: key);

  final List<T> options;
  final void Function(T?) onChanged;
  final controller;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final String? hintText;
  final Widget? icon;
  final Color? fillColor;
  final double? elevation;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool hidesUnderline;
  final bool isOverButton;
  final bool isSearchable;
  final bool isMultiSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 50.0,
      margin: margin,
      decoration: BoxDecoration(
        color: fillColor ?? Colors.grey.shade900, // Cor cinza escuro
        borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade700,
          width: borderWidth ?? 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          dropdownColor: fillColor ?? Colors.grey.shade900, // fundo da lista
          value: controller?.value,
          isExpanded: true,
          icon: icon ??
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
          style: textStyle ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
          onChanged: (val) {
            controller?.value = val;
            onChanged(val);
          },
          items: options.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(value.toString(),
                  style: textStyle ??
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          )),
            );
          }).toList(),
          hint: Text(
            hintText ?? 'Select...',
            style: textStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
          ),
          // Configuração da borda arredondada quando a lista é aberta
          selectedItemBuilder: (BuildContext context) {
  return options.map<Widget>((T value) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 4.0),
      child: Text(
        value.toString(),
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }).toList();
}
        ),
      ),
    );
  }
}
