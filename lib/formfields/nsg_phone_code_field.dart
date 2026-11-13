part of 'nsg_input.dart';

/// Dial digits are presentation only; the existing field contract stays ISO.
class _NsgPhoneCodeField extends StatefulWidget {
  const _NsgPhoneCodeField({
    super.key,
    required this.iso,
    required this.initialIso,
    required this.countries,
    required this.enabled,
    required this.showClear,
    required this.focusNode,
    required this.label,
    required this.onChanged,
    required this.onComplete,
    required this.onSubmitted,
    required this.decoration,
    required this.style,
  });

  final String iso;
  final String? initialIso;
  final List<PhoneCountryData> countries;
  final bool enabled, showClear;
  final FocusNode focusNode;
  final String label;
  final ValueChanged<String> onChanged, onSubmitted;
  final VoidCallback onComplete;
  final InputDecoration decoration;
  final TextStyle style;

  @override
  State<_NsgPhoneCodeField> createState() => _NsgPhoneCodeFieldState();
}

class _NsgPhoneCodeFieldState extends State<_NsgPhoneCodeField> {
  late final TextEditingController _digits;
  late String _modelIso;
  String _preferredIso = '';
  bool _cleared = false;

  PhoneCountryData? _country(String? iso) => widget.countries
      .where((c) => c.countryCode?.toUpperCase() == iso?.toUpperCase())
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    _modelIso = widget.iso.toUpperCase();
    _preferredIso = _modelIso;
    _digits = TextEditingController(text: _country(_modelIso)?.phoneCode ?? '');
    _initialCountry();
  }

  void _initialCountry() {
    if (_cleared || _modelIso.isNotEmpty) return;
    final initial = _country(widget.initialIso);
    if (initial == null) return;
    final iso = initial.countryCode!.toUpperCase();
    _modelIso = iso;
    _preferredIso = iso;
    _digits.text = initial.phoneCode ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.enabled ||
          _modelIso != iso ||
          widget.iso.isNotEmpty) {
        return;
      }
      widget.onChanged(iso);
      widget.onComplete();
    });
  }

  @override
  void didUpdateWidget(covariant _NsgPhoneCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.iso.toUpperCase();
    // Parent rebuilds after our own callback must keep partially typed digits.
    if (incoming != _modelIso) {
      _modelIso = incoming;
      if (incoming.isNotEmpty) _preferredIso = incoming;
      final next = _country(incoming)?.phoneCode ?? '';
      _digits.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    if (oldWidget.initialIso != widget.initialIso ||
        (!oldWidget.enabled && widget.enabled)) {
      _initialCountry();
    }
  }

  void _write(String iso) {
    _modelIso = iso;
    if (iso.isNotEmpty) _preferredIso = iso;
    widget.onChanged(iso);
  }

  void _typed(String digits) {
    _cleared = true;
    final matching = widget.countries.where((c) => c.phoneCode == digits);
    final selected =
        matching
            .where((c) => c.countryCode?.toUpperCase() == _preferredIso)
            .firstOrNull ??
        matching.firstOrNull;
    _write(selected?.countryCode?.toUpperCase() ?? '');
    setState(() {});
  }

  Future<void> _pick() async {
    final selected = await showDialog<PhoneCountryData>(
      context: context,
      builder: (_) => _NsgPhoneCountryDialog(
        countries: widget.countries,
        selectedIso: _modelIso,
        label: widget.label,
      ),
    );
    if (!mounted ||
        !widget.enabled ||
        selected == null ||
        _country(selected.countryCode) == null) {
      return;
    }
    _cleared = true;
    _digits.text = selected.phoneCode ?? '';
    _write(selected.countryCode!.toUpperCase());
    widget.onComplete();
    setState(() {});
  }

  Widget _button(IconData icon, String tooltip, VoidCallback? action) =>
      IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: icon == Icons.clear
              ? Theme.of(context).extension<NsgInputTheme>()?.clearIconColor ??
                    nsgtheme.nsginputCloseIconColor
              : null,
        ),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 24, height: 36),
        onPressed: action,
      );

  @override
  Widget build(BuildContext context) {
    final strings = MaterialLocalizations.of(context);
    return TextFormField(
      controller: _digits,
      focusNode: widget.focusNode,
      readOnly: !widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: _typed,
      onFieldSubmitted: widget.onSubmitted,
      style: widget.style,
      decoration: widget.decoration.copyWith(
        prefixText: '+',
        suffixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 36,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.decoration.suffixIcon != null)
              widget.decoration.suffixIcon!,
            if (widget.enabled && widget.showClear && _digits.text.isNotEmpty)
              _button(Icons.clear, strings.deleteButtonTooltip, () {
                _digits.clear();
                _typed('');
                widget.onComplete();
              }),
            _button(
              Icons.arrow_drop_down,
              strings.showMenuTooltip,
              widget.enabled && widget.countries.isNotEmpty ? _pick : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _digits.dispose();
    super.dispose();
  }
}

class _NsgPhoneCountryDialog extends StatelessWidget {
  const _NsgPhoneCountryDialog({
    required this.countries,
    required this.selectedIso,
    required this.label,
  });
  final List<PhoneCountryData> countries;
  final String selectedIso, label;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(label),
    content: SizedBox(
      width: 400,
      height: MediaQuery.sizeOf(context).height * .55,
      child: ListView.builder(
        itemExtent: 52,
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final iso = country.countryCode?.toUpperCase() ?? '';
          return ListTile(
            key: ValueKey('nsg-phone-country-$iso'),
            selected: iso == selectedIso,
            title: Text(country.country ?? iso),
            leading: Text(iso),
            trailing: Text('+${country.phoneCode ?? ''}'),
            onTap: () => Navigator.of(context).pop(country),
          );
        },
      ),
    ),
  );
}
