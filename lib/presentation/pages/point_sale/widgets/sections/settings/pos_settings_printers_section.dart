import 'package:flutter/material.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/printer/models/printer_device.dart';
import '../../../../../../shared/printer/printer_service.dart';
import '../../../../../widgets/empty_data.dart';

class PosSettingsPrintersSection extends StatefulWidget {
  final PrinterService printerService;

  const PosSettingsPrintersSection({super.key,required this.printerService});

  @override
  State<PosSettingsPrintersSection> createState() =>
      _PosSettingsPrintersSectionState();
}

class _PosSettingsPrintersSectionState
    extends State<PosSettingsPrintersSection> {
  final ScrollController _scrollController = ScrollController();
  late PrinterService _printerService;
  bool _isSearching = false;
  List<PrinterDevice> _devices = [];
  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _searchDevices() async {

    setState(() {
      _isSearching = true;
      _devices.clear();
    });


    try {

      final devices =
      await widget.printerService.scan();


      if(!mounted) return;


      setState(() {
        _devices = devices;
      });


    } catch(e){

      debugPrint(
          "Error buscando impresoras: $e"
      );

    }


    if(!mounted) return;


    setState(() {
      _isSearching = false;
    });

  }
  Future<void> _loadInitial() async {

    if (!mounted) return;

  }

  Future<void> _loadMore() async {

  }



  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        _buildPrinterTabs(),

        Expanded(
          child: _buildPrinterContent(),
        ),

      ],
    );
  }


  int _selectedPrinterTab = 0;
  Widget _buildPrinterContent(){

    switch(_selectedPrinterTab){

      case 0:

       return _buildSearchDevices();


      case 1:
        return const EmptyData(
          icon: Icons.bluetooth_connected,
          title: 'Dispositivos conectados',
          descriptionText:
          'Aquí aparecerán las impresoras conectadas anteriormente.',
          linkText: 'Más información',
        );


      case 2:
        return const EmptyData(
          icon: Icons.print,
          title: 'Impresoras configuradas',
          descriptionText:
          'Aquí estarán tus impresoras del punto de venta.',
          linkText: 'Más información',
        );


      default:
        return Container();

    }

  }
  Widget _buildPrinterTabs() {

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ToggleButtons(
        isSelected: [
          _selectedPrinterTab == 0,
          _selectedPrinterTab == 1,
          _selectedPrinterTab == 2,
        ],

        onPressed: (index){

          setState(() {
            _selectedPrinterTab = index;
          });

        },

        children: const [

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'Buscar',
            ),
          ),


          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'Conectadas',
            ),
          ),


          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'Impresoras',
            ),
          ),

        ],
      ),
    );

  }
  Widget _buildSearchDevices(){

    return Column(
      children:[
        ElevatedButton.icon(
          onPressed:
          _isSearching
              ? null
              : _searchDevices,
          icon:
          const Icon(
            Icons.bluetooth_searching,
          ),


          label:
          Text(
            _isSearching
                ? 'Buscando...'
                : 'Buscar dispositivos',
          ),

        ),


        Expanded(

          child:

          ListView.builder(

            itemCount:_devices.length,


            itemBuilder:(context,index){

              final device =
              _devices[index];


              return ListTile(

                leading:
                const Icon(
                  Icons.print,
                ),


                title:
                Text(
                  device.name,
                ),


                subtitle:
                Text(
                  device.address,
                ),

              );

            },

          ),

        )

      ],
    );

  }
}