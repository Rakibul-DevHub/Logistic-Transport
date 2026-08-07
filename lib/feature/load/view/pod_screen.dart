// /**
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tag/core/constants/app_routes.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_style.dart';
// import '../../../shared/components/Custom_Elevated_Button.dart';
//
// class PODScreen extends StatefulWidget {
//   const PODScreen({super.key});
//
//   @override
//   State<PODScreen> createState() => _PODScreenState();
// }
//
// class _PODScreenState extends State<PODScreen> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _showImageSourceDialog() async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Wrap(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Select Image Source',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: AppColors.lightBlueColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(
//                           Icons.camera_alt,
//                           color: AppColors.primaryColor,
//                           size: 24,
//                         ),
//                       ),
//                       title: const Text(
//                         'Camera',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       subtitle: const Text(
//                         'Take a new photo',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF888888),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.camera);
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     ListTile(
//                       leading: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: AppColors.lightBlueColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(
//                           Icons.photo_library,
//                           color: AppColors.primaryColor,
//                           size: 24,
//                         ),
//                       ),
//                       title: const Text(
//                         'Gallery',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       subtitle: const Text(
//                         'Choose from gallery',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF888888),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.gallery);
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInvoiceCard(),
//                   const SizedBox(height: 16),
//                   _buildInstructionsCard(),
//                   const SizedBox(height: 16),
//                   CustomElevatedButton(
//                     onPressed:() {
//                       // // Continue to next screen or save POD
//                       // Navigator.pop(context);
//                       Navigator.pushNamed(context, AppRoutes.billOfLoad);
//                     },
//                     buttonText:'Continue',
//                     backgroundColor: AppColors.primaryColor,
//                     foregroundColor: AppColors.whiteColor,
//                     height: 48,
//                     borderRadius: BorderRadius.circular(30),
//                     isFullWidth: true,
//                     hasShadow: false,
//                     icon: _selectedImage != null
//                         ? const Icon(Icons.check, size: 20)
//                         : SvgPicture.asset(
//                       'assets/icons/upload.svg',
//                       colorFilter: const ColorFilter.mode(
//                         AppColors.whiteColor,
//                         BlendMode.srcIn,
//                       ),
//                     ),
//                     gap: 8,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.backgroundColor,
//       surfaceTintColor: AppColors.backgroundColor,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 14),
//         child: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
//         ),
//       ),
//       title: const Text(
//         'POD',
//         style: TextStyle(
//           color: Color(0xFF1A1A2E),
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       centerTitle: true,
//     );
//   }
//
//   Widget _buildInvoiceCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           // Invoice Image from assets - Centered
//           Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(
//                 'assets/images/demo_bol.jpg',
//                 fit: BoxFit.contain,
//                 width: double.infinity,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     height: 400,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5F7FA),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFE1E8ED),
//                         width: 1,
//                       ),
//                     ),
//                     child: const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.image_not_supported,
//                             size: 64,
//                             color: Color(0xFF888888),
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             'Invoice image not found',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF888888),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 12),
//           Text(
//             'Proof of Delivery Document',
//             style: AppTextStyle.SFProDisplay_Regular.copyWith(
//               fontSize: 12,
//               color: const Color(0xFF888888),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInstructionsCard() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.lightBlueColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline,
//                 color: AppColors.primaryColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Instructions',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             '1. Upload or capture the Proof of Delivery document\n'
//                 '2. Ensure recipient signature is visible\n'
//                 '3. Click "Continue" to complete the delivery',
//             style: TextStyle(
//               fontSize: 12,
//               color: Color(0xFF555555),
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }*/
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// // feature/load/view/proof_of_delivery/pod_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_style.dart';
// import '../../../shared/components/Custom_Elevated_Button.dart';
// import '../../../core/constants/app_routes.dart';
// import 'bol_screen.dart';
//
// class PODScreen extends StatefulWidget {
//   const PODScreen({super.key});
//
//   @override
//   State<PODScreen> createState() => _PODScreenState();
// }
//
// class _PODScreenState extends State<PODScreen> {
//   File? _selectedImage;
//   String? _imageUrl;
//   String? _loadId;
//   File? _bolImageFromArgs;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final args = ModalRoute.of(context)!.settings.arguments;
//
//       if (args is Map) {
//         _imageUrl = args['imageUrl'] as String?;
//         _loadId = args['loadId'] as String?;
//
//         // Get the BOL image from args
//         if (args['imageFile'] != null && args['imageFile'] is File) {
//           _bolImageFromArgs = args['imageFile'] as File;
//         } else if (args['imagePath'] != null) {
//           _bolImageFromArgs = File(args['imagePath'] as String);
//         }
//         setState(() {});
//       } else if (args is PODScreenArgs) {
//         _imageUrl = args.imageUrl;
//         _loadId = args.loadId;
//         if (args.imageFile != null) {
//           _bolImageFromArgs = args.imageFile;
//         } else if (args.imagePath != null) {
//           _bolImageFromArgs = File(args.imagePath!);
//         }
//         setState(() {});
//       }
//     });
//   }
//
//   Future<void> _showImageSourceDialog() async {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Wrap(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Select Image Source',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: AppColors.lightBlueColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(
//                           Icons.camera_alt,
//                           color: AppColors.primaryColor,
//                           size: 24,
//                         ),
//                       ),
//                       title: const Text(
//                         'Camera',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       subtitle: const Text(
//                         'Take a new photo',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF888888),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.camera);
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     ListTile(
//                       leading: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: AppColors.lightBlueColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(
//                           Icons.photo_library,
//                           color: AppColors.primaryColor,
//                           size: 24,
//                         ),
//                       ),
//                       title: const Text(
//                         'Gallery',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       subtitle: const Text(
//                         'Choose from gallery',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF888888),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);
//                         _pickImage(ImageSource.gallery);
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   void _continueToBOL() {
//     // Pass the BOL image and POD image to BOL screen
//     final args = BOLScreenArgs(
//       imagePath: _selectedImage?.path ?? _bolImageFromArgs?.path,
//       imageUrl: _imageUrl,
//       loadId: _loadId,
//       imageFile: _selectedImage ?? _bolImageFromArgs,
//     );
//
//     Navigator.pushNamed(
//       context,
//       AppRoutes.billOfLoad,
//       arguments: args,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final hasImage = _selectedImage != null || _imageUrl != null || _bolImageFromArgs != null;
//     final displayImage = _selectedImage ?? _bolImageFromArgs;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInvoiceCard(),
//                   const SizedBox(height: 16),
//                   _buildInstructionsCard(),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // In PODScreen - Fix the AppBar
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.backgroundColor,
//       surfaceTintColor: AppColors.backgroundColor,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 14), // FIXED: Changed from EdgeInsets.Left
//         child: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
//         ),
//       ),
//       title: Text(
//         _loadId != null ? 'POD - #$_loadId' : 'POD',
//         style: const TextStyle(
//           color: Color(0xFF1A1A2E),
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         if (_selectedImage != null || _bolImageFromArgs != null)
//           Container(
//             margin: const EdgeInsets.only(right: 14),
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5E9),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.check_circle, size: 12, color: Color(0xFF27AE60)),
//                 SizedBox(width: 4),
//                 Text('Ready',
//                     style: TextStyle(
//                         fontSize: 11,
//                         color: Color(0xFF27AE60),
//                         fontWeight: FontWeight.w700)),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildInvoiceCard() {
//     final hasImage = _selectedImage != null || _imageUrl != null || _bolImageFromArgs != null;
//     final displayImage = _selectedImage ?? _bolImageFromArgs;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: hasImage
//                   ? displayImage != null
//                   ? Image.file(
//                 displayImage,
//                 fit: BoxFit.contain,
//                 width: double.infinity,
//                 height: 400,
//                 errorBuilder: (_, __, ___) => _placeholder(),
//               )
//                   : _imageUrl != null
//                   ? Image.network(
//                 _imageUrl!,
//                 fit: BoxFit.contain,
//                 width: double.infinity,
//                 height: 400,
//                 loadingBuilder: (_, child, progress) {
//                   if (progress == null) return child;
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: progress.expectedTotalBytes != null
//                           ? progress.cumulativeBytesLoaded /
//                           progress.expectedTotalBytes!
//                           : null,
//                     ),
//                   );
//                 },
//                 errorBuilder: (_, __, ___) => _placeholder(),
//               )
//                   : _placeholder()
//                   : _placeholder(),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   hasImage
//                       ? 'POD Document${_loadId != null ? " - #$_loadId" : ""}'
//                       : 'No POD image available. Tap upload to add one.',
//                   style: AppTextStyle.SFProDisplay_Regular.copyWith(
//                     fontSize: 12,
//                     color: hasImage ? const Color(0xFF888888) : Colors.orange,
//                   ),
//                 ),
//               ),
//               if (!hasImage)
//                 TextButton.icon(
//                   onPressed: _showImageSourceDialog,
//                   icon: const Icon(Icons.upload_file, size: 16),
//                   label: const Text('Upload'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppColors.primaryColor,
//                   ),
//                 ),
//               if (hasImage && _selectedImage != null)
//                 TextButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _selectedImage = null;
//                     });
//                   },
//                   icon: const Icon(Icons.delete, size: 16, color: Colors.red),
//                   label: const Text(
//                     'Remove',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//             ],
//           ),
//           if (_bolImageFromArgs != null && _selectedImage == null)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
//                     const SizedBox(width: 6),
//                     Text(
//                       'BOL image loaded from load details',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _placeholder() {
//     return Container(
//       height: 400,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F7FA),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: const Color(0xFFE1E8ED),
//           width: 1,
//         ),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.image_not_supported,
//               size: 64,
//               color: Color(0xFF888888),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'No image available',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF888888),
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Upload a POD image to continue',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFFAAAAAA),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInstructionsCard() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.lightBlueColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline,
//                 color: AppColors.primaryColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Instructions',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             '1. Upload or capture the Proof of Delivery document\n'
//                 '2. Ensure recipient signature is visible\n'
//                 '3. Click "Continue" to proceed to BOL signature',
//             style: TextStyle(
//               fontSize: 12,
//               color: Color(0xFF555555),
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }