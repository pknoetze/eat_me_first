enum SortOption {
  expiryDate(label: 'Expiry Date'),
  name(label: 'Name');

  final String label;
  const SortOption({required this.label});
}
