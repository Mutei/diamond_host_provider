import 'package:auto_size_text/auto_size_text.dart';
import 'package:daimond_host_provider/constants/colors.dart';
import 'package:daimond_host_provider/constants/styles.dart';
import 'package:daimond_host_provider/extension/sized_box_extension.dart';
import 'package:daimond_host_provider/screens/qr_image_screen.dart';
import 'package:daimond_host_provider/widgets/reused_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../backend/booking_services.dart';
import '../backend/estate_services.dart';
import '../constants/coffee_music_options.dart';
import '../constants/entry_options.dart';
import '../constants/hotel_entry_options.dart';
import '../constants/restaurant_options.dart';
import '../constants/sessions_options.dart';
import '../localization/language_constants.dart';
import '../backend/customer_rate_services.dart';
import '../utils/rooms.dart';
import '../utils/success_dialogue.dart';
import '../utils/failure_dialogue.dart';
import '../widgets/chip_widget.dart';
import 'edit_estate_screen.dart';
import 'estate_chat_screen.dart';

class ProfileEstateScreen extends StatefulWidget {
  final String nameEn;
  final String nameAr;
  final String bioEn;
  final String bioAr;
  final String estateId;
  final String estateType;
  final String location;
  final double rating;
  final String fee;
  final String deliveryTime;
  final double price;
  final String typeOfRestaurant;
  final String sessions;
  final String menuLink;
  final String entry;
  final String music;
  final double lat;
  final double lon;
  final String type;
  final String hasKidsArea;
  final String hasValet;
  final String valetWithFees;
  final String hasSwimmingPool;
  final String hasGym;
  final String hasBarber;
  final String hasMassage;
  final String isSmokingAllowed;
  final String hasJacuzziInRoom;
  final String lstMusic;

  const ProfileEstateScreen({
    Key? key,
    required this.nameEn,
    required this.nameAr,
    required this.estateId,
    required this.estateType,
    required this.location,
    required this.rating,
    required this.fee,
    required this.deliveryTime,
    required this.price,
    required this.typeOfRestaurant,
    required this.sessions,
    required this.menuLink,
    required this.entry,
    required this.music,
    required this.lat,
    required this.lon,
    required this.bioAr,
    required this.type,
    required this.bioEn,
    required this.isSmokingAllowed,
    required this.hasGym,
    required this.hasMassage,
    required this.hasBarber,
    required this.hasSwimmingPool,
    required this.hasKidsArea,
    required this.hasJacuzziInRoom,
    required this.valetWithFees,
    required this.hasValet,
    required this.lstMusic,
  }) : super(key: key);

  @override
  _ProfileEstateScreenState createState() => _ProfileEstateScreenState();
}

class _ProfileEstateScreenState extends State<ProfileEstateScreen> {
  List<String> _imageUrls = [];
  Map<String, dynamic> estate = {};
  List<Rooms> LstRooms = [];
  bool isLoading = true;
  double _overallRating = 0.0;
  final _cacheManager = CacheManager(
      Config('customCacheKey', stalePeriod: const Duration(days: 7)));
  int _currentImageIndex = 0;
  List<Map<String, dynamic>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _listenToEstateData();
    _fetchImageUrls();
    _fetchUserRatings();
    _fetchFeedback();
  }

  void _listenToEstateData() {
    String estateTypePath;
    switch (widget.estateType) {
      case "1":
        estateTypePath = "Hottel";
        break;
      case "2":
        estateTypePath = "Coffee";
        break;
      case "3":
        estateTypePath = "Restaurant";
        break;
      default:
        estateTypePath = widget.estateType;
    }

    DatabaseReference estateRef = FirebaseDatabase.instance
        .ref('App/Estate/$estateTypePath/${widget.estateId}');

    // Listen for any changes
    estateRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        setState(() {
          estate = Map<String, dynamic>.from(event.snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('No data found for this estate.');
      }
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      print('Error listening to estate data: $error');
    });
  }

  Future<void> _fetchEstateData() async {
    try {
      String estateTypePath;
      switch (widget.estateType) {
        case "1":
          estateTypePath = "Hottel";
          break;
        case "2":
          estateTypePath = "Coffee";
          break;
        case "3":
          estateTypePath = "Restaurant";
          break;
        default:
          estateTypePath = widget.estateType;
      }

      print(
          "Fetching data for estateTypePath: $estateTypePath, estateId: ${widget.estateId}");

      DatabaseReference estateRef = FirebaseDatabase.instance
          .ref('App/Estate/$estateTypePath/${widget.estateId}');

      DataSnapshot snapshot = await estateRef.get();

      if (snapshot.exists && snapshot.value != null) {
        print("Raw Estate Data: ${snapshot.value}");
        setState(() {
          estate = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('No data found for this estate.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching estate data: $e');
    }
  }

  Widget _buildStarRating(double rating, {double size = 16}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.orange, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.orange, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.orange, size: size);
        }
      }),
    );
  }

  Future<void> _fetchImageUrls() async {
    int index = 0;
    bool hasMoreImages = true;
    List<String> imageUrls = [];

    while (hasMoreImages) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('${widget.estateId}/$index.jpg');
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);

        await _cacheManager.getSingleFile(imageUrl);
      } catch (e) {
        hasMoreImages = false;
      }
      index++;
    }

    setState(() {
      _imageUrls = imageUrls;
    });
  }

  Future<void> _fetchUserRatings() async {
    CustomerRateServices rateServices = CustomerRateServices();
    final ratings =
        await rateServices.fetchEstateRatingWithUsers(widget.estateId);
    double totalRating = ratings.isNotEmpty
        ? ratings.map((e) => e['rating'] as double).reduce((a, b) => a + b) /
            ratings.length
        : 0.0;

    setState(() {
      _overallRating = totalRating;
    });
  }

  Future<void> _fetchFeedback() async {
    try {
      DatabaseReference feedbackRef =
          FirebaseDatabase.instance.ref('App/CustomerFeedback');
      DataSnapshot snapshot = await feedbackRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> feedbacks = [];
        snapshot.children.forEach((child) {
          final data = Map<String, dynamic>.from(child.value as Map);
          if (data['EstateID'] == widget.estateId) {
            feedbacks.add(data);
          }
        });
        setState(() {
          _feedbackList = feedbacks;
        });
      }
    } catch (e) {
      print('Error fetching feedback: $e');
    }
  }

  void _launchMaps() async {
    print('Latitude: ${widget.lat}, Longitude: ${widget.lon}');
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lon}';

    try {
      bool launched = await launch(googleUrl, forceWebView: false);
      print('Launch successful: $launched');
    } catch (e) {
      print('Error launching maps: $e');
    }
  }

  String getTranslatedTypeOfRestaurant(BuildContext context, String types) {
    // Check the current locale
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Split the types by comma and trim whitespace
    List<String> typeList =
        types.split(',').map((type) => type.trim()).toList();

    // Translate each type in the list
    List translatedTypes = typeList.map((type) {
      final match = restaurantOptions.firstWhere(
        (option) => option['label'] == type,
        orElse: () => {'label': type, 'labelAr': type},
      );
      return isArabic ? match['labelAr'] : match['label'];
    }).toList();

    // Join the translated types back with a comma
    return translatedTypes.join(', ');
  }

  String getTranslatedSessions(BuildContext context, String types) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    List<String> typeList =
        types.split(',').map((type) => type.trim()).toList();
    List translatedTypes = typeList.map((type) {
      final match = sessionsOptions.firstWhere(
        (option) => option['label'] == type,
        orElse: () => {'label': type, 'labelAr': type},
      );
      return isArabic ? match['labelAr'] : match['label'];
    }).toList();
    return translatedTypes.join(', ');
  }

  String getTranslatedHotelEntry(BuildContext context, String types) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    List<String> typeList =
        types.split(',').map((type) => type.trim()).toList();
    List translatedTypes = typeList.map((type) {
      final match = hotelEntryOptions.firstWhere(
        (option) => option['label'] == type,
        orElse: () => {'label': type, 'labelAr': type},
      );
      return isArabic ? match['labelAr'] : match['label'];
    }).toList();
    return translatedTypes.join(', ');
  }

  String getTranslatedEntry(BuildContext context, String types) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    List<String> typeList =
        types.split(',').map((type) => type.trim()).toList();
    List translatedTypes = typeList.map((type) {
      final match = entryOptions.firstWhere(
        (option) => option['label'] == type,
        orElse: () => {'label': type, 'labelAr': type},
      );
      return isArabic ? match['labelAr'] : match['label'];
    }).toList();
    return translatedTypes.join(', ');
  }

  String getTranslatedCoffeeMusicOptions(BuildContext context, String types) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    List<String> typeList =
        types.split(',').map((type) => type.trim()).toList();
    List translatedTypes = typeList.map((type) {
      final match = coffeeMusicOptions.firstWhere(
        (option) => option['label'] == type,
        orElse: () => {'label': type, 'labelAr': type},
      );
      return isArabic ? match['labelAr'] : match['label'];
    }).toList();
    return translatedTypes.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String displayName = languageCode == 'ar'
        ? (estate['NameAr'] ?? widget.nameAr)
        : (estate['NameEn'] ?? widget.nameEn);
    final String displayBio = languageCode == 'ar'
        ? (estate['BioAr'] ?? widget.bioAr)
        : (estate['BioEn'] ?? widget.bioEn);

    return Scaffold(
      appBar: AppBar(
        iconTheme: kIconTheme,
        elevation: 0,
        actions: [
          InkWell(
            child: Icon(Icons.map_outlined),
            onTap: () {
              _launchMaps();
            },
          ),
          10.kW,
          if (widget.estateType != "1")
            InkWell(
              child: const Icon(Icons.edit),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditEstate(
                    objEstate: estate,
                    LstRooms: LstRooms,
                  ),
                ));
                // Refresh estate data after returning from EditEstate
                _fetchEstateData();
              },
            ),
          10.kW,
          IconButton(
            icon: Icon(
              Icons.chat,
              color: kDeepPurpleColor,
            ),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EstateChatScreen(
                    estateId: widget.estateId,
                    estateNameEn: widget.nameEn,
                    estateNameAr: widget.nameAr,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imageUrls.isEmpty
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                                child: CircularProgressIndicator()),
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  itemCount: _imageUrls.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: _imageUrls[index],
                                        cacheManager: _cacheManager,
                                        placeholder: (context, url) =>
                                            Container(color: Colors.grey[300]),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1} / ${_imageUrls.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    16.kH,
                    Text(displayName, style: kTeritary),
                    8.kH,
                    Text(displayBio,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey)),
                    16.kH,
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        4.kW,
                        Text(
                          _overallRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    16.kH,
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        if (widget.type == "3")
                          ChipWidget(
                            icon: Icons.fastfood,
                            label: getTranslatedTypeOfRestaurant(
                              context,
                              estate['TypeofRestaurant'] ??
                                  widget.typeOfRestaurant,
                            ),
                          ),
                        if (widget.type == "3" || widget.type == "2")
                          ChipWidget(
                            icon: Icons.home,
                            label: getTranslatedSessions(
                              context,
                              estate['Sessions'] ?? widget.sessions,
                            ),
                          ),
                        ChipWidget(
                          icon: Icons.grain,
                          label: widget.type == "1"
                              ? getTranslatedHotelEntry(
                                  context,
                                  estate['Entry'] ?? widget.entry,
                                )
                              : getTranslatedEntry(
                                  context,
                                  estate['Entry'] ?? widget.entry,
                                ),
                        ),
                        ChipWidget(
                          icon: Icons.music_note,
                          label: (widget.type == "3" || widget.type == "1")
                              ? ((estate['Music'] ?? widget.music) == "1"
                                  ? getTranslated(context, "There is music")
                                  : getTranslated(context, "There is no music"))
                              : (widget.type == "2"
                                  ? ((estate['Music'] ?? widget.music) == "1"
                                      ? getTranslatedCoffeeMusicOptions(
                                          context,
                                          estate['Lstmusic'] ?? widget.lstMusic,
                                        )
                                      : getTranslated(
                                          context, "There is no music"))
                                  : getTranslated(
                                      context, "There is no music")),
                        ),
                        if (widget.type != "1")
                          ChipWidget(
                            icon: Icons.boy,
                            label: (estate['HasKidsArea'] ??
                                        widget.hasKidsArea) ==
                                    "1"
                                ? getTranslated(context, "We have kids area")
                                : getTranslated(
                                    context, "We dont have kids area"),
                          ),
                        if (widget.type == "1")
                          ChipWidget(
                            icon: Icons.bathtub,
                            label: (estate['HasJacuzziInRoom'] ??
                                        widget.hasJacuzziInRoom) ==
                                    "1"
                                ? getTranslated(context, "We have jaccuzzi")
                                : getTranslated(
                                    context, "We dont have jaccuzzi"),
                          ),
                        ChipWidget(
                          icon: Icons.car_rental,
                          label: (estate['HasValet'] ?? widget.hasValet) == "1"
                              ? getTranslated(
                                  context, "Valet service available")
                              : getTranslated(
                                  context, "No valet service available"),
                        ),
                        if ((estate['HasValet'] ?? widget.hasValet) == "1")
                          ChipWidget(
                            icon: Icons.money,
                            label: (estate['ValetWithFees'] ??
                                        widget.valetWithFees) ==
                                    "1"
                                ? getTranslated(context, "Valet is not free")
                                : getTranslated(context, "Valet is free"),
                          ),
                        if (widget.type == "1")
                          ChipWidget(
                            icon: Icons.pool,
                            label: (estate['HasSwimmingPool'] ??
                                        widget.hasSwimmingPool) ==
                                    "1"
                                ? getTranslated(
                                    context, "We have swimming pool")
                                : getTranslated(
                                    context, "We dont have swimming pool"),
                          ),
                        if (widget.type == "1")
                          ChipWidget(
                            icon: Icons.spa,
                            label:
                                (estate['HasMassage'] ?? widget.hasMassage) ==
                                        "1"
                                    ? getTranslated(context, "We have massage")
                                    : getTranslated(
                                        context, "We dont have massage"),
                          ),
                        if (widget.type == "1")
                          ChipWidget(
                            icon: Icons.fitness_center,
                            label: (estate['HasGym'] ?? widget.hasGym) == "1"
                                ? getTranslated(context, "We have Gym")
                                : getTranslated(context, "We dont have Gym"),
                          ),
                        if (widget.type == "1")
                          ChipWidget(
                            icon: Icons.content_cut,
                            label: (estate['HasBarber'] ?? widget.hasBarber) ==
                                    "1"
                                ? getTranslated(context, "We have barber")
                                : getTranslated(context, "We dont have barber"),
                          ),
                        ChipWidget(
                          icon: Icons.smoking_rooms,
                          label: (estate['IsSmokingAllowed'] ??
                                      widget.isSmokingAllowed) ==
                                  "1"
                              ? getTranslated(context, "Smoking is allowed")
                              : getTranslated(
                                  context, "Smoking is not allowed"),
                        ),
                      ],
                    ),
                    16.kH,
                    AutoSizeText(
                      getTranslated(context, "Feedback"),
                      style: kTeritary,
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    8.kH,
                    _feedbackList.isEmpty
                        ? const Center(child: Text("No feedback available."))
                        : Container(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _feedbackList.length,
                              itemBuilder: (context, index) {
                                final feedback = _feedbackList[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 16.0),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    kDeepPurpleColor,
                                                backgroundImage: feedback[
                                                                'profileImageUrl'] !=
                                                            null &&
                                                        feedback[
                                                                'profileImageUrl']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? CachedNetworkImageProvider(
                                                        feedback[
                                                            'profileImageUrl'])
                                                    : AssetImage(
                                                            'assets/images/default_avatar.png')
                                                        as ImageProvider,
                                                child: feedback['profileImageUrl'] ==
                                                            null ||
                                                        feedback[
                                                                'profileImageUrl']
                                                            .toString()
                                                            .isEmpty
                                                    ? Text(
                                                        (feedback['userName'] !=
                                                                    null &&
                                                                (feedback['userName']
                                                                        as String)
                                                                    .isNotEmpty)
                                                            ? (feedback['userName']
                                                                    as String)[0]
                                                                .toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AutoSizeText(
                                                      feedback['userName'] ??
                                                          getTranslated(context,
                                                              'Anonymous'),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 12,
                                                    ),
                                                    Text(
                                                      feedback['feedbackDate'] !=
                                                              null
                                                          ? DateFormat.yMMMd()
                                                              .format(DateTime
                                                                  .parse(feedback[
                                                                      'feedbackDate']))
                                                          : '',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _buildStarRating(
                                            (feedback['RateForEstate'] ?? 0)
                                                .toDouble(),
                                            size: 16,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Estate Rating: ${feedback['RateForEstate'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          AutoSizeText(
                                            feedback['feedback'] ??
                                                getTranslated(context,
                                                    'No feedback provided'),
                                            style:
                                                const TextStyle(fontSize: 14),
                                            maxLines: 10,
                                            minFontSize: 10,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.restaurant,
                                                          color: Colors.orange,
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      _buildStarRating(
                                                        (feedback['RateForFoodOrDrink'] ??
                                                                0)
                                                            .toDouble(),
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Food Rating: ${feedback['RateForFoodOrDrink'] ?? 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .miscellaneous_services,
                                                          color: Colors.orange,
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      _buildStarRating(
                                                        (feedback['RateForServices'] ??
                                                                0)
                                                            .toDouble(),
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Service Rating: ${feedback['RateForServices'] ?? 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    24.kH,
                    CustomButton(
                      text: getTranslated(context, "View your Qr Code"),
                      onPressed: () {
                        if (isLoading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                getTranslated(context,
                                    'Data is still loading. Please try again shortly.'),
                              ),
                            ),
                          );
                        } else if (estate.isEmpty ||
                            estate['IDUser'] == null ||
                            estate['NameEn'] == null) {
                          print('Estate Data: $estate');
                          print('IDUser: ${estate['IDUser']}');
                          print('NameEn: ${estate['NameEn']}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                getTranslated(context,
                                    'Unable to load QR Code. Please ensure estate data is complete.'),
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRImage(
                                userId: estate['IDUser'],
                                userName: estate['NameEn'],
                                estateId: widget.estateId,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    16.kH,
                  ],
                ),
              ),
            ),
    );
  }
}
