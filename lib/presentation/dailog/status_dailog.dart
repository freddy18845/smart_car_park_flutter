import 'package:flutter/material.dart';
import '../../Service/api_services.dart';
import '../../utils/constant.dart';
import '../../utils/storage_manage.dart';

class StatusDialog extends StatefulWidget {
  final int parkingSpotId;
  final int parkingSpaceId;
  final int subSpaceId;
  final String currentStatus;
  final String subSpaceLabel;
  final VoidCallback? onStatusUpdated;

  const StatusDialog({
    super.key,
    required this.parkingSpotId,
    required this.parkingSpaceId,
    required this.subSpaceId,
    required this.currentStatus,
    required this.subSpaceLabel,
    this.onStatusUpdated,
  });

  static void show(
      BuildContext context, {
        required int parkingSpotId,
        required int parkingSpaceId,
        required int subSpaceId,
        required String currentStatus,
        required String subSpaceLabel,
        VoidCallback? onStatusUpdated,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatusDialog(
        parkingSpotId: parkingSpotId,
        parkingSpaceId: parkingSpaceId,
        subSpaceId: subSpaceId,
        currentStatus: currentStatus,
        subSpaceLabel: subSpaceLabel,
        onStatusUpdated: onStatusUpdated,
      ),
    );
  }

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  final statusController = TextEditingController();
  bool isLoading = false;
  int? operatorId;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    operatorId = StorageManager().getUserID();
    // Set current status as default
    statusController.text = widget.currentStatus;
  }

  Map<String, dynamic> buildPayload() {
    return {
      "parking_spot_id": widget.parkingSpotId,
      "parking_space_id": widget.parkingSpaceId,
      "operator_id": operatorId,
      "status": statusController.text.trim(),
    };
  }

  Future<void> _updateStatus() async {
    // Validate status is selected
    if (statusController.text.trim().isEmpty) {
      showCustomSnackBar(
        context: context,
        message: "Please select a status",
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Check if status is changed
    if (statusController.text.trim() == widget.currentStatus) {
      showCustomSnackBar(
        context: context,
        message: "Status is already ${widget.currentStatus}",
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Validate operator ID
    if (operatorId == null) {
      showCustomSnackBar(
        context: context,
        message: "Operator ID not found. Please login again.",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final payload = buildPayload();

      final response = await apiService.put(
        'sub-spaces/${widget.subSpaceId}/status',
        payload,
      );

      if (mounted) {
        // Check if response is successful
        if (response['success'] == true || response['data'] != null) {
          showCustomSnackBar(
            context: context,
            message: response["message"] ??
                "Status updated to ${statusController.text} successfully",
          );

          // Call the callback to refresh parent widget
          if (widget.onStatusUpdated != null) {
            widget.onStatusUpdated!();
          }

          Navigator.pop(context, true); // Return true to indicate success
        } else {
          throw Exception(response['message'] ?? 'Failed to update status');
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: "Failed to update status: ${e.toString()}",
          backgroundColor: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        routeNavigation(context: context, pageName: "home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 350),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "CHANGE STATUS",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sub-space info

      Card(
        elevation: 3,
        child:    Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Name: ${widget.subSpaceLabel}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getSubSpaceColor(widget.currentStatus),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 1.0, color: Colors.grey)
                      ),
                      child: Text(
                        widget.currentStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),),
              const SizedBox(height: 16),

              // Dropdown for status
              customDropdownField(
                hint: "Select New Status",
                items: const ["available", "occupied", "reserved", "maintenance"],
                controller: statusController,
                context: context,
                onChanged: (val) {
                  setState(() {
                    statusController.text = val ?? '';
                  });
                },
              ),

              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : () => Navigator.pop(context),
                      child: modalBtn(
                        btnColor: Colors.white,
                        text: 'Cancel',
                        textColor: isLoading
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : _updateStatus,
                      child: modalBtn(
                        btnColor: isLoading
                            ? Colors.grey
                            : Colors.black,
                        text: isLoading ? 'Updating...' : 'Update',
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    statusController.dispose();
    super.dispose();
  }
}