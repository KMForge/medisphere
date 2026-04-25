import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class DeliveryAddressScreen extends StatefulWidget {
  static const String routeName = '/delivery-address';
  final String? orderId;

  const DeliveryAddressScreen({super.key, this.orderId});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isDefaultAddress = false;

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAddress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _addressController.text = data['address_line'] ?? '';
          _cityController.text = data['city'] ?? '';
          _provinceController.text = data['province'] ?? '';
          _postalCodeController.text = data['postal_code'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _notesController.text = data['delivery_notes'] ?? '';
          _isDefaultAddress = true;
        });
      }
    } catch (e) {
      debugPrint('[DeliveryAddressScreen] Error loading address: $e');
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      final addressData = {
        'user_id': userId,
        'address_line': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'province': _provinceController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'phone': _phoneController.text.trim(),
        'delivery_notes': _notesController.text.trim(),
        'is_default': _isDefaultAddress,
      };

      // Check if user already has a default address
      final existing = await Supabase.instance.client
          .from('user_addresses')
          .select('address_id')
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (existing != null) {
        // Update existing address
        await Supabase.instance.client
            .from('user_addresses')
            .update(addressData)
            .eq('address_id', existing['address_id']);
      } else {
        // Insert new address
        await Supabase.instance.client
            .from('user_addresses')
            .insert(addressData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery address saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // If this is for a specific order, update the order
        if (widget.orderId != null) {
          await Supabase.instance.client
              .from('orders')
              .update({
                'notes': _notesController.text.trim(),
                'delivery_address': _addressController.text.trim(),
              })
              .eq('order_id', widget.orderId!);
        }

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orderId != null
              ? 'Order Delivery Details'
              : 'Delivery Address',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: isDark ? Colors.grey[800] : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide accurate delivery information for your order.',
                style: TextStyle(
                  fontSize: 16,
                  color: textCol.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '09XXXXXXXXX',
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
                    return 'Please enter a valid Philippine phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Address Line
              _buildTextField(
                controller: _addressController,
                label: 'Street Address',
                hint: '123 Main St, Barangay',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Manila',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _provinceController,
                      label: 'Province',
                      hint: 'Metro Manila',
                      icon: Icons.map,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Province is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                hint: '1000',
                icon: Icons.local_post_office,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Postal code is required';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                    return 'Please enter a valid 4-digit postal code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Delivery Notes
              _buildTextField(
                controller: _notesController,
                label: 'Delivery Notes (Optional)',
                hint: 'Landmark, special instructions, etc.',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Default Address Checkbox
              CheckboxListTile(
                value: _isDefaultAddress,
                onChanged: (value) =>
                    setState(() => _isDefaultAddress = value ?? false),
                title: Text(
                  'Save as default delivery address',
                  style: TextStyle(color: textCol),
                ),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textCol,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
