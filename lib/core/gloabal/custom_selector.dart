import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../design_system/app_color.dart';
import 'custom_text.dart';

class CustomSelectField<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final List<T>? initialSelectedItems;
  final String label;
  final String hintText;
  final String Function(T) itemLabelBuilder;
  final bool isMultiSelect;
  final bool showSearchBar;
  final bool showActionButtons;
  final TextEditingController? controller;

  // ADDED: Optional onChanged parameter
  final void Function(dynamic)? onChanged;

  const CustomSelectField({
    super.key,
    required this.items,
    this.value,
    this.initialSelectedItems,
    required this.label,
    required this.hintText,
    required this.itemLabelBuilder,
    this.isMultiSelect = false,
    this.showSearchBar = false,
    this.showActionButtons = true,
    this.controller,
    this.onChanged, // Initialize here
  });

  @override
  Widget build(BuildContext context) {
    String displayText = hintText;

    if (isMultiSelect && initialSelectedItems != null && initialSelectedItems!.isNotEmpty) {
      displayText = initialSelectedItems!.map(itemLabelBuilder).join(", ");
    } else if (value != null) {
      displayText = itemLabelBuilder(value as T);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, fontSize: 16.sp, fontWeight: FontWeight.w600),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => _openSelectDialog(context),
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.grey100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    text: displayText,
                    color: displayText == hintText ? AppColor.grey400 : AppColor.black,
                    fontSize: 14.sp,
                    maxLines: 1,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColor.grey400, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openSelectDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => _SelectDialog<T>(
        items: items,
        initialValue: value,
        initialSelectedItems: initialSelectedItems,
        title: hintText,
        itemLabelBuilder: itemLabelBuilder,
        isMultiSelect: isMultiSelect,
        showSearchBar: showSearchBar,
        showActionButtons: showActionButtons,
      ),
    );

    if (result != null) {
      // 1. Update Controller if it exists
      if (controller != null) {
        if (isMultiSelect && result is List) {
          controller!.text = (result as List<T>).map(itemLabelBuilder).join(", ");
        } else {
          controller!.text = itemLabelBuilder(result as T);
        }
      }

      // 2. TRIGGER ONCHANGED: Pass the result back to the caller
      if (onChanged != null) {
        onChanged!(result);
      }
    }
  }
}

// Internal Dialog remains the same, but returns the generic type T or List<T>
class _SelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final List<T>? initialSelectedItems;
  final String title;
  final String Function(T) itemLabelBuilder;
  final bool isMultiSelect;
  final bool showSearchBar;
  final bool showActionButtons;

  const _SelectDialog({
    required this.items,
    this.initialValue,
    this.initialSelectedItems,
    required this.title,
    required this.itemLabelBuilder,
    required this.isMultiSelect,
    required this.showSearchBar,
    required this.showActionButtons,
  });

  @override
  State<_SelectDialog<T>> createState() => _SelectDialogState<T>();
}

class _SelectDialogState<T> extends State<_SelectDialog<T>> {
  late List<T> filteredItems;
  List<T> selectedItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    if (widget.isMultiSelect) {
      selectedItems = List.from(widget.initialSelectedItems ?? []);
    } else if (widget.initialValue != null) {
      selectedItems = [widget.initialValue!];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(T item) {
    setState(() {
      if (widget.isMultiSelect) {
        selectedItems.contains(item)
            ? selectedItems.remove(item)
            : selectedItems.add(item);
      } else {
        selectedItems = [item];
        if (!widget.showActionButtons) Navigator.pop(context, item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = selectedItems.length == widget.items.length;

    return AlertDialog(
      backgroundColor: AppColor.white,
      surfaceTintColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Column(
        children: [
          CustomText(
            text: widget.title,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          if (widget.showSearchBar) ...[
            SizedBox(height: 16.h),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {
                filteredItems = widget.items.where((i) =>
                    widget.itemLabelBuilder(i).toLowerCase().contains(val.toLowerCase())).toList();
              }),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: AppColor.grey400, fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, color: AppColor.grey400),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: AppColor.grey400, size: 20.sp),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => filteredItems = widget.items);
                  },
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide(color: AppColor.grey100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide(color: AppColor.grey100),
                ),
              ),
            ),
          ]
        ],
      ),
      content: SizedBox(
        width: 1.sw,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isMultiSelect) ...[
              ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                leading: Icon(
                  isAllSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isAllSelected ? const Color(0xFFFFC107) : AppColor.grey300,
                  size: 22.sp,
                ),
                title: CustomText(text: "Select All", color: AppColor.grey500, fontSize: 14.sp),
                onTap: () {
                  setState(() {
                    if (isAllSelected) {
                      selectedItems.clear();
                    } else {
                      selectedItems = List.from(widget.items);
                    }
                  });
                },
              ),
              const Divider(color: AppColor.grey100, height: 16),
            ],
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = selectedItems.contains(item);
                  return ListTile(
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    leading: widget.isMultiSelect
                        ? Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFFFFC107) : AppColor.grey300,
                      size: 22.sp,
                    )
                        : null,
                    title: CustomText(
                      text: widget.itemLabelBuilder(item),
                      color: isSelected ? AppColor.black : AppColor.grey500,
                      fontSize: 14.sp,
                    ),
                    trailing: !widget.isMultiSelect && isSelected
                        ? Icon(Icons.check, color: const Color(0xFFFFC107), size: 20.sp)
                        : null,
                    onTap: () => _toggle(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h),
      actions: widget.showActionButtons ? [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: const BorderSide(color: Color(0xFFFFC107)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () => Navigator.pop(context),
                child: CustomText(
                    text: "Cancel",
                    color: const Color(0xFFFFC107),
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                onPressed: () => Navigator.pop(
                    context,
                    widget.isMultiSelect ? selectedItems : (selectedItems.isNotEmpty ? selectedItems.first : null)
                ),
                child: CustomText(
                    text: "Done",
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        )
      ] : null,
    );
  }
}